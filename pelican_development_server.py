#!/usr/bin/env python3


from http.server import HTTPServer, SimpleHTTPRequestHandler
from os import chdir
from subprocess import PIPE, Popen


def main():
    with Popen(
        [
            "pelican",
            "--delete-output-directory",
            "--autoreload",
            "--ignore-cache",
            "--verbose",
            "-s", "pelican_development_configuration.py",
        ],
        stdout=PIPE,
    ):
        chdir("output")
        server = HTTPServer(
            ("127.0.0.1", 8000),
            SimpleHTTPRequestHandler,
        )
        server.serve_forever()


main()
