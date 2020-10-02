# Volatile Thunk - Louis Jackman's Site

[![pipeline status](https://gitlab.com/louis.jackman/volatile_thunk/badges/master/pipeline.svg)](https://gitlab.com/louis.jackman/volatile_thunk/-/commits/master)

My website, using static page generation via Hugo.

This repository is hosted [on
GitLab.com](https://gitlab.com/louis.jackman/volatile_thunk). If you're
seeing this on GitHub, you're on the official GitHub mirror. [Go to
GitLab](https://gitlab.com/louis.jackman/volatile_thunk) to contribute.

## Posts

Posts are put in `content`, under the subdirectory `$Y/$M/$D/$SLUGLINE`, where:

* $Y = Year
* $M = Month
* $D = Day
* $SLUGLINE = The article's title, snake cased.

They are written in Markdown, and have metadata at the start like this:

```markdown
+++
title = "My super title"
date = "2010-12-03"
tags = ["pelican", "publishing"]
+++

This is the content of my super blog post.
```

## Pages

Pages are put in `content` under `pages`. Their names are their titles snake
cased. They automatically appear on the main navigation menu. They are otherwise
like posts.

## Setup

Git cloning must be recursive as submodules are used for the default theme,
hermit:
```shell
git clone --recursive https://github.com/LouisJackman/volatile_thunk.git
```

## Publish

The blog can be generated with `make publish`.

The `s3_upload` make target publishes to AWS S3.

