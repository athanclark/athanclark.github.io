#!/bin/bash

echo "Checking quality of shell scripts..."

shellcheck -S error ./*.sh

echo "Checking for broken links..."

linkchecker -f .linkcheckerrc docs/
