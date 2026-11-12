#!/usr/bin/env bash
# Serve the built site at http://localhost:8080
set -euo pipefail
if command -v static-web-server > /dev/null; then
    exec static-web-server -d ./docs/ -p 8080
else
    exec python3 -m http.server 8080 --directory ./docs/
fi
