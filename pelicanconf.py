AUTHOR = 'Louis Jackman'
SITENAME = 'Volatile Thunk'
SITESUBTITLE = "Louis Jackman's Website"
SITEURL = 'https://volatilethunk.com'
ARTICLE_URL = 'articles/{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html'
ARTICLE_SAVE_AS = 'articles/{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html'

SITE_DESCRIPTION = "Louis Jackman's website about information security, software development, and system administration."

SITE_KEYWORDS = [
    'Louis Jackman',
    'blog',
    'articles',
    'infosec',
    'backend development',
    'sysadmin',
    'system administration'
]

PATH = 'content'

TIMEZONE = 'Europe/London'

DEFAULT_LANG = 'en'

SUMMARY_HTML_SUFFIX = '<span class="summary-suffix">[…]</span>'

INDEX_SAVE_AS = 'articles.html'

PLUGIN_PATHS = [
    'plugins/github.com/LouisJackman/pelican_summary_suffix_replacer',
    'plugins/github.com/whiskyechobravo/pelican-open_graph'
]

PLUGINS = [
    'extended_sitemap',
    'open_graph',
    'summary_suffix_replacer'
]

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

SUMMARY_MAX_LENGTH = 125

# Uncomment following line if you want document-relative URLs when developing
RELATIVE_URLS = True

MENUITEMS = [
    ('Articles', '/articles.html'),
    ('About', '/pages/about.html'),
    ('Projects', 'https://github.com/LouisJackman'),
    ('Contact', '/pages/contact.html')
]

SITEMAP = {
    'format': 'xml',
    'priorities': {
        'articles': 1,
        'indexes': 0.5,
        'pages': 0.5,
    },
    'changefreqs': {
        'articles': 'always',
        'indexes': 'hourly',
        'pages': 'monthly'
    }
}

STATIC_PATHS = [
    '.well-known/keybase.txt',
    'cv',
    'images',
    'robots.txt',
]

EXTRA_PATH_METADATA = {
    'robots.txt': {'path': 'robots.txt'},
    '.well-known/keybase.txt': {'path': '.well-known/keybase.txt'},
}

GITHUB_URL = 'https://github.com/LouisJackman'

# Social widget
SOCIAL = [
    ('Stack Exchange', 'https://stackexchange.com/users/2032836/ljackman')
]

DISPLAY_PAGES_ON_MENU = False

DEFAULT_PAGINATION = 10
DISPLAY_CATEGORIES_ON_MENU = False
THEME = 'themes/default'
TYPOGRIFY = True
