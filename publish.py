#!/usr/bin/env python3

import re
import subprocess
from pathlib import Path
from sys import exit
from typing import NamedTuple, Optional, List


def git(*cmd_args, **kwargs) -> None:
    subprocess.check_call(["git", *cmd_args], **kwargs)


def confirm(message: str) -> bool:
    confirmation = input(f"{message} (y/n): ")
    return confirmation.lower().strip() == "y"


def review(article_path: Path) -> None:
    git("add", str(article_path))

    satisfied = False
    while not satisfied:
        git("diff", "--staged")
        satisfied = confirm("Do you want to commit that?")


def latest_of(directory: Path) -> Optional[Path]:
    numbered = list(directory.iterdir())

    if len(numbered) <= 0:
        result = None
    else:
        latest = sorted([int(node.name) for node in numbered])[-1]

        latest_name = f"{latest:02}"
        result = directory / latest_name

    return result


class ArticleDate(NamedTuple):
    year: int
    month: int
    day: int


def find_latest() -> Optional[ArticleDate]:
    year = latest_of(Path("content") / "posts")
    if year is None:
        result = None
    else:
        month = latest_of(year)
        if month is None:
            result = None
        else:
            day = latest_of(month)
            if day is None:
                result = None
            else:
                result = ArticleDate(int(year.name), int(month.name), int(day.name))
    return result


class ArticleTime(NamedTuple):
    hour: int
    minute: int


class NoSuchFieldToExtractError(RuntimeError):
    def __init__(self, field_name: str) -> None:
        super().__init__(f"no such field found: {field_name}")


def extract_field(article_path: Path, field_name: str) -> str:
    with article_path.open() as article:
        escaped_name = re.escape(field_name)
        pattern = fr"^\s*{escaped_name}\s*:\s*(.*?)\s*$"
        for line in article:
            match = re.match(pattern, line, re.IGNORECASE)
            if match is not None:
                result = match.group(1)
                break
        else:
            raise NoSuchFieldToExtractError(field_name)

    return result


def extract_article_time(article_path: Path) -> ArticleTime:
    field = extract_field(article_path, "Date")
    hour, minute = field.split()[1].split(":")
    return ArticleTime(hour=int(hour), minute=int(minute))


def extract_article_title(article_path: Path) -> str:
    return extract_field(article_path, "Title")


class NoMatchingArticleFoundError(RuntimeError):
    def __init__(self) -> None:
        super().__init__("No matching article found.")


def find_article_path() -> Path:
    latest = find_latest()
    if latest is None:
        raise NoMatchingArticleFoundError()
    year, month, day = latest.year, latest.month, latest.day

    base_path = Path("content") / "posts" / f"{year:04}" / f"{month:02}" / f"{day:02}"

    paths = [
        base_path / article_directory.name / "post.md"
        for article_directory in base_path.iterdir()
    ]

    if len(paths) <= 0:
        raise NoMatchingArticleFoundError()

    paths_with_times = sorted([(extract_article_time(path), path) for path in paths])

    _, path = paths_with_times[-1]
    return path


def commit(article_path: Path) -> None:
    title = extract_article_title(article_path)
    commit_message = f'Publish "{title}"'
    git("commit", "-m", commit_message)


def publish() -> None:
    git("show", "HEAD")
    if confirm("Do you want to push that?"):
        git("push")
    else:
        print("When you're ready to publish, run 'git push'.")


def main() -> None:
    try:
        article_path = find_article_path()

        review(article_path)
        commit(article_path)
        publish()
    except (NoSuchFieldToExtractError, NoMatchingArticleFoundError) as error:
        print(f"An error occured: {error}")
        exit(-1)


if __name__ == "__main__":
    main()
