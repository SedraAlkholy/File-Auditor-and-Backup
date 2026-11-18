source "$(dirname "$0")/lib.sh"
TARGET_DIR="${1:-.}"
LOG_FILE="$TARGET_DIR/auditor.log"
require_dir "$TARGET_DIR" || exit 1

#Lists all the files and directories in the given directory and counts them.
scan_dir() {
local file_count=0
local dir_count=0
echo "scannng directory: $TARGET_DIR"

for item in "$TARGET_DIR"/*; do
if [ -e "$item" ];
then
echo "$item"

if [ -f "$item" ];
then
((file_count++))
elif [ -d "$item" ];
then
((dir_count++))
fi
fi
done

echo "Files: $file_count"
echo "Directories: $dir_count"

log_action "scan_dir"
}

#Prints and checks the write, read, and execute permissions.
permission_audit() {
local unreadable_count=0
local executable_count=0
local permissions=""
echo "Permission Audit: $TARGET_DIR"

for file in "$TARGET_DIR"/*; do

if [ -f "$file" ];
then
permissions=""
if [ -r "$file" ];
then
permissions+="r"
else
permissions+="-"
fi

if [ -w "$files" ];
then
permissions+="w"
else
permissions+="-"
fi

if [ -x "$file" ];
then
permissions+="x"
((executable_count++))
else
permissions+="-"
fi

echo "$(basename "$file"): $permissions"

if [ ! -r "$file" ];
then
((unreadable_count++))
fi
fi
done

echo "Unreadable Files: $unreadable_count"
echo "Executable Files: $executable_count"

log_action "permission_audit"
}

#Counts the file given with a specific extension.
extension_report() {
declare -A ext_count
ext_count=(
[txt]=0
[log]=0
[sh]=0
[jpg]=0
[other]=0
)

for file in "$TARGET_DIR"/*; do

if [ -f "$file" ];
then
extension="${file##*.}"

if [[ ${ext_count[$extension]+_} ]];
then
((ext_count[$extension]++))
else
((ext_count[other]++))
fi
fi
done

echo "Extension Report:"

for ext in txt log sh jpg other; do
echo "$ext: ${ext_count[$ext]}"
done

log_action "extension_report"
}

#searches for a file by its name.
search_file() {
local search_text
local file
local file_name
local found=0

read -r -p "Enter file name: " search_text

for file in "$TARGET_DIR"/*; do
if [ -f "$file" ];
then
file_name="${file##*/}"
if [[ "$file_name" == *"$search_text"* ]];
then
echo "Found: $file_name"
((found++))
fi
fi
done
if [ "$found" -eq 0 ];
then
echo "No matching files found."
fi

log_action "search_file"
}

#Backsup timestamps of readable files.
backup_all() {
local file
local file_name
local timestamp
local saved_count=0
local skipped_count=0

mkdir -p "$TARGET_DIR/backups"

for file in "$TARGET_DIR"/*; do
if [ -f "$file" ];
then
if [ -r "$file" ];
then
file_name=$(basename "$file")
timestamp=$(date '+%Y%m%d_%H%M%S')
cp "$file" "$TARGET_DIR/backups/${file_name}_${timestamp}.bak"
((saved_count++))

else
echo "Error: Cannot read $file"
((skipped_count++))
fi
fi
done
echo "Backed up!"
echo "Saved files: $saved_count"
echo "Skipped files: $skipped_count"

log_action "backup_all"
}

#Displays all the backup files.
list_backups() {
local backup_file
local found=0
echo "Available Backups: "

for backup_file in "$TARGET_DIR/backups"/*; do
if [ -f "$backup_file" ];
then
echo "$(basename "$backup_file")"
found=1
fi
done
if [ "$found" -eq 0 ];
then
echo "No backups yet."
fi

log_action "list_backups"
}

#Restores a given backup without overwriting the original file.
restore_backups() {
local backup_name
local backup_path
local original_name

read -r -p "Enter backup file name: " backup_name
backup_path="$TARGET_DIR/backups/$backup_name"

if [ -f "$backup_path" ];
then
original_name="${backup_name%_*_*}"
original_name="${original_name%.bak}"

cp "$backup_path" "$TARGET_DIR/restored_$original_name"

echo "Backup restored successfully!"
echo "Restored_file: restored_$original_name"

log_action "restore_backup"

else
echo "Error: Backup file not found."
log_action "restore_backup"
return 1
fi
}

#Gives a menu for the user to choose an action to do.
main_menu() {
local choice

while true; do
echo ""
echo "File Auditor & Backup: "
echo "1- Scan Directory."
echo "2- Permission Audit."
echo "3- Extension Report."
echo "4- Search File."
echo "5- Backup All."
echo "6- List Backups."
echo "7- Restore Backup."
echo "8- Exit."

read -r -p "Enter your choice: " choice

if [ "$choice" = "1" ];
then
scan_dir
elif [ "$choice" = "2" ];
then
permission_audit
elif [ "$choice" = "3" ];
then
extension_report
elif [ "$choice" = "4" ];
then
search_file
elif [ "$choice" = "5" ];
then
backup_all
elif [ "$choice" = "6" ];
then
list_backups
elif [ "$choice" = "7" ];
then
restore_backups
elif [ "$choice" = "8" ];
then
echo "Exited!"
break

else
echo "Invalid choice, Please choose from the given choices."
fi
done
}

#Command-line Arguments
if [ -z "$2" ];
then
main_menu

elif [ "$2" = "scan" ];
then
scan_dir
elif [ "$2" = "perms" ];
then
permission_audit
elif [ "$2" = "ext" ];
then
extension_report
elif [ "$2" = "backup" ];
then
backup_all

else
echo "Invalid action."
fi
