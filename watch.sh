#!/usr/bin/env bash
# Rebuild whenever sources change.
set -euo pipefail
exec watchexec -w pages -w template -w styles -w scripts -w images -w build.sh ./build.sh
