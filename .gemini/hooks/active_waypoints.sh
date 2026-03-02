#!/bin/bash
# Hook: Active Waypoints
# Shows waypoints for the current track URI if available in shared state.

echo "<hook_context name="active_waypoints">"
TRACK_URI=$(defaults read "group.com.brandonlamer-connolly.nowplaying" trackURI 2>/dev/null)

if [ -n "$TRACK_URI" ]; then
    echo "Current Track URI: $TRACK_URI"
    # Waypoints are saved in UserDefaults for the main app with key "waypoints_\(trackURI)"
    # Note: On macOS, this would require querying the app's container.
    # For now, we'll list all waypoint-related keys from the main app's defaults if available.
    echo "Stored Waypoints:"
    defaults read com.brandonlamer-connolly.nowplaying | grep "waypoints_" || echo "No waypoints stored yet."
else
    echo "No track currently playing (or URI not found in shared state)."
fi
echo "</hook_context>"
