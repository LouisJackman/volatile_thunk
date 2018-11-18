#!/usr/bin/env python3

import subprocess
import re
from datetime import datetime
from os import environ
from shutil import which
from textwrap import dedent
from typing import Optional, Set
from pathlib import Path


def title_to_path_component(title: str) -> str:
    without_spaces = re.sub(r'\s+', '-', title.lower())
    return re.sub(r'[^\w-]', '', without_spaces)


def make_path(title: str, year: int, month: int, day: int) -> Path:
    title_component = title_to_path_component(title)

    return (
        Path('content')
        / 'posts'
        / f'{year:04}'
        / f'{month:02}'
        / f'{day:02}'
        / title_component
        / 'post.md'
    )


def make_post_file(title: str, tags: Set[str]) -> Path:
    now = datetime.now()
    year, month, day = now.year, now.month, now.day
    hour, minute = now.hour, now.minute

    path = make_path(title, year, month, day)
    tags_field = ', '.join(tags)

    header = dedent(f'''
        Title: {title}
        Date: {year:04}-{month:02}-{day:02} {hour:02}:{minute:02}
        Tags: {tags_field}


    ''').lstrip()

    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w') as post:
        post.write(header)

    return path


def get_editor() -> Optional[str]:
    result: Optional[str]
    if 'VISUAL' in environ:
        result = environ['VISUAL']
    elif 'EDITOR' in environ:
        result = environ['EDITOR']
    elif which('vi') is not None:
        result = 'vi'
    else:
        result = None
    return result


def edit(path: Path) -> None:
    editor = get_editor()
    if editor is not None:
        subprocess.check_call([
            editor,
            str(path)
        ])


def main():
    title = input("The post's title: ")
    raw_tags = input("The post's tags (seperate with commas): ")
    tags = {tag.lower().strip() for tag in raw_tags.split(',')}

    post_file = make_post_file(title, tags)
    edit(post_file)


if __name__ == '__main__':
    main()

