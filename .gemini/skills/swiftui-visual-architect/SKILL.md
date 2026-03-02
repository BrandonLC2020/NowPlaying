---
name: swiftui-visual-architect
description: Expert in the project's "glassmorphism" aesthetic. Use for designing new UI components, implementing .glassBackground() modifiers, and ensuring dynamic color interpolation from album art follows consistent visual patterns.
---

# SwiftUI Visual Architect

Expert guidance for maintaining the polished, glass-inspired look of the Now Playing app.

## Visual Standards
- **Glassmorphism:** Use the `.glassBackground()` modifier for all floating containers. It provides an `ultraThinMaterial` background with a subtle white overlay and a linear gradient border.
- **Dynamic Artwork Blur:** When `appTheme` is `.album`, the background should use a blurred version of the current track image (radius set by `blurRadius`).
- **Interactive Feedback:** Maintain consistent interactive cues (e.g., `.green` for active shuffle/repeat, `.white.opacity(0.1)` for background buttons).
- **Dark Mode Support:** All glass elements are designed to look best when forced to `.dark` color scheme in `ContentView.swift`.

## Key Components
- **Waypoint Dock:** A horizontal scroll view for waypoint navigation. Use `Circle()` with `waypoint.color` and monospaced digits for position text.
- **Main Control Cluster:** Symmetrical layout for playback controls (shuffle, previous, play/pause, next, repeat).
- **Progress Slider:** Integrates `waypoint` markers as small `Circle()` overlays on the track timeline.

## Best Practices
- **Blur Radius Management:** Ensure `blurRadius` (from `@AppStorage`) is correctly passed to background images to prevent pixelation while maintaining the depth effect.
- **Accessibility:** While prioritizing aesthetic, ensure contrast remains readable (use `.shadow(radius: 2)` on text over blurred backgrounds).
- **Layout Consistency:** Standard container width is `250px` for the main content and waypoint dock.
