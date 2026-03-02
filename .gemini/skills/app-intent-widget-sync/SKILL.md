---
name: app-intent-widget-sync
description: Specialized in AppIntents and widget-to-app state synchronization. Use for improving widget controls, handling shared state in App Groups, and bridging background intent triggers to SpotifyController playback.
---

# App Intent & Widget Sync Expert

Expert guidance for managing the shared state between the Now Playing app and its widget extension.

## Architecture
- **App Group:** All shared data uses `group.com.brandonlamer-connolly.nowplaying`.
- **PlaybackStateManager:** The source of truth for the widget. Every time `SpotifyController` updates, it MUST call `saveState()` which triggers `WidgetCenter.shared.reloadAllTimelines()`.
- **AppIntents:** Located in `PlaybackControlIntents.swift`. Currently, they update the `PlaybackState` in the App Group but do not yet trigger the live Spotify session.

## Key State Synchronization
- **Track Metadata:** Name, artist, URI, and duration must be synchronized to ensure the widget reflects the current track.
- **Playback State:** `isPaused` and `currentTrackPosition` are crucial for the widget's "Now Playing" UI.
- **Timeline Reloading:** Always call `WidgetCenter.shared.reloadAllTimelines()` after any state change that affects the widget.

## Roadmap & Challenges
- **Background Playback Control:** The current `AppIntents` in `PlaybackControlIntents.swift` need a mechanism to wake the main app or communicate with the `SpotifyController`'s background session to actually pause/play music.
- **Image Persistence:** Album art images are saved separately using `saveImage()` in `PlaybackStateManager`.

## Best Practices
- **Minimized Writes:** Only save to `PlaybackStateManager` when state actually changes to avoid redundant widget reloads.
- **Timestamping:** Always update `lastUpdated` in `PlaybackState` to help the widget's `TimelineProvider` determine data freshness.
