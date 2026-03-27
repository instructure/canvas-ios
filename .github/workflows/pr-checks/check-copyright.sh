#!/usr/bin/env bash
# Usage: check-copyright.sh
# Outputs two lines to stdout:
#   Line 1: pass | fail
#   Line 2+: human-readable details
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

missing_files=()

while IFS= read -r file; do
    abs="$REPO_ROOT/$file"
    [[ -f "$abs" ]] || continue

    case "$file" in
        .github/*) continue ;;
        *.framework/Headers/*) continue ;;
        *.framework/Versions/*) continue ;;
        */node_modules/*) continue ;;
        */jquery/*) continue ;;
        */preact/*) continue ;;
        */preact.*) continue ;;
        */templates/*) continue ;;
    esac

    header=$(head -20 "$abs" | tr '[:upper:]' '[:lower:]')
    if ! printf '%s' "$header" | grep -q "copyright" || \
       ! printf '%s' "$header" | grep -q "instructure"; then
        missing_files+=("$file")
    fi
done < <(cd "$REPO_ROOT" && git ls-files '*.swift' '*.h' '*.m' '*.js' '*.sh')

if [[ ${#missing_files[@]} -eq 0 ]]; then
    echo "pass"
else
    echo "fail"
    printf '%s\n' "${missing_files[@]}"
fi
