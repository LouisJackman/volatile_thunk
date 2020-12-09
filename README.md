# Volatile Thunk - Louis Jackman's Site

[![pipeline status](https://gitlab.com/louis.jackman/volatile-thunk/badges/master/pipeline.svg)](https://gitlab.com/louis.jackman/volatile-thunk/-/commits/master)

My website, using static page generation via [Hugo](https://gohugo.io/).

This repository is currently hosted [on
GitLab.com](https://gitlab.com/louis.jackman/volatile-thunk). Official mirrors
exist on [SourceHut](https://git.sr.ht/~louisjackman/volatile-thunk) and
[GitHub](https://github.com/LouisJackman/volatile-thunk). At the moment, GitLab
is still the official hub for contributions such as PRs and issues.

## Posts

Posts are put in `content/posts`, under the subdirectory `$Y/$M/$D/$SLUGLINE`,
where:

* `$Y`: Year
* `$M`: Month
* `$D`: Day
* `$SLUGLINE`: The article's title, snake-cased.

They are written in Markdown, and have TOML metadata at the start like this:

```markdown
+++
title = "My super title"
date = "2010-12-03"
tags = ["pelican", "publishing"]
+++

This is the content of my super blog post.
```

## Pages

Pages are put in `content` under `pages`. Their names are their titles,
snake-cased. They automatically appear on the main navigation menu. They are
otherwise like posts.

## Setup

Git cloning must be recursive as submodules are used for the default theme,
hermit:

```shell
git clone --recursive https://github.com/LouisJackman/volatile-thunk.git
```

## Publish

The blog can be generated with `make publish`.

The `s3_upload` make target publishes to AWS S3.

