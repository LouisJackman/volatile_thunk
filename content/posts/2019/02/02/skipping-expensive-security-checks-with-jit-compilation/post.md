Title: To Secure Systems of the Future, We must Rethink our Notions of "Environment" and "Operating System"
Date: 2019-02-02 17:17
Tags: plt, appsec, security
Summary: The blurred distinction between environments and the layers in operating systems has made security responsibilities unclear, leading to performance regressions from duplicated checks, and leaving areas unprotected.

For all of the proclamations about using C for "performance reasons", its lack
of safety has inflicted performance penalties on contemporary systems that must
be paid by programs written in all other languages.

Blaming C for this is unfair though. The real culprit is machine code
still being the primary delivery format format for executables on mainstream
operating systems. They might alter some addresses and put their own executable
format header on top, but even with all of the OS-specific executable format
additions, the majority of the executable code is still machine code provided
directly to the CPU.

The delivery format therefore assumes the lowest common denominator of modern
computing: the Von Newman architecture with plenty of CPU architecture
edgecases, such as the massive complexity and legacy of the x86 instruction set.

# The Problem with Machine Code as a Distributed Application Artefact

The CPU and OS must assume that the code doesn't properly split procedure
stackframes and data stored on the stack, allowing them to mingle in the same
space. They must assume that the source language is sufficiently under-specified
as to allow user-created buffer overflow to overwrite otherwise unrelated
variables and potentially tamper with control flow. They must assume that the
source language has no notion of safe data primitives that the rest of the
program is built on top of; the worst-case scenario of raw memory addresses being
conjured out of thin air and dereferenced must be anticipated.

Historically OSes and CPUs have allowed such behaviour, reasoning that it is
the job of the programmer to check their code does not misbehave and the role
of the user to ensure only trusted programs run on their OS. This view, still
unfortunately held by some of the "old guard" across various computing
communities, has thankfully waned in recent decades.

Memory protection is ubiquitous in modern operating systems, aided by support in
underlying CPUs such as the x86's memory protection. Operating systems have also
added W^X (write XOR execute), a.k.a. DEP (data execution prevention) support to
stop memory corruption allowing the writing of new code and its subsequent
execution in running processes, an attack that allow sliding nefarious behaviour
into the security context of a trusted running process. Other examples include
stack canaries for detecting stack corruption, randomising addresses to
frustrate exploit reproducability via ASLR (address space layout randomisation),
and even updating compilers or rewriting code as it executes to frustrate
control flow attacks and return-oriented programming.

While not fixing all memory safety problems of C programs, which is practically
impossible, they do an admirable job at frustrating adversaries, eliminating
whole subcatagories of memory safety attacks, and most importantly isolating a
compromised process from serving as a pivoting point to attack the rest of the
system.

---

This isn't a free lunch though. Most of these mitigations incur runtime
performance costs. Even more costs pile up if such mitigations are revealed to
[not actually work]() and then need to be implemented again in higher levels.

All of this poses a question: why should other languages pay these performance
costs due to the failings of C and other languages lacking memory safety? If,
say Lisp, only gives out access to objects by reference thereby making it
impossible for one process to arbitrarily grab data of another process, why
should it pay the cost for memory corruption runtime mitigations underneath?

The technical reason is that Lisp Machines and Java bytecode-executing CPUs
never took off, so today's safe language implementations run atop general
purpose OSes. The final code that _actually runs_ such as the Lisp interpreter
or a Java virtual machine written in C++, is native code for the underlying
machine. This native code, as far as the CPU and OS are aware, can potentially
have memory corruption bugs and myriad other problems, so they assume the worst
and apply all of their runtime protections. They cannot just take the
process' word that it is derived from a memory-safe source.  This also applies
to other memory safe languages that use implementations atop general-purpose
OSes, such as the CPython, and .NET.

Putting Rust aside for a moment, most memory-safe languages incur runtime costs
to ensure memory safety, such as forcing all objects through forced automatic
memory management i.e. garbage collection. They then must pay another cost
again, in the memory protection layer of the OS, to verify something _they have
already checked_.

Is it possible for a system to only run safe languages and remove the runtime
checks that are otherwise necessary? Even if it is possible, it the resulting
system desirable?

# Mandating Safe Languages to Eliminate Some OS and CPU Runtime Checks

We can assume that language-specific hardware will not take the computing world
by storm in the foreseeable future. Even very successful language runtimes such
as the Java Virtual Machine gave up trying to work on custom-built
hardware. The Java community's dream of CPUs with microcode that executed JVM
bytecode directly en masse didn't materialise.

How can general purpose OSes know that executables were written in memory-safe
source languages and safely take their word for it? A declaration that, pinky
promise, they won't accidentally (or otherwise) corrupt memory?

Allowing executables to self-declare their safety is clearly a security
nightmare; far too many C developers think they're the "special few" who can
write secure code, and it would allow adversaries to just put such declarations
in nefarious executables. Let's cross this approach off right away.

The approach of whitelisting "allowed" executables is clearly insecure too and
won't scale. How does the OS know whether an executable is "allowed"? Is being
cryptographically signed by a known developer, iOS app-style, enough to take
such declarations seriously? Of course not. If the OS only receives the native
code and nothing else, it is right to assume the worst and apply all runtime
memory protections.

What if an OS had a built-in set of compilers of known memory safe languages,
and compiled them on the fly, mandating the source language as the only form of
distributable executable the OS would "run"? This is essentially what AOT
compilation in .NET is doing: taking a memory-safe intermediate language and
compiling to machine-code ahead of time (putting aside .NET's support for opt-in
unsafe code).

The JIT or AOT compilation step is necessary because modern hardware is general
purpose and won't execute popular language bytecode formats natively. Blocking
_direct_ execution of compiled code is also necessary since the OS must run
sources itself through known-memory-safe language compilers or interpreters to
ensure memory corruption cannot occur in the resulting executables.

---

The problem more broadly is that the fewer constraints applied to
outside-controlled inputs such as executable code by third-party developers,
the fewer assumptions that can be made by the environment into which it is
loaded. When basic assumptions like memory safety cannot be made the
environment must compensate with runtime checks or risk compromise.

This is why designers of environments like language VMs or OSes must be careful
about relaxing constraints on the "apps" or "languages" running on top. Some
platform's like Apple's iOS has done respectable jobs of this.

---

How would this system even work? The compilers and interpreters would need to be
fixed and trusted; allowing arbitrary ones would allow compiling or interpreting
languages lacking memory safety, circumventing the protection. There would also
need to be environment primitives that can be written without such guarentees,
to allow bootstrapping the environment and providing the low-level building
blocks.

The user would download an "app", a bundle of language source files, and execute
it. The OS would then detect that it is a new "app" and compile it to machine
code, probably caching the results somewhere. That cache has to be internal to
the environment and not accessible by the user, as it is caching raw executables
which, if modified and then reexecuted, can bypass memory safety.

These compilers probably wouldn't be for high-level languages like Rust, but
could be. It seems more likely that languages would target memory-safe
intermediate languages formats like WebAssembly or JVM bytecode, for which a
compiler or interpreter would exist in the OS.

It could be argued that this approach violates the security-in-layers approach
of security engineering. If a bug were found in Rust's borrow checker that
allowed bypassing safe mode, it would be game over. (Let's assume a Rust
compiler in this environment would only load apps whose Rust sources banned
unsafe code and whitelisted standard libraries that had `unsafe`
implementations.) Perhaps the aforementioned runtime checks are still necessary
for that reason: the memory safety of the environment becomes the weakest link
of all memory-safe language compilers supported by the environment. Most
environments would probably keep their amount of compilers small and
auditable. Many might even opt for just one immediate language and support
no others.

---

Wait, have we just basically described a web browser executing WebAssembly,
the browser being implemented on the "bare metal" and bypassing existing OS
and CPU protections directly? I'm not the first one to realise this; Gary B**
made a "haha, only serious" comment about this regarding JavaScript in his
excellent "JavaScript takes over the World" talk [many years ago]().

# How Existing Notions of "Environment" and "Operating System" have Blurred Security Responsibilities

The overlap between language and OS security layers is an inevitable conflict
given that language runtimes and compilers seem to have constructs that are
suspiciously similar to various OS features. On one end of the scale you
superficial similarities like Rust's borrow checker trying to implement OS'
memory safety but statically at compile time rather than at runtime; on the
other end you have Erlang/OTP and Emacs which are effectively creating
whole new operating systems bar the hardware abstraction layer.

Sadly, a lot of these systems are not designed to be operating systems but are
treated as such by their users. Emacs is supposed to be a text editor but often
becomes the environment in which its users live, but it's poorly suited for that
role as its text editor origins means it doesn't contain even basic security
features that people expect of modern OSes like process isolation. A syntax
highlighting package can start intercepting password entry functions in
SSH-utilising packages like TRAMP.

Perhaps the computing industry as a whole needs to look at this overlap and have
an honest discussion about what layers should be providing security features
like isolation, and which ones are solely for evaluating already-trusted inputs.

It seems environments, operating systems, and language runtimes have intertangled
definitions and unclear responsibilities. I envisage a more clearly defined
layer as follows:-

## The Hardware

This one is self-explanatory. It's what realises our abstract programs, what
physically gets things done.

## The Hardware Abstraction Layer

Completely Subsuming hardware abstraction layers into the definition of
an operating system is unhelpful. An OS providers a HAL but also often provide
unrelated features like GUI toolkits; compacting these layers into one entity
doesn't help discussion of security responsibilities.

## The Environment

Rather than just calling this the "OS", let's clearly distinguish it from the
HAL. It's the set of building blocks of the environment in which the user will
work even if it's mostly hidden behind UIs. It's the filesystems, the process
management, the local user account management, the ACLs, and more. A Lisp
machine and a Linux box will have a very different set of abstractions, but they
serve the same purpose: a hardware-agnostic set of abstractions for a
computation environment.

This environment needs to provide clear, robust, and comprehensive security
mechanisms. User accounts should be isolated, the datastore of choice (primarily
the hierarchal filesystem on popular environments today) should have access
controls, and processes need to be isolatable. It can ask the HAL to use
the underlying hardware to provide a second layer of enforcement of these
constraints but it shouldn't _completely_ delgate to it.

If it is sufficiently confident in its security layers, it is possible to
disable the secondary runtime checks in the underlying platforms to gain a
performance boost at the expense of security-by-layers. Contrary to what many
security engineers claim, tradeoffs like this can be a perfectly reasonable.
Security engineering isn't about acheiving absolute security but is instead an
economic tradeoff between security the other aspects of a system.

Again, why should an environment pay twice for a security constraint it is
already sure it implements properly?

A bonus point about making a clear distinction by splitting the definition of an
operating system into the HAL and the environment is the clarification that
that such environments don't necessarily need a HAL as they can nest within
other environments, but that _the security mechanisms must still be enforced_.
As mentioned previously, Emacs and other similar current environments fail at
this.

## The User Interface

There isn't much to say about this except that the UI should not implement
security constraints but delegate to the environment, and should take care to
visualise and present these constraints in a way that is useful to the expected
user of the platform.

Provide security controls in a way that is easily digestable to the average user
is a topic out of scope for this post; needless to say, Linux is a prime
example of how _not_ to do this. iOS and Qubes OS are better examples.

# Rethinking Environment Layers and their Security Responsibilities

Rethinking the layers that make up an OS lays bare the ambiguities about which
layers should be handling what, and whether layers should be duplicating runtime
security checks from layers underneath.

Is the performance cost worth the benefits of security-in-layers, or is it an
unnecessary performance hit caused by environments not implementing security in
a sufficiently clear and robust way that they are willing to depend solely on it
and not delegate to lower levels?

Don't look at me, I have no idea. I've only just managed to formulate the
question, let alone one of the many right answers.

