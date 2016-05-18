#!/bin/bash
# Squash commits script

if [ $# -lt 1 ]; then
	echo "Error! Not enough arguments for the script"
	exit 1
fi

# Assign shell parameters
SGIT="$1"

source "$SGIT/../conf/global.conf" 1>/dev/null 2>/dev/null
source "$SGIT/../conf/local.conf" 1>/dev/null 2>/dev/null

### TODO setup logging

dir=$(pwd)

if [ "$dir" != "$DEV_MAIN" ]; then
	echo "Error! This command can only be used in the Main directory"
	exit 1
fi

branch_name=$(git symbolic-ref HEAD 2>/dev/null)
branch_name=${branch_name##refs/heads/}

count=$(git log --oneline origin/$branch_name..$branch_name | wc -l | awk -F' ' '{ print $1 }')

IFS=$'\n'

entries=($(git log --pretty=format:'%B%n' --max-count=$count))

entry="$branch_name - Committing changes\n"
for e in ${entries[@]}; do
	entry="$entry  $e\n"
done

### TODO the entry should be the commit message
printf "$entry"