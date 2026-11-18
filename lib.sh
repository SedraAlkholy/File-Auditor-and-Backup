require_dir() {
if [ -d "$1" ];
then
echo "Directory exists."
else
echo "Error: Directory doesn't exist."
return 1
fi
}

log_action() {
local action="$1"
echo "$(date '+%Y-%m-%d %H:%M:%S') - $action" >> "$LOG_FILE"
}

