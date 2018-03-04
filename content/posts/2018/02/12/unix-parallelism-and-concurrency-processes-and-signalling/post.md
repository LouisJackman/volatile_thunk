Title: Unix Parallelism and Concurrency: Processes & Signalling
Date: 2018-02-12 22:30
Tags: unix, python, c

In this era of threads and asynchronous abstractions, applications and processes
have become almost synonymous. A process is widely seen as the operating
system's underlying representation of a whole running application. However, by
limiting ourselves to this model we cut outselves off from an elegant set of
tools for parallelism and concurrency.

In case you thought this blog's design looked prehistoric enough, it's being
started with a post about following concurrency patterns rooted in the era in
which the mouse was a keen invention.

The key construct behind process-based Unix concurrency is the
[fork](https://linux.die.net/man/2/fork) system call. It's practically a
paradox: one program calls it yet two programs finish calling it to move on.
This appears as quite the oddity to programmers of contemporary environments
like Java and the JavaScript; how can a mere function call violate the
fundamental laws of how a written program executes?

Most environments, despite having a set of rules its programmers can depend on,
have occasional strange artefacts on the surface that violate such rules and
are exposed by the underlying system.

A Java program holding a reference to an object ensures that
object remains alive, but the system exposes a different type of reference
tracking with the
[java.lang.ref.WeakReference](https://docs.oracle.com/javase/9/docs/api/java/lang/ref/WeakReference.html)
type insofar as allowing an object to be deleted while the programmer is still
holding onto it. Likewise, storing a string literal into a object will never
block execution in JavaScript, but there's an exception of course that exposes
the underlying browser environment:
[window.location](https://developer.mozilla.org/en-US/docs/Web/API/Window/location).
Assigning a string to that cancels the current flow of execution by redirecting
the page, halting the current JavaScript environment and throwing it away.

In C, or even other higher level language like Python or Ruby, the environment
is not a language-specific world unto itself like Java or a web browser; it is
instead our underlying operating system. Python and Ruby build their own
abstractions on top, but they are not as aggressive about hiding the underlying
operating systems as programming environments like Java and in-browser
JavaScript.

Apart from your operating system, languages like Python and Ruby provide little
more than extra gizmos provided by the language runtime like garbage collection
and some introspection capabilities. System calls from these languages, like the
previous examples, provide capabilities that can step outside of the normal
rules of the language you are using. Unix doesn't care about the `finally`
blocks that your language runtime makes "guarantees" about running; if you
`exec`, the whole process' runtime image is being swapped out and execution is
jumping. Those finally blocks will be deep sixed.

Invoking the `fork` system call in Python 3 is just:

    :::python

    import os

    if os.fork() == 0:
        print('running the child process')
    else:
        print('running the parent process')

    print('finished a process')

This program demonstrates that oxymoron of one program entering `fork()` and two
leaving it; how else could _both_ branches be run in a single `if`? This allows
for a form of concurrency and parallelism:

    :::shell

    $ python3 program.py
    running the parent process
    finished a process
    running the child process
    finished a process

Running operations side-by-side is hardly an elusive trick. Anyone spinning up a
thread in Java or interleaving two `setTimeout`s in JavaScript could replicate
something similar. Unlike the latter, however, the application can still
continue while one of the tasks infinitely loops:

    :::python

    import os
    import time

    if os.fork() == 0:
        while True:
            pass
    else:
        print('finished')

These clearly aren't events being triggered, otherwise the infinite loop would
block the event loop, stopping the second event `print('finished')` from
running. Single events blocking the entire event loop and grinding large
applications to a halt
[is not a theoretical problem](https://www.owasp.org/index.php/Regular_expression_Denial_of_Service_-_ReDoS).

Threads sidestep this problem by utilising the operating system's _scheduler_
which slices up time on the computer between competing tasks to avoid any
one of them starving the whole system of resources, but they come with their
own arsenel of footguns in many shapes and sizes:

    :::python

    import os
    import time
    import threading


    class UserCounter:

        def __init__(self):
            self.count = 0

        def increment(self):
            count = self.count
            print(f'User {count} visited')
            self.count = count + 1


    user_counter = UserCounter()


    def handle_requests():
        while True:

            # Pretend to serve a user on the network.
            time.sleep(.3)

            user_counter.increment()


    for _ in range(os.cpu_count()):
        thread = threading.Thread(target=handle_requests)
        thread.start()

An expensive operation is divided and conquered, handling user requests across
as many threads as we have processor cores. Unfortunately `user_counter` is
shared across all threads, meaning the loading and incrementing is interleaved
with other concurrent threads, causing the counter to be wrong most of the time.

    :::shell
    $ python3 program.py
    User 0 visited
    User 0 visited
    User 1 visited
    User 1 visited
    User 1 visited

We must remember quite a few rules to avoid shooting ourselves in the foot in
multithreaded systems.
[Just a few.](https://docs.oracle.com/javase/specs/jls/se8/html/jls-17.html#jls-17.4.5)

Between dealing with data races, deadlocks, stale reads, and other threading
esoteria, programming with threads is playing Russian Roulette with a fully
loaded uzi. An uzi that jams a lot too, as adding too many _critical regions_ to
synchronise threaded code bottlenecks your otherwise concurrent program into
single-threaded hotspots that can end up throttling your application's
performance.

Have you managed to get the locking fine-grained enough to get good performance
while avoiding those pitfalls? Well, hopefully you're not building any more
abstractions on top of it, as
[locks do not compose](https://www.youtube.com/watch?v=dGVqrGmwOAw).

Operating system processes are bulky and cannot be spun up as fast as threads,
but are more isolated from one another. They have their own memory space,
meaning one buggy process can't corrupt the in-memory data of another. Unlike
threads, misbehaving processes can actually be killed without causing
[strange, hard to trace bugs in the underlying system](https://docs.oracle.com/javase/8/docs/technotes/guides/concurrency/threadPrimitiveDeprecation.html).

Processes also encourage communication via message-passing mechanisms like
signalling, domain sockets, and networking connections. It turns out that these
solutions are easier to scale across multiple physical machines than shared
memory communication, as
[others also discovered quite a long time ago](https://www.erlang.org/).

Signalling is the easiest way to get your feet wet with Unix IPC, _Inter-Process
Communication_:

    :::python
    from os import _exit, kill, getppid, fork,
    from signal import sigwait, SIGCONT
    from time import sleep


    def expensive_operation_1():
        sleep(5)
        kill(getppid(), SIGCONT)
        sigwait((SIGCONT, ))
        print('Very expensive operation 1 complete.')


    def expensive_operation_2():
        time.sleep(2)
        kill(getppid(), SIGCONT)
        sigwait((SIGCONT, ))
        print('Slightly expensive operation 2 complete.')


    def start_children():
        pid_1 = fork()
        if pid_1 == 0:
            expensive_operation_1()
            _exit(0)

        pid_2 = fork()
        if pid_2 == 0:
            expensive_operation_2()
            _exit(0)

        return pid_1, pid_2


    def wait_for_all(pids):
        for _ in pids:
            sigwait((SIGCONT, ))


    def display_in_order(pids):
        for pid in pids:
            kill(pid, SIGCONT)
            waitpid(pid, 0)


    pids = start_children()
    print('All children started.')
    wait_for_all(pids)
    print(
        'All children finished main tasks; asking them to display results in '
        'order.')
    display_in_order(pids)

Running this yields:

    :::shell
    $ python3 test.py
    All children started.
    All children finished main tasks; asking them to display results in order.
    Very expensive operation 1 complete.
    Slightly expensive operation 2 complete.

The slightly expensive operation, despite being quicker, displays its
output after the longer running one. Both of them ran at the same time; it
waited for 5 seconds, not 7. Combining `fork` with Unix process signalling, the
following was organised:

* Multiple tasks are forked in seperate processes. This not only allows IO
  interleaving like event systems, but also utilisation of multiple processor
  cores if we assumed the mock `sleep`s are actually computationally expensive
  operations.
* The parent process waits for a signal, specifically `SIGCONT`, to indicate a
  child process finished its main task. It waits for the same amount of signals
  as child processes. This means it does not move on until they all declare
  having finished.
* It iterates over the processes in the order they were defined, sends a
  message to each to display their results, and waits for them to complete.

The whole process not only parallelises the compution, but it linearises the
results. Notice the lack of locks, shared queues, and polling.

Running `man signal` on a Unix device tells us what signals exist. Choosing
`SIGCONT` was an arbritary decision, as most of the signals here could have been
used. `SIGCONT` just so happens to best describe what it was doing: continuing
after the tasks had finished waiting for something else.

     No    Name         Default Action       Description
     1     SIGHUP       terminate process    terminal line hangup
     2     SIGINT       terminate process    interrupt program
     3     SIGQUIT      create core image    quit program
     4     SIGILL       create core image    illegal instruction
     5     SIGTRAP      create core image    trace trap
     6     SIGABRT      create core image    abort program (formerly SIGIOT)
     7     SIGEMT       create core image    emulate instruction executed
     8     SIGFPE       create core image    floating-point exception
     9     SIGKILL      terminate process    kill program
     10    SIGBUS       create core image    bus error
     11    SIGSEGV      create core image    segmentation violation
     12    SIGSYS       create core image    non-existent system call invoked
     13    SIGPIPE      terminate process    write on a pipe with no reader
     14    SIGALRM      terminate process    real-time timer expired
     15    SIGTERM      terminate process    software termination signal
     16    SIGURG       discard signal       urgent condition present on socket
     17    SIGSTOP      stop process         stop (cannot be caught or ignored)
     18    SIGTSTP      stop process         stop signal generated from keyboard
     19    SIGCONT      discard signal       continue after stop
     20    SIGCHLD      discard signal       child status has changed
     21    SIGTTIN      stop process         background read attempted from control terminal
     22    SIGTTOU      stop process         background write attempted to control terminal
     23    SIGIO        discard signal       I/O is possible on a descriptor (see fcntl(2))
     24    SIGXCPU      terminate process    cpu time limit exceeded (see setrlimit(2))
     25    SIGXFSZ      terminate process    file size limit exceeded (see setrlimit(2))
     26    SIGVTALRM    terminate process    virtual time alarm (see setitimer(2))
     27    SIGPROF      terminate process    profiling timer alarm (see setitimer(2))
     28    SIGWINCH     discard signal       Window size change
     29    SIGINFO      discard signal       status request from keyboard
     30    SIGUSR1      terminate process    User defined signal 1
     31    SIGUSR2      terminate process    User defined signal 2

Some of those signals have special behaviour, like being impossible to handle
such as `SIGKILL`, or being handled by some language runtimes for us, like
Python translating `SIGINT` into `KeyboardInterrupt` exceptions. `SIGUSR1` and
`SIGUSR2` are good for non-standard signals for application-specific events.

Some notes about the previous code before moving on:

* `_exit` is just a normal exit without proper clean up. We only want the main
  process to clean up properly, as the child processes just need to do their
  allocated tasks and immediately stop.
* `kill` by default, well, _kills_ processes. Passing it other kinds of signals
  turns it into a general signalling mechanism that don't necessarily kill the
  process.
* `sigwait((SIGCONT, ))` looks strange because of Python's odd syntax for a
  single-item tuple: `(42,)`. The comma disambiguates between single-item tuples
  and grouped expressions. The statement is just waiting until a `SIGCONT`
  signal is sent to the current process.
* The function `wait_for_all` does nothing with the processes it iterates over,
  it only matters that it does so that many times before continuing.

We might want to wait for a signal, but not if it takes too long:

    :::python
    from os import fork, _exit, kill
    from signal import signal, SIGALRM, SIGCHLD, SIGKILL, alarm, sigwait
    from time import sleep

    signal(SIGCHLD, lambda signal_number, stack_frame: None)


    def set_five_second_alarm():
        alarm(5)


    def remove_alarm():
        alarm(0)


    def run_slow_operation():
        sleep(10)
        print('finished slow operation')
        _exit()


    def wait_for(pid):
        set_five_second_alarm()
        try:
            if sigwait((SIGCHLD, SIGALRM)) == SIGALRM:
                print('too late; killing child process')
                kill(pid, SIGKILL)
            else:
                print('child process finished')
        finally:
            remove_alarm()


    pid = fork()
    if pid == 0:
        run_slow_operation()
    else:
        wait_for(pid)

Alarms allow timers to be interleaved with events. Three things to note in that
code: firstly, `0` is interpreted by `alarm` as 'disable all active alarms';
secondly, `SIGCHLD` is a signal for when any child processes stop running;
finally, some signals like `SIGCHLD` do nothing by default. Even waiting for
them with `sigwait` does nothing unless the system knows you want to handle
them, which the above example does by hooking an otherwise useless lambda
expression to the `SIGCHLD` signal. We don't care about the lambda, just that
the system knows we want to listen to that signal in general.

If we wanted, we could put all of our event handling logic directly in signal
handlers like that rather than waiting with `sigwait`. In fact, most programs
that use signals do just that.

Be careful of default signal behaviour. If your program is being run by a parent
process, it can pass down non-default 'default' signal handlers. If a signal
must be picked up by your program, even for just `sigwait`, add a dummy signal
hook like above to be sure.

Signalling is one of the simplest forms of Unix IPC. It's enough to coordinate
processes, but does not allow sending messages with payloads. Domain sockets,
networking connections, and other IPC systems allow a programmer to go a lot
further.

If Unix IPC is such a powerful and battle-tested standard for parallelisation
and concurrency, why isn't it the primary port of call for solving such problems
today? Well, for starters it's slow and bulky even with modern optimisations
like copy-on-write for copying processes' memory spaces to forked children.
Although shared memory has problems, it is sometimes the best way of solving
certain problems and it's easier with threads. Event-driven systems avoid many
of the problems with threads and handle the majority of concurrency use cases in
modern webservices, so managing processes manually becomes unnecessary.

Many applications written in the likes of Node.js use processes just to utilize
as many processor cores as possible, but hide process management behind modules
like `cluster`. Processes are used to parallelise, but the concurrency is
handled by abstractions built atop an event loop. Using a process per request
would destroy performance as they are too coarse for that level of fine-grained
concurrency.  In fact, that's how web applications were handled many years ago
in CGI scripts.  There's a reason it isn't done that way anymore.

Despite these problems, Unix IPC mechanisms are sometimes still the best way of
tackling certain concurrency and parallelism problems, so it's worth keeping
those dusty old '70s techniques in the toolbox.
