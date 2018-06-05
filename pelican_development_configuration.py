import pathlib

from pelican_base_configuration import (
    PATH,
    TIMEZONE,
)

SITEURL = (pathlib.Path(".").absolute() / "output").as_uri()
FEED_DOMAIN = SITEURL
RELATIVE_URLS = True
