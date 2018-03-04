"""
Pelican generates summaries with its `utils.truncate_html_words`, which
hardcodes an elipsis to the end of the article summary.

As it is appended directly to the text node of the DOM output, it cannot easily
be styled. I wanted the elipsis to be greyed out and surrounded with square
brackets to make it clear there is more content if the post is followed.

This plugin monkeypatches the `contents.Content.get_summary` method to allow
arbritary HTML suffixes to be applied to summaries by specifying
`SUMMARY_SUFFIX` in a blog's settings.
"""

import functools
import re
from typing import Any, Callable

import pelican.contents
from pelican import Pelican, signals


def _get_suffix_replacement(settings) -> str:
    return settings['SUMMARY_SUFFIX']


_DEFAULT_SUFFIX = '…'

_TEXT_LESS_CLOSING_TAGS_REGEXP = re.compile(
    fr'''
        {re.escape(_DEFAULT_SUFFIX)}
        (
            (?:
                \s*<
                \s*/
                \s*\w+
                >
            )+
        )
        $
    ''',
    (re.X | re.S))


def _replace_suffix(content: str, replacement: str) -> str:

    def replace(match):
        return f'{replacement}{match.group(1)}'

    return re.sub(_TEXT_LESS_CLOSING_TAGS_REGEXP, replace, content)


_SummaryGetter = Callable[..., Any]


def _patch_summary_getter(
        replacement: str,
        previous_getter: _SummaryGetter) -> _SummaryGetter:

    @functools.wraps(previous_getter)
    def patch(*args):
        result = previous_getter(*args)
        return _replace_suffix(result, replacement)

    return patch


def _initialize(instance: Pelican) -> None:
    previous_get_summary = pelican.contents.Content.__dict__['get_summary']
    suffix_replacement = _get_suffix_replacement(instance.settings)

    new_get_summary = _patch_summary_getter(
        suffix_replacement,
        previous_get_summary)

    pelican.contents.Content.get_summary = new_get_summary


def register() -> None:
    signals.initialized.connect(_initialize)
