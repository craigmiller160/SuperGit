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

# LOG_FILE="$LOGS/create.log"

# Prepare log file
# exec 3>&1 1>>"${LOG_FILE}" 2>&1
# if [ -f "$LOG_FILE" ]; then
# 	> "$LOG_FILE"
# else
# 	touch "$LOG_FILE"
# fi

# Overwrite create log file
# echo "Create Script Log File"
# echo "Date: $(date)"
# echo ""

# The main function that excutes the script
function main {

	# Test if the directory exists before trying to create it
	if [ -d "$DEV_ROOT/$NAME" ]; then
		echo "Error! Brand directory already exists"
		exit 1
	fi

	echo "Fetching latest metadata from remote"
	cd "$DEV_MAIN"
	ensure_master_branch

	git fetch 1>/dev/null 2>/dev/null
	echo "Updating master branch with latest changes from remote" 
	git pull origin master 1>/dev/null 2>/dev/null

	# Move to main directory and ensure already on master branch
	echo "Creating branch directory"
	cp -R "$DEV_MAIN" "$DEV_ROOT/$NAME"
	cd "$DEV_ROOT/$NAME"
	ensure_master_branch

	# Test if the local branch exists, if not create it
	git rev-parse --verify "$NAME" 1>/dev/null 2>/dev/null
	if [[ $? -ne 0 ]]; then
		git branch -a | egrep 'remotes/origin/\\$NAME$' 1>/dev/null 2>/dev/null
		if [[ $? -ne 0 ]]; then
			echo "Creating new local git branch"
			git checkout -b "$NAME" 1>/dev/null 2>/dev/null
		else
			echo "Checkout out local copy of remote branch"
			git checkout -b "$NAME" "origin/$NAME" 1>/dev/null 2>/dev/null
		fi
	else
		echo "Local branch already exists, checking it out"
		git checkout "$NAME" 1>/dev/null 2>/dev/null
	fi

}

# A function to ensure that the current branch is the master branch before executing
function ensure_master_branch {

	current_branch=$(git symbolic-ref HEAD | awk -F/ '{print $3}')
	if [ "$current_branch" != "master" ]; then
		echo "Switching Main directory to master branch"
		git checkout master 1>/dev/null 2>/dev/null
		if [ $? -ne 0 ]; then
			echo "An unexpected error has occurred. Please check the logs"
			exit 1
		fi
	else
		echo "Already on master branch"
	fi

}

# Execute the main function
main