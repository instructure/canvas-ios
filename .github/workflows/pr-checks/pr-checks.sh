#!/usr/bin/env bash
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
COVERAGE_CONFIG="$SCRIPT_DIR/coverage-config.json"
RESULT_BUNDLE="$REPO_ROOT/scripts/coverage/citests.xcresult"

WORKSPACE="Canvas.xcworkspace"
SCHEME="CITests"
SIM_ID=$(xcrun simctl list devices available | grep -E "^\s+iPhone" | grep -oE '[A-F0-9-]{36}' | tail -1)
echo "Using simulator: $(xcrun simctl list devices available | grep "$SIM_ID" | xargs)"
DESTINATION="platform=iOS Simulator,id=$SIM_ID"

WORK_DIR=$(mktemp -d)

# ── Dependency check ──────────────────────────────────────────────────────────
missing_deps=()
for dep in swiftlint xcbeautify jq xcrun; do
    command -v "$dep" &>/dev/null || missing_deps+=("$dep")
done

if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo "❌ Missing dependencies: ${missing_deps[*]}"
    echo "   Install with: brew install ${missing_deps[*]}"
    exit 1
fi

# ── Step state ────────────────────────────────────────────────────────────────
LINT_STATUS="" LINT_DETAILS=""
BUILD_STATUS="" BUILD_DETAILS=""
TEST_STATUS="" TEST_DETAILS=""
COV_STATUS="" COV_DETAILS=""
OVERALL_PASS=true

# ── Step 1: SwiftLint ─────────────────────────────────────────────────────────
lint_out="$WORK_DIR/lint.txt"
echo "Running SwiftLint... ($lint_out)"
if (cd "$REPO_ROOT" && bash scripts/runSwiftLint.sh >"$lint_out" 2>&1); then
    LINT_STATUS="✅ Passed"
else
    LINT_STATUS="❌ Failed"
    OVERALL_PASS=false
    LINT_DETAILS=$(grep -v "^LINTING\|^Linting" "$lint_out" | sed '/^[[:space:]]*$/d' | sed "s|${REPO_ROOT}/||g")
fi

# ── Step 2: Build CITests ─────────────────────────────────────────────────────
build_out="$WORK_DIR/build.txt"
echo "Building CITests... ($build_out)"
if (cd "$REPO_ROOT" && xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -sdk iphonesimulator \
        -configuration Debug \
        -destination "$DESTINATION" \
        COMPILER_INDEX_STORE_ENABLE=NO \
        build-for-testing 2>&1 | xcbeautify --quiet >"$build_out" 2>&1); then
    BUILD_STATUS="✅ Passed"
else
    BUILD_STATUS="❌ Failed"
    OVERALL_PASS=false
    BUILD_DETAILS=$(grep " error:" "$build_out" | head -50 || true)
    TEST_STATUS="⏭️ Skipped"
    COV_STATUS="⏭️ Skipped"
fi

# ── Step 3: Unit Tests ────────────────────────────────────────────────────────
if [[ -z "$TEST_STATUS" ]]; then
    test_out="$WORK_DIR/tests.txt"
    echo "Running unit tests... ($test_out)"
    rm -rf "$RESULT_BUNDLE"
    mkdir -p "$(dirname "$RESULT_BUNDLE")"
    if (cd "$REPO_ROOT" && xcodebuild \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -destination "$DESTINATION" \
            -resultBundlePath "$RESULT_BUNDLE" \
            test-without-building 2>&1 | xcbeautify >"$test_out" 2>&1); then
        TEST_STATUS="✅ Passed"
    else
        TEST_STATUS="❌ Failed"
        OVERALL_PASS=false
        TEST_DETAILS=$(awk '
            /Test Suite .* started/ { s = $0; gsub(/.*Test Suite ./, "", s); gsub(/. started.*/, "", s); suite = s }
            /✖|Test Case .* failed/ { if (suite != "") print suite; print; suite = "" }
        ' "$test_out" | head -200 || true)
    fi
fi

# ── Step 4: Code Coverage ─────────────────────────────────────────────────────
if [[ -z "$COV_STATUS" ]]; then
    echo "Checking code coverage..."
    cov_output=$(bash "$SCRIPT_DIR/check-coverage.sh" "$RESULT_BUNDLE")
    cov_result=$(echo "$cov_output" | head -1)
    COV_DETAILS=$(echo "$cov_output" | tail -n +2)

    case "$cov_result" in
        pass)  COV_STATUS="✅ Passed" ;;
        fail)  COV_STATUS="❌ Failed"; OVERALL_PASS=false ;;
        *)     COV_STATUS="❌ Failed"; OVERALL_PASS=false ;;
    esac
fi

# ── Build report ──────────────────────────────────────────────────────────────
make_icon() {
    local status="$1"
    case "$status" in
        *✅*) printf '✅' ;;
        *❌*) printf '❌' ;;
        *)    printf '⏭️' ;;
    esac
}

make_name() {
    local name="$1" details="$2"
    if [[ -n "$details" ]]; then
        local escaped
        escaped=$(printf '%s' "$details" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
        printf '<details><summary>%s</summary><pre>%s</pre></details>' "$name" "$escaped"
    else
        printf '%s' "$name"
    fi
}

REPORT="<!-- ci-check-results -->
## PR Checks

<table>
<tr><th></th><th>Step</th></tr>
<tr><td>$(make_icon "$LINT_STATUS")</td><td>$(make_name "SwiftLint" "$LINT_DETAILS")</td></tr>
<tr><td>$(make_icon "$BUILD_STATUS")</td><td>$(make_name "Build CITests" "$BUILD_DETAILS")</td></tr>
<tr><td>$(make_icon "$TEST_STATUS")</td><td>$(make_name "Unit Tests" "$TEST_DETAILS")</td></tr>
<tr><td>$(make_icon "$COV_STATUS")</td><td>$(make_name "Code Coverage" "$COV_DETAILS")</td></tr>
</table>"

# ── Output ────────────────────────────────────────────────────────────────────
echo "$REPORT" > ci-report.md
cat ci-report.md

[[ "$OVERALL_PASS" == true ]]
