#!/bin/bash
# A script to practice setting up the project files to be symlinked

# Assign shell parameters
SGIT="$1"

source "$SGIT/../conf/global.conf" 1>/dev/null 2>/dev/null
source "$SGIT/../conf/local.conf" 1>/dev/null 2>/dev/null

LOG_FILE="$LOGS/symlink.log"

exec 3>&1 1>>"${LOG_FILE}" 2>&1
if [ -f "$LOG_FILE" ]; then
	> "$LOG_FILE"
else
	touch "$LOG_FILE"
fi

# Overwrite symlink log file
echo "Symlink Script Log File"
echo "Date: $(date)"
echo ""

echo "Running this script" | tee /dev/fd/3

# Create .project directory if it doesn't exist
if [ ! -d "$PROJECT" ]; then
	echo "Creating project directory" | tee /dev/fd/3
	mkdir -p "$PROJECT"
	cd "$PROJECT"
	echo "Initializing git repo in directory"
	git init
	### TODO fully set up git repo here
fi

# Clear existing template directory so it can be rebuilt
if [ -d "$TEMPLATE" ]; then
	echo "Clearing existing template" | tee /dev/fd/3
	rm -rf "$TEMPLATE"
	mkdir -p "$TEMPLATE"
else
	echo "Creating template directory" | tee /dev/fd/3
	mkdir -p "$TEMPLATE"
fi

# Copy and symlink .idea directory to Project directory
if [ ! -h "$DEV_MAIN/.idea" ]; then
	echo "Moving .idea directory to .project and symlinking" | tee /dev/fd/3
	echo "   Moving .idea directory to .project directory"
	mv -f "$DEV_MAIN/.idea" "$PROJECT/.idea"
	echo "   Symlinking reloacted .idea directory back to Main project"
	ln -s "$PROJECT/.idea" "$DEV_MAIN/.idea"
fi

# Find all .iml files
cd "$DEV_MAIN" # This is necessary so that we get relative paths, which are needed for process below
echo "Searching Main directory for .iml files"
files=$(find . -name '*.iml')

# Copy and symlink all .iml files to Project directory
for f in ${files[@]}; do
	
	if [ ! -h $f ]; then
		dir=$(dirname $f)
		file=$(basename $f)
		echo "Moving $file to .project and symlinking" | tee /dev/fd/3

		echo "   Creating directory path for $file in .project"
		mkdir -p "$PROJECT/$dir"
		echo "   Moving $file from Main to .project"
		mv "$f" "$PROJECT/$f"
		echo "   Symlinking $file from .project back to Main"
		ln -s "$PROJECT/$f" "$DEV_MAIN/$f"
	fi
	
done

# Backup .project directory with git
cd "$PROJECT"
echo "Committing changes to project files with git" | tee /dev/fd/3
git add . 1>/dev/null
git commit -m "Updating project files" 1>/dev/null

# Populate new template directory
echo "Populating new Template directory" | tee /dev/fd/3
echo "Symlinking .idea directory from .project to .template"
ln -s "$PROJECT/.idea" "$TEMPLATE/.idea"
echo "Searching for *.iml files in .project, and simlinking them to .template"
cd "$PROJECT"
files=$(find . -name '*.iml')
for f in ${files[@]}; do
	dir=$(dirname $f)
	file=$(basename $f)

	echo "   Creating directory path for $file in .template"
	mkdir -p "$TEMPLATE/$dir"
	echo "   Symlinking $file from .project to .template"
	ln -s "$PROJECT/$f" "$TEMPLATE/$f"
done