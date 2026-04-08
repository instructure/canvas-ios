#!/usr/bin/env bash
# Usage: check-pr-description.sh
# Reads PR body from the PR_BODY environment variable.
# Outputs:
#   Line 1: pass | fail
#   Line 2+: human-readable error details
set -o pipefail

if [[ -z "${1:-}" ]]; then
    echo "fail"
    echo "- No PR body provided"
    exit 0
fi

body="$1"

if printf '%s' "$body" | grep -qi '\[ignore-pr-lint\]'; then
    echo "pass"
    exit 0
fi

errors=()

check_field() {
    local label="$1" pattern="$2" valid_values="$3"
    local line value

    line=$(printf '%s' "$body" | grep -i "^${pattern}:" | tail -1)
    if [[ -z "$line" ]]; then
        errors+=("Missing '${pattern}:' field")
        return
    fi

    value=$(printf '%s' "$line" | sed "s/^[^:]*:[[:space:]]*//" | sed 's/[[:space:]]*$//')
    if [[ -z "$value" ]]; then
        errors+=("'${pattern}:' field is empty")
        return
    fi

    [[ -z "$valid_values" ]] && return

    IFS=',' read -ra items <<< "$value"
    for item in "${items[@]}"; do
        item=$(printf '%s' "$item" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        item=$(printf '%s' "$item" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
        if ! printf '%s' "$valid_values" | grep -qw "$item"; then
            errors+=("Invalid value '$item' in '${pattern}:'. Valid: $valid_values")
        fi
    done
}

check_field "Release note"  "release note"  ""
check_field "Affects"       "affects"       "Student Teacher Parent None"
check_field "Builds"        "builds"        "Student Teacher Parent All None"
check_field "Refs"          "refs"          ""

if [[ ${#errors[@]} -eq 0 ]]; then
    echo "pass"
else
    echo "fail"
    for err in "${errors[@]}"; do
        echo "- $err"
    done
    echo ""
    echo "Add [ignore-pr-lint] to the PR description to skip these checks."
fi
