#!/usr/bin/env bash
# Usage: check-coverage.sh <path-to.xcresult>
# Outputs two lines to stdout:
#   Line 1: pass | fail | error
#   Line 2: human-readable details
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
COVERAGE_CONFIG="$SCRIPT_DIR/coverage-config.json"
RESULT_BUNDLE="${1:-}"

if [[ -z "$RESULT_BUNDLE" ]]; then
    echo "error"
    echo "Usage: check-coverage.sh <path-to.xcresult>"
    exit 1
fi

WORK_DIR=$(mktemp -d)

cov_json="$SCRIPT_DIR/coverage.json"
echo "Parsing coverage report... ($cov_json)" >&2
if ! xcrun xccov view --report --json "$RESULT_BUNDLE" >"$cov_json" 2>/dev/null; then
    echo "error"
    echo "Could not parse coverage report from $RESULT_BUNDLE"
    rm -rf "$WORK_DIR"
    exit 1
fi

file_min=$(jq '.fileMinCoverage' "$COVERAGE_CONFIG")
total_min=$(jq '.totalMinCoverage' "$COVERAGE_CONFIG")
file_min_pct=$(awk "BEGIN { printf \"%.0f%%\", $file_min * 100 }")
total_min_pct=$(awk "BEGIN { printf \"%.0f%%\", $total_min * 100 }")

combined_path_pattern=$(jq -r '.ignorePatterns[]' "$COVERAGE_CONFIG" | paste -sd '|' -)
content_pattern_file="$WORK_DIR/ignore_content.txt"
jq -r '.ignoreContent[]' "$COVERAGE_CONFIG" > "$content_pattern_file"

under_files=()
total_covered=0
total_executable=0

while IFS=$'\t' read -r file_path covered executable line_cov; do
    [[ "$executable" -eq 0 ]] && continue

    echo "$file_path" | grep -qE -- "$combined_path_pattern" && continue

    [[ -f "$file_path" ]] && grep -qF -f "$content_pattern_file" -- "$file_path" && continue

    total_covered=$((total_covered + covered))
    total_executable=$((total_executable + executable))

    if awk "BEGIN { exit ($line_cov < $file_min) ? 0 : 1 }"; then
        pct=$(awk "BEGIN { printf \"%.1f%%\", $line_cov * 100 }")
        under_files+=("$pct  ${file_path#"$REPO_ROOT/"}")
    fi
done < <(jq -r '.targets[].files[] | [.path, .coveredLines, .executableLines, .lineCoverage] | @tsv' "$cov_json")

rm -rf "$WORK_DIR"

if [[ "$total_executable" -gt 0 ]]; then
    overall=$(awk "BEGIN { printf \"%.4f\", $total_covered / $total_executable }")
else
    overall=0
fi
overall_pct=$(awk "BEGIN { printf \"%.1f%%\", $overall * 100 }")

if [[ ${#under_files[@]} -eq 0 ]] && awk "BEGIN { exit ($overall >= $total_min) ? 0 : 1 }"; then
    echo "pass"
    echo "Overall coverage: $overall_pct"
else
    echo "fail"
    detail="Overall coverage: $overall_pct (minimum: $total_min_pct)"
    if [[ ${#under_files[@]} -gt 0 ]]; then
        detail+=$'\nFiles below '"$file_min_pct"$' threshold:\n'
        for entry in "${under_files[@]}"; do
            detail+="- $entry"$'\n'
        done
    fi
    echo "$detail"
fi
