# This file is only used if you use `make publish` or
# explicitly specify it as your config file.

import sys
from pathlib import Path

sys.path.append(str(Path.cwd()))
from pelicanconf import *


PLUGINS.append('minify')

RELATIVE_URLS = False

FEED_ALL_ATOM = 'feeds/all.atom.xml'
CATEGORY_FEED_ATOM = 'feeds/%s.atom.xml'

DELETE_OUTPUT_DIRECTORY = True
