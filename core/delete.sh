#!/bin/bash
# Delete script

# Assign shell parameters
SGIT="$1"

source "$SGIT/../conf/global.conf" 1>/dev/null 2>/dev/null
source "$SGIT/../conf/local.conf" 1>/dev/null 2>/dev/null

LOG_FILE="$LOGS/delete.log"

exec 3>&1 1>>"${LOG_FILE}" 2>&1
if [ -f "$LOG_FILE" ]; then
	> "$LOG_FILE"
else
	touch "$LOG_FILE"
fi

# Overwrite delete log file
echo "Delete Script Log File"
echo "Date: $(date)"
echo ""

### TODO figure out how to handle the remote here. backup? repo?

# Initial variable declarations
NAME=""
NO_FLAG=true
LOCAL=false
DIR=false
REMOTE=false
DEV_MAIN_DIR="$(basename $DEV_MAIN)"

# A function to parse arguments
function parse_arg {

	case $1 in
		-*)
			parse_flag $1
		;;
		*)
			if [ "$NAME" = "" ]; then
				NAME="$1"
			else
				printf "${RED}${BOLD}Error! Argument $1 is not a flag, and branch name is already set.${NORM}${NC}\n" | tee /dev/fd/3
				exit 1
			fi
		;;
	esac

	return 0

}

# A function to parse the contents of the flag argument
function parse_flag {

	flag=$1
	NO_FLAG=false

	for (( i = 0; i < ${#flag}; i++ )); do
		case ${flag:$i:1} in
			l)
				if $LOCAL ; then
					printf "${RED}${BOLD}Error! Local flag (l) can only be provided once.${NORM}${NC}\n" | tee /dev/fd/3
					exit 1
				fi
				echo "Setting local flag to true"
				LOCAL=true
			;;
			d)
				if $DIR ; then
					printf "${RED}${BOLD}Error! Directory flag (d) can only be provided once.${NORM}${NC}\n" | tee /dev/fd/3
					exit 1
				fi

				echo "Setting dir flag to true"
				DIR=true
			;;
			r)
				if $REMOTE ; then
					printf "${RED}${BOLD}Error! Remote flag (r) can only be provided once.${NORM}${NC}\n" | tee /dev/fd/3
					exit 1
				fi

				echo "Setting remote flag to true"
				REMOTE=true
			;;
			-)
				# Do nothing
			;;
			*)
				printf "${RED}${BOLD}Error! Invalid flag: ${flag:$i:1}${NORM}${NC}\n" | tee /dev/fd/3
				exit 1
			;;
		esac
	done

	return 0

}



# Parse all arguments
for arg in "${@:2}"; do
	parse_arg $arg
done

# If no flag is provided, everything is true
if $NO_FLAG ; then
	echo "No flags set, setting local, dir, and remote to true"
	LOCAL=true
	DIR=true
	REMOTE=true
fi


# If no branch name is provided, exit with an error
if [ "$NAME" = "" ]; then
	printf "${RED}${BOLD}Error! No branch name to delete provided.${NORM}${NC}\n" | tee /dev/fd/3
	exit 1
fi

# Prevent the deletion of the main directory or master
case "$NAME" in
	"$DEV_MAIN_DIR" | "master")
		printf "${RED}${BOLD}Error! Cann't delete main development branch.${NORM}${NC}\n" | tee /dev/fd/3
		exit 1
	;;
esac

# Build intro message
intro="$NAME: Preparing to delete"
if $DIR ; then
	intro="$intro [directory]"
fi

if $LOCAL ; then
	intro="$intro [local branch]"
fi

if $REMOTE ; then
	intro="$intro [remote branch]"
fi


echo "$intro." | tee /dev/fd/3

cd "$DEV_ROOT_PATH"

# Delete the directory if that option is chosen
if $DIR; then
	DIR_EXISTS=$(ls | grep $NAME)
	if [ "$DIR_EXISTS" != "" ]; then
		printf "$NAME: Deleting branch directory from filesystem." | tee /dev/fd/3
		ERROR=$(rm -rf "$NAME" 2>&1 >/dev/null) &
		while pkill -0 -u craigmiller -x rm; do
			printf "." | tee /dev/fd/3
			sleep 1
		done
		printf "\n" | tee /dev/fd/3

		if [ $? -ne 0 ]; then
			printf "${RED}${BOLD}$TAG $NAME: Unable to delete branch directory from filesystem.${NORM}${NC}\n" | tee /dev/fd/3
			printf "${RED}$ERROR${NC}" | tee /dev/fd/3
		else
			echo "$TAG $NAME: Successfully deleted branch directory from filesystem." | tee /dev/fd/3
		fi
	else
		printf "${RED}${BOLD}$TAG $NAME: Branch is not a directory on local filesystem. Nothing deleted.${NORM}${NC}\n" | tee /dev/fd/3
	fi
fi

