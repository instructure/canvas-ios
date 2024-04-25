#!/bin/bash

if [ $# -ne 2 ]; then
	echo "This script lists commits between the version's tag and the master branch affecting the given app."
	echo "Usage: $0 <Student|Teacher|Parent> <version>"
	exit 1
fi

tag_name="$1-$2"

if ! git rev-parse -q --verify "refs/tags/$tag_name" >/dev/null; then
	echo "Tag '$tag_name' not found."
	exit 1
fi

# -i to do a case insensitive search
# --grep to list commits containing the affects string and the app's name in one line
# --oneline to print commits in a short format
git log -i --grep="affects:.*$1" --oneline master...$tag_name
