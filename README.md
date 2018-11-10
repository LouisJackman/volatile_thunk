# Volatile Thunk - Louis Jackman's Blog

[![Known Vulnerabilities](https://snyk.io/test/github/LouisJackman/volatile_thunk/badge.svg)](https://snyk.io/test/github/LouisJackman/volatile_thunk)


## Synopsis

My website, using static page generation via Python 3.6 onwards and Pelican.

Python 2 is not tested, and one of the pelican plugins in use only works on
Python 3.

## Posts

Posts are put in `content`, under the subdirectory `$Y/$M/$D/$SLUGLINE`, where:

* $Y = Year
* $M = Month
* $D = Day
* $SLUGLINE = The article's title, snake cased.

They are written in Markdown, and have metadata at the start, like the
following example on Pelican's website:

```markdown
Title: My super title
Date: 2010-12-03 10:20
Modified: 2010-12-05 19:30
Category: Python
Tags: pelican, publishing
Slug: my-super-post
Authors: Alexis Metaireau, Conan Doyle
Summary: Short version for index and feeds

This is the content of my super blog post.
```

Although Pelican supports categories like above, all Volatile Thunk content
should only need tags for the foreseeable future.

## Pages

Pages are put in `content`, under `pages`. Their name is their title snake
cased. They automatically appear on the main navigation menu. They are otherwise
like posts.

## Setup

Git cloning must be recursive, as submodules are used for some plugins that are
not on PyPi:
```shell
git clone --recursive https://github.com/LouisJackman/volatile_thunk.git
```

A virtualenv should be setup like this, which is a one-off operation:
```shell
python3 -m venv .venv
```

When working on Volatile Thunk, be sure to enter the virtualenv and leave when
you're done:
```shell
source .venv/bin/activate

# [...]

deactivate
```

When inside the virtualenv, install the required packages:
```shell
pip3 install -r requirements.txt
```

## Publish

The blog can be generated with `pelican -s publishconf.py`.

The `s3_upload` make task publishes to AWS S3.
