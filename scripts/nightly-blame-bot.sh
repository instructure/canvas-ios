#!/bin/zsh

set -euxo pipefail

# copy the scripts to somewhere git won't change them
if [[ ${1-} = --relocate-before-execute ]]; then
    export CANVAS_SCRIPTS=$(mktemp -d)
    cp -r scripts/* $CANVAS_SCRIPTS
    exec $CANVAS_SCRIPTS/nightly-blame-bot.sh
fi

# TODO: change this to master before merge
if [[ $(git rev-parse --abbrev-ref HEAD) != MBL-13651-nightly-blame-bot ]]; then
    echo "Blame should only be run on master!"
    exit 1
fi

if [[ ${BITRISE_IO-} = true ]]; then
    git reset --hard
fi


if ! git diff-index --quiet HEAD --; then
    echo "unstaged changes present! aborting"
    exit 1
fi

export NSUnbufferedIO=YES

blames=()
failures=("${(@f)FINAL_FAILED_TESTS}")

function banner() (
    set +x
    local yellowbold=$(export TERM=xterm-color; tput bold; tput setaf 3)
    printf "%s" $yellowbold; echo " $@ " | tr -c $'\n' '='
    printf "%s" $yellowbold; echo " $@ "
    printf "%s" $yellowbold; echo " $@ " | tr -c $'\n' '='
    TERM=xterm-color tput sgr0
)

function build {
    destination_flag=(-destination 'platform=iOS Simulator,name=iPhone 8')
    {
        xcodebuild -workspace Canvas.xcworkspace -scheme NightlyTests $destination_flag build-for-testing 2>&1 | xcbeautify --quiet
    } || {
        rm -rf DerivedData/ModuleCache.noindex
        xcodebuild -workspace Canvas.xcworkspace -scheme NightlyTests $destination_flag build-for-testing 2>&1 | xcbeautify --quiet
    }
}

function lookup_committer {
    export EMAIL=$1
    # tiny amount of obfuscation to deter unsophisticated spammers
    EMAIL=$(printf "%s" $EMAIL | sed -e 's/\./_DOT_/g' -e 's/@/_AT_/g')
    match=$(jq < $CANVAS_SCRIPTS/blame.json '[.[] | select(.emails | index(env.EMAIL) != null) | del(.emails)][0]')
    [[ $match != "null" ]] || return 1
    SLACK_ID=$(printf "%s" $match | jq -r .slack)
    JIRA_ID=$(printf "%s" $match | jq -r .jira)
}

function blame_slack {
    message_lines+="<@$SLACK_ID> the commit https://github.com/instructure/canvas-ios/commit/$BLAME_REF"
    message_lines+='```'"$COMMIT_INFO"'```'
    message_lines+="probably caused build ${BUILD_LINK-(unknown)} to fail these tests:"
    message_lines+='```'"${(F)broken}"'```'

    export MSG=${(F)message_lines}
    #TODO: bottest -> ios-bots
    blames+=$(jq -nac '{
        "channel": "#bottest",
        "text": env.MSG,
        "icon_emoji": ":bitrise:",
        "username": "nightly-blame-bot.sh"
    }')
}

while (( ${#failures} > 0 )); do
    export BLAME_REF=$(git rev-parse HEAD)
    banner "reverting $(git log -1 --format=oneline)"
    git checkout HEAD^
    build
    ret=0
    $CANVAS_SCRIPTS/run-nightly-tests.sh --only-testing $failures || ret=$?
    new_failures=("${(@f)$(cat nightly-xcresults/final-failed.txt)}")

    # subtract the 2 lists
    broken=("${(@)failures:|new_failures}")

    if (( ${#broken} > 0 )); then
        message_lines=()
        export EMAIL=$(git log -1 --pretty='%ae' $BLAME_REF)
        export COMMIT_INFO=$(git log -1 $BLAME_REF)
        lookup_committer $EMAIL || {
            message_lines+="Unknown commit email! Pinging default instead"
            lookup_committer default
        }
        blame_slack
    fi

    failures=($new_failures)
done

SHAME=NONE
for blame in $blames; do
    curl -X POST \
        -H "Content-Type: application/json; charset=utf-8" \
        --data-raw $blame \
        $SLACK_URL
    SHAME=GREAT
done

if [[ $SHAME = GREAT ]]; then
    jq -nac '{
        "channel": "#bottest",
        "icon_emoji": ":bitrise:",
        "username": "nightly-blame-bot.sh",
        "blocks": [{
            "type": "image",
            "title": {
                "type": "plain_text",
                "text": "shame",
                "emoji": true
            },
            "image_url": ("https://slack-imgs.com/?c=1&o1=ro&url=https%3A%2F%2Fmedia3.giphy.com" +
                "%2Fmedia%2FvX9WcCiWwUF7G%2Fgiphy-downsized.gif%3Fcid%3D6104955ef69b1126ce0cbe3" +
                "c52d75481324b04c9c77ded5c%26rid%3Dgiphy-downsized.gif"),
            "alt_text": "Shame. Shame. Shame."
	}]
    }' |
    curl -X POST \
        -H "Content-Type: application/json; charset=utf-8" \
        --data-binary @- \
        $SLACK_URL
fi
