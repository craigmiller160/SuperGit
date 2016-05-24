#!/bin/bash
# Script to create new local branch

### TODO ensure on master branch in Main directory before beginning process
### TODO update trunk before creating the new branch
### TODO add option to pull from remote

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

# Move to main directory for using git commands
cd "$DEV_MAIN"

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

# Test if the local branch exists, if not create it
git rev-parse --verify "$NAME" 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
	echo "Creating new local git branch" | tee /dev/fd/3
	git branch "$NAME" 1>/dev/null
else
	echo "Local git branch already exists" | tee /dev/fd/3
fi

# Test if the directory exists, if not create it
if [ -d "$DEV_ROOT/$NAME" ]; then
	echo "Branch directory already exists" | tee /dev/fd/3
else
	echo "Creating and configuring new branch directory" | tee /dev/fd/3
	echo "   Copying .template to create new directory"
	cp -R "$TEMPLATE" "$DEV_ROOT/$NAME"
	echo "   Initializing and configuring git in new directory"
	cd "$DEV_ROOT/$NAME"
	git init 1>/dev/null
	git remote add origin "$DEV_MAIN"
	echo "   Pulling data from git origin to new directory"
	git pull origin "$NAME" 1>/dev/null
	git branch -u origin/"$NAME" 1>/dev/null
fi

