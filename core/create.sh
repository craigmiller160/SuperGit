#!/bin/bash
# Script to create new local branch

### TODO revise this section that produces an error if not enough arguments
if [ $# -lt 2 ]; then
	echo "Error! Not enough arguments for the script"
	exit 1
fi

# Assign shell parameters
SGIT="$1"
NAME="$2"

source "$SGIT/../conf/global.conf" 1>/dev/null 2>/dev/null
source "$SGIT/../conf/local.conf" 1>/dev/null 2>/dev/null

LOG_FILE="$LOGS/create.log"

# Prepare log file
exec 3>&1 1>>"${LOG_FILE}" 2>&1
if [ -f "$LOG_FILE" ]; then
	> "$LOG_FILE"
else
	touch "$LOG_FILE"
fi

# Overwrite create log file
echo "Create Script Log File"
echo "Date: $(date)"
echo ""

# The main function that excutes the script
function main {

	# Test if the directory exists before trying to create it
	if [ -d "$DEV_ROOT/$NAME" ]; then
		echo "Brand directory already exists" | tee /dev/fd/3
		exit 1
	fi

	echo "Fetching latest metadata from remote" | tee /dev/fd/3
	cd "$DEV_MAIN"
	ensure_master_branch
	git fetch
	echo "Updating master branch with latest changes from remote" | tee /dev/fd/3
	git pull origin master

	# Move to main directory and ensure already on master branch
	echo "Creating branch directory" | tee /dev/fd/3
	cp -R "$DEV_MAIN" "$DEV_ROOT/$NAME"
	cd "$DEV_ROOT/$NAME"
	ensure_master_branch

	# Test if the local branch exists, if not create it
	echo "Testing if remote branch already exists"
	git rev-parse --verify "$NAME" 1>/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		echo "Testing if local branch already exists"
		git branch -a | egrep 'remotes/origin/\\$NAME$'
		if [ $? -ne 0 ]; then
			echo "Creating new local git branch" | tee /dev/fd/3
			git checkout -b "$NAME"
		else
			echo "Checkout out local copy of remote branch" | tee /dev/fd/3
			git checkout -b "$NAME" "origin/$NAME"
		fi
	else
		echo "Local branch already exists, checking it out" | tee /dev/fd/3
		git checkout "$NAME"
	fi

}

# A function to ensure that the current branch is the master branch before executing
function ensure_master_branch {

	current_branch=$(git symbolic-ref HEAD | awk -F/ '{print $3}')
	if [ "$current_branch" != "master" ]; then
		echo "Switching Main directory to master branch"
		git checkout master
		if [ $? -ne 0 ]; then
			echo "An unexpected error has occurred. Please check the logs" | tee /dev/fd/3
			exit 1
		fi
	else
		echo "Already on master branch"
	fi

}

# Execute the main function
main