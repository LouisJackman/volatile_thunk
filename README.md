# Volatile Thunk - Louis Jackman's Blog

[![Known Vulnerabilities](https://snyk.io/test/github/LouisJackman/volatile_thunk/badge.svg?targetFile=requirements.txt)](https://snyk.io/test/github/LouisJackman/volatile_thunk?targetFile=requirements.txt)

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
not on PyPi.

`pip3 install --user` should be enough to install all required dependencies.

## Publish

The blog can be generated with `pelican -s publishconf.py`.

The `s3_upload` make task publishes to AWS S3.
