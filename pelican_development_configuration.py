import pathlib

exec(
    open(
        "pelican_base_configuration.py",
    ).read(),
)

SITEURL = (pathlib.Path(".").absolute() / "output").as_uri()
FEED_DOMAIN = SITEURL
RELATIVE_URLS = True
