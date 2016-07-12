#!/bin/bash
# Git logging script

if [ $# -lt 1 ]; then
	echo "Error! Not enough arguments for the script"
	exit 1
fi

# Assign shell parameters
SGIT="$1"
if [ $# -eq 2 ]; then
	FILTER="$2"
fi

source "$SGIT/../conf/global.conf" 1>/dev/null 2>/dev/null
source "$SGIT/../conf/local.conf" 1>/dev/null 2>/dev/null

# LOG_FILE="$LOGS/logging.log"

# # Prepare log file
# exec 3>&1 1>>"${LOG_FILE}" 2>&1
# if [ -f "$LOG_FILE" ]; then
# 	> "$LOG_FILE"
# else
# 	touch "$LOG_FILE"
# fi

if [ "$FILTER" == "" ]; then
	git log --pretty=format:'%ad | %H' --date=format:'%Y-%m-%d %H:%M:%S'
else
	git log --pretty=format:'%ad | %H' --date=format:'%Y-%m-%d %H:%M:%S' | grep "$FILTER"
fi

 