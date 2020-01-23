# This file is only used if you use `make publish` or
# explicitly specify it as your config file.

from pathlib import Path
import sys
from typing import Optional

sys.path.append(str(Path.cwd()))
from pelicanconf import *


PLUGINS.append("minify")

RELATIVE_URLS = False

FEED_ALL_ATOM: Optional[str] = "feeds/all.atom.xml"
CATEGORY_FEED_ATOM: Optional[str] = "feeds/{slug}.atom.xml"

DELETE_OUTPUT_DIRECTORY = True
