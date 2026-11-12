#!/usr/bin/env bash
# Checks the build scripts and the generated site in docs/ (run ./build.sh first).
set -euo pipefail

echo "Checking quality of shell scripts..."
shellcheck -S warning ./*.sh

echo "Checking that generated XML is well-formed..."
for xml in docs/feed.xml docs/sitemap.xml; do
    python3 -c 'import sys, xml.dom.minidom; xml.dom.minidom.parse(sys.argv[1])' "$xml"
done

echo "Checking for broken links..."
linkchecker -f .linkcheckerrc docs/
