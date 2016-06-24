#!/bin/bash
# SuperGit Setup Script

### TODO add item for configuring the remote name
### TODO add backup remote configuration
### TODO test for value existence, and offer to leave the same or change

echo "Welcome to SuperGit. This will guide you through setting up SuperGit's configuration"
echo ""

read -p "Press any key to continue..."

echo "First, we need to get the path to the main Git binary."

valid=false
while ! $valid ; do
	read -p "Enter full path to main Git binary: "
	if [ ! -f "$REPLY" ]; then
		echo "Error! Not a valid path to the Git binary. Please try again"
	else
		GIT_PATH="$REPLY"
		valid=true
	fi
done

echo "Now, please enter the url of the remote repo this project will sync with."

valid=false
while ! $valid ; do
	read -p "Remote Repo URL: "
	if [ "$REPLY" == "" ]; then
		echo "Error! Not a valid repo url. Please try again"
	else
		MAIN_REMOTE="$REPLY"
		valid=true
	fi
done

echo "Excellent! Saving configuration"

echo "# SuperGit Local Configuration" > ../conf/local.conf
echo "# A key-value file for the local configurations for SuperGit" >> ../conf/local.conf
echo "" >> ../conf/local.conf
echo "# The path to the actual git binary on the local system" >> ../conf/local.conf
echo "GIT_PATH=\"$GIT_PATH\"" >> ../conf/local.conf
echo "" >> ../conf/local.conf

### TODO add this stuff
# The path to the sgit binary on the local system
# SGIT_PATH=""

echo "# The urls for the main and backup remote repos" >> ../conf/local.conf
echo "MAIN_REMOTE=\"$MAIN_REMOTE\"" >> ../conf/local.conf
### TODO add this one BACKUP_REMOTE=""

# Overriding directory paths should go here

echo "SuperGit is now configured"