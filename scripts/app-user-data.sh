#!/bin/bash

set -e

dnf update -y
dnf install -y python3

mkdir -p /opt/app

cat > /opt/app/server.py <<'PYTHON'
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"healthy")
            return

        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(b"AWS Production Platform")

    def log_message(self, format, *args):
        return


server = HTTPServer(("0.0.0.0", 8080), Handler)
server.serve_forever()
PYTHON

nohup python3 /opt/app/server.py > /var/log/app.log 2>&1 &