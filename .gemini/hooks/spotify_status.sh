#!/bin/bash
# Hook: Spotify SDK Status
# Outputs the current connection status and basic track info if available.

echo "<hook_context name="spotify_status">"
# In a real environment, we'd query the running app or a state file.
# For now, we'll read the shared state file if it exists.
STATE_FILE="$HOME/Library/Group Containers/group.com.brandonlamer-connolly.nowplaying/Library/Preferences/group.com.brandonlamer-connolly.nowplaying.plist"

if [ -f "$STATE_FILE" ]; then
    echo "Shared State (App Group):"
    defaults read "group.com.brandonlamer-connolly.nowplaying"
else
    echo "No shared state found. Ensure the app has been run at least once."
fi
echo "</hook_context>"
