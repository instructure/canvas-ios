#!/usr/bin/env bash
# Usage: check-copyright.sh
# Outputs two lines to stdout:
#   Line 1: pass | fail
#   Line 2+: files missing Instructure copyright header
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

missing_files=$(
    cd "$REPO_ROOT" && \
    git ls-files -z '*.swift' '*.h' '*.m' '*.js' '*.sh' | \
    grep -z -v -E '^\.github/|\.framework/(Headers|Versions)/|/node_modules/|/jquery/|/preact[./]|/templates/' | \
    xargs -0 awk '
        FNR == 1 {
            if (NR > 1 && (!c || !i)) print prev
            c = 0; i = 0; prev = FILENAME
        }
        FNR <= 20 {
            t = tolower($0)
            if (!c && t ~ /copyright/) c = 1
            if (!i && t ~ /instructure/) i = 1
        }
        FNR == 20 { nextfile }
        END { if (prev != "" && (!c || !i)) print prev }
    '
)

if [[ -z "$missing_files" ]]; then
    echo "pass"
else
    echo "fail"
    echo "$missing_files"
fi
