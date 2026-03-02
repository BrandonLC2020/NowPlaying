#!/bin/bash
# Hook: Theme & Glassmorphism Settings
# Outputs the current theme and blur radius settings from the app's preferences.

echo "<hook_context name="theme_settings">"
# Theme defaults from @AppStorage ("appTheme", "blurRadius", "skipInterval")
echo "Current App Settings:"
defaults read com.brandonlamer-connolly.nowplaying appTheme 2>/dev/null || echo "Theme: (Default/Album)"
defaults read com.brandonlamer-connolly.nowplaying blurRadius 2>/dev/null || echo "Blur Radius: (Default/40.0)"
defaults read com.brandonlamer-connolly.nowplaying skipInterval 2>/dev/null || echo "Skip Interval: (Default/15s)"
echo "</hook_context>"
