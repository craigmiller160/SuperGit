#!/bin/bash
# Script to create new local branch

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

# The main function that excutes the script
function main {

	# Move to main directory and ensure already on master branch
	cd "$DEV_MAIN"
	ensure_master_branch

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
		git init
		git remote add origin "$DEV_MAIN"
		echo "   Pulling data from git origin to new directory"
		git pull origin "$NAME"
		git branch -u origin/"$NAME"
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

function check_if_remote_exists {

	if [ $# -ne 1 ]; then
		echo "Error! Missing branch name argument for check_if_remote_exists function"
		exit 1
	fi

	BRANCH="$1"

	remote_branch=$(git branch -a | grep remotes/$REMOTE_NAME/$BRANCH\$)
	if [ "$remote_branch" != "" ]; then
		valid=false
		while ! $valid ; do
			read -p "A remote branch already exists with this name. Do you want to check it out? (y/n)"
			case "$REPLY" in
				y) 
					valid=true
					### TODO checkout the remote branch
				;;
				n)
					valid=true
					### TODO don't checkout the remote branch
				;;
			esac
		done
	fi

	### TODO ensure this affects the rest of the operation

}

# Execute the main function
main