#!/usr/bin/env bash
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
COVERAGE_CONFIG="$SCRIPT_DIR/coverage-config.json"
RESULT_BUNDLE="$REPO_ROOT/scripts/coverage/citests.xcresult"

WORKSPACE="Canvas.xcworkspace"
SCHEME="CITests"
SIM_ID=$(xcrun simctl list devices available -j | jq -r '[.devices | to_entries[] | select(.key | startswith("com.apple.CoreSimulator.SimRuntime.iOS")) | .value[] | select(.name | startswith("iPhone")) | .udid] | last')
SIM_NAME=$(xcrun simctl list devices available -j | jq -r '[.devices | to_entries[] | select(.key | startswith("com.apple.CoreSimulator.SimRuntime.iOS")) | .value[] | select(.name | startswith("iPhone")) | .name] | last')
echo "Using simulator: $SIM_NAME ($SIM_ID)"
BUILD_DESTINATION="generic/platform=iOS Simulator"
TEST_DESTINATION="platform=iOS Simulator,id=$SIM_ID"

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
PR_DESC_STATUS="" PR_DESC_DETAILS=""
COPYRIGHT_STATUS="" COPYRIGHT_DETAILS=""
LINT_STATUS="" LINT_DETAILS=""
BUILD_STATUS="" BUILD_DETAILS=""
TEST_STATUS="" TEST_DETAILS=""
COV_STATUS="" COV_DETAILS=""
OVERALL_PASS=true

# ── Step 1: PR description ────────────────────────────────────────────────────
echo "Checking PR description..."
pr_desc_output=$(bash "$SCRIPT_DIR/check-pr-description.sh" "${PR_BODY:-}")
if [[ "$(echo "$pr_desc_output" | head -1)" == "pass" ]]; then
    PR_DESC_STATUS="✅ Passed"
else
    PR_DESC_STATUS="❌ Failed"
    OVERALL_PASS=false
    PR_DESC_DETAILS=$(echo "$pr_desc_output" | tail -n +2)
fi

# ── Step 3: Copyright headers ─────────────────────────────────────────────────
echo "Checking copyright headers..."
copyright_output=$(bash "$SCRIPT_DIR/check-copyright.sh")
copyright_result=$(echo "$copyright_output" | head -1)
if [[ "$copyright_result" == "pass" ]]; then
    COPYRIGHT_STATUS="✅ Passed"
else
    COPYRIGHT_STATUS="❌ Failed"
    OVERALL_PASS=false
    COPYRIGHT_DETAILS=$(echo "$copyright_output" | tail -n +2)
fi

# ── Step 3: SwiftLint ─────────────────────────────────────────────────────────
lint_out="$WORK_DIR/lint.txt"
echo "Running SwiftLint... ($lint_out)"
if (cd "$REPO_ROOT" && bash scripts/runSwiftLint.sh >"$lint_out" 2>&1); then
    LINT_STATUS="✅ Passed"
else
    LINT_STATUS="❌ Failed"
    OVERALL_PASS=false
    LINT_DETAILS=$(grep -v "^LINTING\|^Linting" "$lint_out" | sed '/^[[:space:]]*$/d' | sed "s|${REPO_ROOT}/||g")
fi

# ── Step 4: Build CITests ─────────────────────────────────────────────────────
build_out="$WORK_DIR/build.txt"
build_raw="$WORK_DIR/build_raw.txt"
echo "Building CITests... ($build_out)"
if (cd "$REPO_ROOT" && xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -configuration Debug \
        -destination "$BUILD_DESTINATION" \
        COMPILER_INDEX_STORE_ENABLE=NO \
        build-for-testing 2>&1 | tee "$build_raw" | xcbeautify --quiet >"$build_out" 2>&1); then
    BUILD_STATUS="✅ Passed"
else
    BUILD_STATUS="❌ Failed"
    OVERALL_PASS=false
    BUILD_DETAILS=$(grep -A 20 "error:" "$build_raw" | head -40 || cat "$build_raw" | tail -50)
    TEST_STATUS="⏭️ Skipped"
    COV_STATUS="⏭️ Skipped"
fi

# ── Step 5: Unit Tests ────────────────────────────────────────────────────────
if [[ -z "$TEST_STATUS" ]]; then
    test_out="$WORK_DIR/tests.txt"
    test_raw="$WORK_DIR/tests_raw.txt"
    echo "Running unit tests... ($test_out)"
    rm -rf "$RESULT_BUNDLE"
    mkdir -p "$(dirname "$RESULT_BUNDLE")"
    (
        cd "$REPO_ROOT" || exit 1
        xcodebuild \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -destination "$TEST_DESTINATION" \
            -resultBundlePath "$RESULT_BUNDLE" \
            test-without-building 2>&1 | tee "$test_raw" | xcbeautify >"$test_out" 2>&1
        exit "${PIPESTATUS[0]}"
    )
    if [[ $? -eq 0 ]]; then
        TEST_STATUS="✅ Passed"
    else
        TEST_STATUS="❌ Failed"
        OVERALL_PASS=false
        TEST_DETAILS=$(grep '✖' "$test_out" 2>/dev/null | head -200)
        if [[ -z "$TEST_DETAILS" ]]; then
            TEST_DETAILS=$(grep -E "Test Case.*failed\.|\.swift:[0-9]+: error:|Test Suite .* failed|TEST EXECUTE FAILED" "$test_raw" 2>/dev/null | head -100)
        fi
        if [[ -z "$TEST_DETAILS" ]]; then
            TEST_DETAILS=$(tail -50 "$test_raw")
        fi
    fi
fi

# ── Step 6: Code Coverage ─────────────────────────────────────────────────────
if [[ -z "$COV_STATUS" ]]; then
    echo "Checking code coverage..."
    cov_output=$(bash "$SCRIPT_DIR/check-coverage.sh" "$RESULT_BUNDLE")
    cov_result=$(echo "$cov_output" | head -1)
    COV_DETAILS=$(echo "$cov_output" | tail -n +2)

    case "$cov_result" in
        pass)  COV_STATUS="✅ Passed"; COV_DETAILS="" ;;
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

make_row() {
    local status="$1" name="$2" details="$3"
    local icon label
    icon=$(make_icon "$status")
    if [[ -n "$details" ]]; then
        local escaped
        escaped=$(printf '%s' "$details" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
        label=$(printf '<details><summary>%s %s</summary><pre>%s</pre></details>' "$icon" "$name" "$escaped")
    else
        label="$icon $name"
    fi
    printf '<tr><td>%s</td></tr>' "$label"
}

REPORT="<!-- ci-check-results -->
## PR Checks

<table>
$(make_row "$PR_DESC_STATUS" "PR Description" "$PR_DESC_DETAILS")
$(make_row "$COPYRIGHT_STATUS" "Copyright Headers" "$COPYRIGHT_DETAILS")
$(make_row "$LINT_STATUS" "SwiftLint" "$LINT_DETAILS")
$(make_row "$BUILD_STATUS" "Build CITests" "$BUILD_DETAILS")
$(make_row "$TEST_STATUS" "Unit Tests" "$TEST_DETAILS")
$(make_row "$COV_STATUS" "Code Coverage" "$COV_DETAILS")
</table>"

# ── Output ────────────────────────────────────────────────────────────────────
echo "$REPORT" > ci-report.md
cat ci-report.md

[[ "$OVERALL_PASS" == true ]]
