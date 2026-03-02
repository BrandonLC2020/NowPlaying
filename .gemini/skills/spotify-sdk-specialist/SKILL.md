---
name: spotify-sdk-specialist
description: Expert in Spotify iOS SDK integration (SPTAppRemote). Use for debugging playback synchronization, session management, token refresh, and waypoint persistence logic within SpotifyController.swift.
---

# Spotify SDK Specialist

Expert guidance for maintaining and extending the Spotify SDK integration in the Now Playing app.

## Core Responsibilities
- **Session Lifecycle:** Manage `SPTAppRemote` connection state (connect/disconnect) in sync with `UIApplication` lifecycle.
- **Playback Synchronization:** Handle `SPTAppRemotePlayerStateDelegate` to keep `currentTrackPosition`, `isPaused`, and track metadata up to date.
- **Waypoint Logic:** Manage the `waypoints` array, including adding/removing waypoints and seeking to specific positions using `playerAPI?.seek(toPosition:callback:)`.
- **API Communication:** Use `URLSession` for direct Spotify Web API calls (e.g., `/me` for user profile) when the SDK lacks specific functionality.

## Key Patterns in `SpotifyController.swift`
- **Timer-based Updates:** Since the SDK only notifies on state changes, a local `Timer` increments `currentTrackPosition` every second while playing.
- **Persistence:** Waypoints are persisted in `UserDefaults` using the track's URI as a key: `waypoints_\(trackURI)`.
- **App Group Sync:** Every state change must call `saveState()` to update the shared `PlaybackState` for the widget.

## Common Tasks
- **Fixing Connection Issues:** Ensure `accessToken` is valid and `authorize()` is called if `appRemote.isConnected` is false.
- **Extending Metadata:** Adding new fields from `SPTAppRemotePlayerState` (e.g., album name, URI) to the `@Published` properties.
- **Optimizing Seek:** Handling seek intervals and ensuring the timer stays in sync after a manual seek.
