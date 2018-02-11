# Volatile Thunk - Louis Jackman's Blog

## Posts

Posts are put in `content`, under the subdirectory `$Y/$M/$D/$SLUGLINE`, where:

* $Y = Year
* $M = Month
* $D = Day
* $SLUGLINE = The article's title, snake cased.

They are written in Markdown, and have metadata at the start, like the
following example on Pelican's website:

```
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

## Deploy

The blog can be generated with `pelican content -o output -s publishconf.py`.

The `ghp-import` command is used to manage the generated output's branch.

After running that, two branches exist on the local host:

* master: The source code of the blog.
* gh-pages: The generated output.

To honour Github's conventions for GitHub Pages, we remap the branches like this
on pushes:

* master -> source
* gh-pages -> master
