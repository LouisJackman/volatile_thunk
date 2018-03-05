AUTHOR = 'Louis Jackman'
SITENAME = 'Volatile Thunk'
SITESUBTITLE = "Louis Jackman's Blog"
SITEURL = 'https://volatilethunk.com'
ARTICLE_URL = 'articles/{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html'
ARTICLE_SAVE_AS = 'articles/{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html'

PATH = 'content'

TIMEZONE = 'Europe/London'

DEFAULT_LANG = 'en'

SUMMARY_SUFFIX = '<span class="summary-suffix">[…]</span>'

PLUGIN_PATHS = ["plugins"]
PLUGINS = ["summary_suffix_replacer"]


# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

SUMMARY_MAX_LENGTH = 100

# Uncomment following line if you want document-relative URLs when developing
RELATIVE_URLS = True

MENUITEMS = [
    ('Blog', '/'),
    ('Projects', 'https://github.com/LouisJackman?tab=repositories'),
    ('Archives', '/archives.html')]

GITHUB_URL = 'https://github.com/LouisJackman'

# Social widget
SOCIAL = [
    ('Stack Exchange', 'https://stackexchange.com/users/2032836/ljackman')]

#DISPLAY_PAGES_ON_MENU = True

DEFAULT_PAGINATION = 10
DISPLAY_CATEGORIES_ON_MENU = False
THEME = 'themes/default'
TYPOGRIFY = True
