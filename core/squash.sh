#!/bin/bash
# Squash commits script

if [ $# -lt 1 ]; then
	echo "Error! Not enough arguments for the script"
	exit 1
fi

# Assign shell parameters
SGIT="$1"

# Load the configurations
source "$SGIT/../conf/global.conf" 1>/dev/null 2>/dev/null
source "$SGIT/../conf/local.conf" 1>/dev/null 2>/dev/null

# Setup the log file and the re-routing of input/output sources
LOG_FILE="$LOGS/squash.log"

exec 3>&1 1>>"${LOG_FILE}" 2>&1
if [ -f "$LOG_FILE" ]; then
	> "$LOG_FILE"
else
	touch "$LOG_FILE"
fi

# Overwrite sqush log file
echo "Squash Script Log File"
echo "Date: $(date)"
echo ""

# Variable parameters assigned based on arguments
custom_message=false
message=""

# A function to parse the arguments of this script
function parse_arg {

	case "$1" in
		-m)
			custom_message=true
		;;
		*)
			if $custom_message ; then
				message="$1"
			else
				echo "Error! Invalid argument $1" | tee /dev/fd/3
				return 1
			fi
		;;
	esac

}

# Get current directory and ensure that the script is only being executed in the Main directory
dir=$(pwd)
if [ "$dir" != "$DEV_MAIN" ]; then
	echo "Error! This command can only be used in the Main directory"
	exit 1
fi

# Parse the other arguments
for arg in "${@:2}"; do
	parse_arg "$arg"
	if [ $? -ne 0 ]; then
		exit 1
	fi
done

# Get the branch name, which should also be the PLIT number
branch_name=$(git symbolic-ref HEAD 2>/dev/null)
branch_name=${branch_name##refs/heads/}

# Assign the default message if a custom message isn't assigned
if ! $custom_message ; then
	message="$branch_name - Committing changes"
fi

# Get a count of the commits to be squashed
count=$(git log --oneline origin/$branch_name..$branch_name | wc -l | awk -F' ' '{ print $1 }')
echo "Command Used: git log --oneline origin/$branch_name..$branch_name | wc -l | awk -F' ' '{ print $1 }'"
echo "$count commits found to squash"

# Get all log entries for the commits to be squashed
IFS=$'\n'
entries=($(git log --pretty=format:'%B%n' --max-count=$count))

# Build the new log entry
entry="$message
"
for e in ${entries[@]}; do
	entry="$entry  $e
"
done

# Confirm with the user that they want this squashed log entry
valid=false
squash=false
while ! $valid ; do
	printf "$entry\n" | tee /dev/fd/3
	printf "Are you satisfied with this log entry? (y/n): " | tee /dev/fd/3
	read
	case $REPLY in
		y|Y)
			squash=true
			valid=true
		;;
		n|N)
			echo "Cancelling commit squash" | tee /dev/fd/3
			valid=true
		;;
		*)
			echo "" | tee /dev/fd/3
			echo "Error! Invalid entry. Please try again!" | tee /dev/fd/3
		;;
	esac
done

# Do the actual squashing of commits
if $squash ; then
	echo "Resetting $count commits"
	git reset --soft HEAD~$count &&
	git commit -m "$entry"

	echo "Commit squashing complete." | tee /dev/fd/3

	# Offer to delete and rebuild branch directory
	rebuild=false
	valid=false
	while ! $valid ; do
		echo "Do you want to rebuild your branch directory?" | tee /dev/fd/3
		echo "This will keep it in sync with the Main directory, but any uncommitted changes will be lost." | tee /dev/fd/3
		printf "Rebuild branch directory? (y/n): " | tee /dev/fd/3
		read
		case $REPLY in
			y|Y)
				rebuild=true
				valid=true
			;;
			n|N)
				echo "Leaving branch directory alone. It will no longer be in sync with the Main directory." | tee /dev/fd/3
				valid=true
			;;
			*)
				echo "" | tee /dev/fd/3
				echo "Error! Invalid entry. Please try again!" | tee /dev/fd/3
			;;
		esac
	done

	# Peform the rebuild, if selected
	if $rebuild ; then
		echo "Rebuilding branch directory, please wait" | tee /dev/fd/3
		echo "Deleting existing directory"
		cd "$DEV_ROOT"
		rm -rf "$branch_name"
		echo "Running create script"
		"$SGIT/../core/create.sh" "$SGIT" "$branch_name"
		echo "Rebuild is now complete" | tee /dev/fd/3
	fi
fi

exit 0