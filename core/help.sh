#!/bin/bash
# Help script

# Assign shell parameters
SGIT="$1"

### TODO goal is for this script to not need the configurations

# Load configuration
source "$SGIT/../conf/global.conf" 1>/dev/null 2>/dev/null
source "$SGIT/../conf/local.conf" 1>/dev/null 2>/dev/null

function help_main {

	echo "NAME"
	echo "    SuperGit"
	echo ""
	echo "AUTHOR"
	echo "    Craig Miller"
	echo ""
	echo "VERSION"
	echo "    1.0"
	echo ""
	echo "DESCRIPTION"
	echo "    SuperGit is an extension to the regular git version control system to provide advanced features. These features can be accessed either via the 'sgit' command, or by overriding the standard 'git' command."
	echo ""
	echo "SETUP"
	echo "    SuperGit can be setup in two modes: 'integrated' and 'standalone'"
	echo ""
	echo "        Integrated Mode"
	echo "            This mode involves overriding the default Git binary by placing the 'bin' directory of the sgit installation package at the beginning of the PATH environment variable. This will cause the custom 'git' script included in that directory to be used instead of the regular git binary. On first run, a configuration process will be used where you will be required to input the full path to the actual git binary. The result is that all sgit commands can be run using git, ie 'git create' instead of 'sgit create'. Normal git commands will still work as expected, due to having the actual path of the git binary to forward them to."
	echo ""
	echo "        Standalone Mode"
	echo "            This mode involves using the 'sgit' script without touching git itself. This is achieved either by placing the 'bin' directory on the PATH, or by simlinking the 'sgit' script into a location that is on the PATH. All commands will need to be given directly to sgit, and git itself will operate as normal."
	echo ""
	echo "COMMANDS"
	echo "    Use 'sgit --help [command]' for more info on a specific command"
	echo ""
	echo "    create         Create a new local working branch and directory."
	echo ""
	echo "    setup          Start or restart the configuration process for sgit."
	echo ""
	echo "    squash         Compare local branch to remote, and squash all local commits into a single commit, while preserving commit messages."
	echo ""
	echo "    symlink        Remove all IntelliJ project files from Main directory and set them up in hidden .project folder."

}

function help_create {

	

}

function help_setup {



}

function help_squash {




}

function help_symlink {



}



function parse_arg {

	case "$1" in
		create)
			help_create
		;;
		setup)
			help_setup
		;;
		squash)
			help_squash
		;;
		symlink)
			help_symlink
		;;
	esac

}

if [ ?# -gt 2 ]; then
	echo "Error! Too many arguments provided to sgit help command"
fi

if [ ?# -eq 1 ]; then
	help_main
else
	parse_arg "$2"
fi

