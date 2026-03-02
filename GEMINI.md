# GEMINI.md - Now Playing Project Overview

This document provides essential context and instructions for AI agents working on the **Now Playing** project.

## Project Overview
Now Playing is a modern iOS application that provides a sleek "glassmorphism" interface for controlling and viewing Spotify tracks. It features real-time playback synchronization, interactive waypoints for bookmarking song positions, and a companion iOS widget.

- **Primary Technologies:** SwiftUI, Spotify iOS SDK, App Intents, Combine.
- **Platforms:** iOS (Main App), iOS Widget (Extension), watchOS (In development).
- **Core Architecture:**
    - **`SpotifyController`**: The central `@MainActor` observable object managing the Spotify session (`SPTAppRemote`), playback state, and waypoints.
    - **`PlaybackStateManager`**: Manages shared state between the main app and the widget using App Groups (`group.com.brandonlamer-connolly.nowplaying`).
    - **`ContentView`**: The primary UI, featuring dynamic backgrounds based on album art, glassmorphism effects, and waypoint navigation.
    - **`Waypoint`**: A data model representing a specific second in a track, including a unique ID and a display color.

## Building and Running
### Prerequisites
- Xcode 15.0+
- Spotify Premium account (required for SDK playback control).
- Spotify App installed on the target device/simulator.

### Setup & Commands
1.  **Configuration**: Create `Now Playing/Now Playing/Sample.xcconfig` and add your Spotify Client ID:
    ```
    SPOTIFY_API_CLIENT_ID = YOUR_CLIENT_ID
    ```
2.  **Spotify Dashboard**: Ensure the Redirect URI `spotify-ios-quick-start://spotify-login-callback` is registered in your Spotify Developer App settings.
3.  **Xcode**:
    - Open `Now Playing/Now Playing.xcodeproj`.
    - Select the **Now Playing** scheme.
    - Build and Run (`Cmd + R`).

## Development Conventions
- **State Management**: Use `SpotifyController` for all playback-related logic. It handles the Spotify SDK's delegation and timer-based position updates.
- **UI Styling**: 
    - Use the `.glassBackground()` modifier for consistent translucent containers.
    - Support three themes: `.light`, `.dark`, and `.album` (dynamic artwork blur).
    - Blur radius and skip intervals are persisted via `@AppStorage`.
- **Widget Integration**: 
    - The widget relies on `PlaybackStateManager` for its data.
    - Whenever significant state changes occur in the main app, `WidgetCenter.shared.reloadAllTimelines()` must be called.
    - **Note**: Current `AppIntents` in `PlaybackControlIntents.swift` update the shared state but do not yet trigger the `SpotifyController` directly due to SDK session requirements.
- **Persistence**: 
    - Waypoints are saved to `UserDefaults` using the track's URI as a key.
    - Shared defaults (App Group) are used for cross-target communication.

## Key Files
- `Now Playing/Now Playing/SpotifyController.swift`: Core playback and session logic.
- `Now Playing/Now Playing/ContentView.swift`: Main UI and theme logic.
- `Now Playing/Now Playing/PlaybackState.swift`: Shared data models and storage manager.
- `Now Playing/iOS Widget/iOS_Widget.swift`: Widget UI and timeline provider.
- `Now Playing/Now Playing/Waypoint.swift`: Waypoint data structures.

## Roadmap & TODOs
- [ ] Implement actual playback control from Widget App Intents (requires background session handling).
- [ ] Complete the watchOS companion app implementation.
- [ ] Enhance waypoint management (editing labels/colors).
