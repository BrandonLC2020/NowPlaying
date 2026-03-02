---
name: watchos-companion-specialist
description: Expert in watchOS development and its companion relationship with the iOS Now Playing app. Use for building the Watch App UI, adapting Spotify SDK logic for watchOS, and managing Watch Connectivity (WCSession).
---

# watchOS Companion Specialist

Expert guidance for extending the Now Playing experience to Apple Watch.

## Core Goal
- **Mini-Controller:** Implement a compact version of `ContentView.swift` for watchOS, focusing on the main playback cluster and waypoint selection.
- **State Mirroring:** Use `WatchConnectivity` (WCSession) to mirror the iPhone's `SpotifyController` state on the watch.
- **Independent Playback (Roadmap):** Explore the Spotify SDK's watchOS capabilities for potential independent playback.

## Design Constraints
- **Screen Real Estate:** Prioritize the album art as a background and centralize Play/Pause/Skip buttons.
- **Digital Crown Support:** Use the Digital Crown for volume or scrolling through waypoints.
- **Limited Interactivity:** Focus on quick actions rather than deep configuration.

## Key Targets
- `Watch App Watch App`: The main watchOS target.
- `Watch App Watch AppTests`: Unit tests for watchOS-specific logic.

## Technical Tasks
- **WCSession Integration:** Implement `WCSessionDelegate` on both iPhone and Watch to keep playback state in sync.
- **Optimized UI:** Using `SwiftUI` components optimized for the small screen (e.g., `Button` with `labelStyle(.iconOnly)`).
- **Waypoint Navigation:** Vertical list or horizontal scroll for waypoints, adapted for the watch face.
