//
//  ContentView.swift
//  Now Playing
//
//  Created by Brandon Lamer-Connolly on 10/25/23.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case album = "Album Art"
    var id: String { self.rawValue }
}

struct ContentView: View {
    @EnvironmentObject var spotifyController: SpotifyController

    @AppStorage("appTheme") private var appTheme: AppTheme = .album
    @AppStorage("blurRadius") private var blurRadius: Double = 40.0
    @AppStorage("skipInterval") private var skipInterval: Int = 15

    @State private var showingThemeSettings = false
    @State private var scrubbingPosition: Double?

    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Background Layer
                BackgroundLayer(appTheme: appTheme, blurRadius: blurRadius)

                // MARK: - Foreground Layer
                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 20) {
                        // Main Content
                        VStack {
                            if let trackName = spotifyController.currentTrackName,
                               let trackArtist = spotifyController.currentTrackArtist,
                               let trackImage = spotifyController.currentTrackImage {
                                // Album Art - Slightly smaller to fit everything
                                Image(uiImage: trackImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    .trackTransition(id: spotifyController.currentTrackURI, duration: 0.4)

                                // Track Name
                                Text(trackName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(width: 250)
                                    .shadow(radius: 2)
                                    .trackTransition(id: spotifyController.currentTrackURI)

                                // Artist Name
                                Text(trackArtist)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.9))
                                    .frame(width: 250)
                                    .shadow(radius: 2)
                                    .trackTransition(id: spotifyController.currentTrackURI)

                                // Main Controls
                                MainControls()
                                    .padding(.top, 5)

                                // Progress Bar Layer
                                ProgressBarLayer(scrubbingPosition: $scrubbingPosition)
                                    .padding(.horizontal, 15)
                                    .padding(.top, 10)
                                    .frame(width: 250)

                                // Secondary Controls
                                if skipInterval > 0 {
                                    HStack(spacing: 50) {
                                        Button(action: { spotifyController.skipBackward() }) {
                                            Image(systemName: "gobackward.\(skipInterval)")
                                                .font(.title)
                                                .foregroundColor(.white)
                                        }

                                        Button(action: { spotifyController.skipForward() }) {
                                            Image(systemName: "goforward.\(skipInterval)")
                                                .font(.title)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.top, 5)
                                }

                            } else {
                                ProgressView()
                                    .tint(.white)
                                    .frame(width: 250, height: 400)
                            }
                        }
                        .padding(.vertical, 25)
                        .padding(.horizontal, 20)
                        .glassBackground()
                        .environment(\.colorScheme, .dark)

                        // Waypoint Dock
                        if !spotifyController.waypoints.isEmpty {
                            WaypointDock()
                                .transition(.slideUpFade)
                        }
                    }
                    .padding(20)
                    .animation(.spring(response: 0.45, dampingFraction: 0.78), value: spotifyController.waypoints.isEmpty)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                spotifyController.skipInterval = skipInterval
            }
            .onChange(of: skipInterval) { newValue in
                spotifyController.skipInterval = newValue
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    AccountMenu()
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    SettingsButton(
                        showingThemeSettings: $showingThemeSettings,
                        appTheme: $appTheme,
                        skipInterval: $skipInterval,
                        blurRadius: $blurRadius
                    )
                }
            }
        }
    }
}

// MARK: - Subviews

struct AccountMenu: View {
    @EnvironmentObject var spotifyController: SpotifyController

    var body: some View {
        Menu {
            Section {
                Text("Account: \(spotifyController.currentUserDisplayName ?? "Loading...")")
            }

            Button(role: .destructive, action: {
                spotifyController.logout()
            }) {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            if let userImage = spotifyController.currentUserImage {
                Image(uiImage: userImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct SettingsButton: View {
    @Binding var showingThemeSettings: Bool
    @Binding var appTheme: AppTheme
    @Binding var skipInterval: Int
    @Binding var blurRadius: Double

    var body: some View {
        Button {
            showingThemeSettings.toggle()
        } label: {
            Image(systemName: "gear")
                .foregroundColor(.primary)
        }
        .popover(isPresented: $showingThemeSettings) {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Theme")
                        .font(.subheadline)
                    Picker("Theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Skip Interval")
                        .font(.subheadline)
                    Picker("Skip Interval", selection: $skipInterval) {
                        Text("None").tag(0)
                        Text("5s").tag(5)
                        Text("10s").tag(10)
                        Text("15s").tag(15)
                        Text("30s").tag(30)
                    }
                    .pickerStyle(.segmented)
                }

                if appTheme == .album {
                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Blur Control")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(blurRadius))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Slider(value: $blurRadius, in: 0...100)
                    }
                }
            }
            .padding()
            .frame(width: 300)
            .presentationCompactAdaptation(.popover)
        }
    }
}

struct BackgroundLayer: View {
    @EnvironmentObject var spotifyController: SpotifyController
    let appTheme: AppTheme
    let blurRadius: Double

    var body: some View {
        Group {
            switch appTheme {
            case .light:
                Color.white.ignoresSafeArea()
            case .dark:
                Color.black.ignoresSafeArea()
            case .album:
                if let trackImage = spotifyController.currentTrackImage {
                    Image(uiImage: trackImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                        .blur(radius: CGFloat(blurRadius))
                        .overlay(Color.black.opacity(0.3))
                        .trackTransition(id: spotifyController.currentTrackURI, duration: 0.6)
                } else {
                    Color.black.ignoresSafeArea()
                }
            }
        }
    }
}

struct MainControls: View {
    @EnvironmentObject var spotifyController: SpotifyController

    var body: some View {
        HStack(spacing: 25) {
            Button(action: { spotifyController.toggleShuffle() }) {
                Image(systemName: "shuffle")
                    .font(.body)
                    .foregroundColor(spotifyController.isShuffling ? .green : .white.opacity(0.6))
            }

            Button(action: { spotifyController.skipToPrevious() }) {
                Image(systemName: "backward.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }

            Button(action: {
                spotifyController.isPaused ? spotifyController.play() : spotifyController.pause()
            }) {
                Image(systemName: spotifyController.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .contentTransition(.symbolEffect(.replace))
                    .animation(.easeInOut(duration: 0.2), value: spotifyController.isPaused)
            }

            Button(action: { spotifyController.skipToNext() }) {
                Image(systemName: "forward.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }

            Button(action: { spotifyController.toggleRepeat() }) {
                Image(systemName: spotifyController.repeatMode == 1 ? "repeat.1" : "repeat")
                    .font(.body)
                    .foregroundColor(spotifyController.repeatMode != 0 ? .green : .white.opacity(0.6))
            }
        }
    }
}

struct ProgressBarLayer: View {
    @EnvironmentObject var spotifyController: SpotifyController
    @Binding var scrubbingPosition: Double?
    
    @State private var localSliderValue: Double = 0

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .leading) {
                Slider(
                    value: $localSliderValue,
                    in: 0...Double(max(1, spotifyController.currentTrackDuration ?? 1))
                ) { scrubbing in
                    if scrubbing {
                        scrubbingPosition = localSliderValue
                    } else {
                        if let newPos = scrubbingPosition {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            spotifyController.seek(to: Int(newPos))
                            scrubbingPosition = nil
                        }
                    }
                }
                .accentColor(.white)
                .onChange(of: localSliderValue) { newValue in
                    if scrubbingPosition != nil {
                        scrubbingPosition = newValue
                    }
                }
                .onChange(of: spotifyController.currentTrackPosition) { newValue in
                    if scrubbingPosition == nil {
                        withAnimation(.linear(duration: 1)) {
                            localSliderValue = Double(newValue)
                        }
                    }
                }
                .onAppear {
                    localSliderValue = Double(spotifyController.currentTrackPosition)
                }

                // Waypoint Markers
                GeometryReader { geometry in
                    ForEach(spotifyController.waypoints) { waypoint in
                        let percentage = CGFloat(waypoint.position) /
                            CGFloat(max(1, spotifyController.currentTrackDuration ?? 1))
                        Circle()
                            .fill(waypoint.color)
                            .frame(width: 6, height: 6)
                            .offset(x: (geometry.size.width * percentage) - 3, y: 12)
                    }
                }
                .frame(height: 12)
                .allowsHitTesting(false)
            }

            HStack {
                Text(Int(localSliderValue).formatAsTime())
                Spacer()

                Button(action: { spotifyController.addWaypoint() }) {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(6)
                        .background(Circle().fill(.white.opacity(0.15)))
                }

                Spacer()
                Text((spotifyController.currentTrackDuration ?? 0).formatAsTime())
            }
            .font(.caption2)
            .foregroundColor(.white.opacity(0.8))
            .monospacedDigit()
        }
    }
}

struct WaypointDock: View {
    @EnvironmentObject var spotifyController: SpotifyController
    @State private var editingWaypoint: Waypoint?

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Waypoints")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(spotifyController.waypoints) { waypoint in
                        Button(action: { spotifyController.seekToWaypoint(waypoint) }) {
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(waypoint.color)
                                    .frame(width: 10, height: 10)
                                Text(waypoint.position.formatAsTime())
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundColor(.white)
                                if let label = waypoint.label, !label.isEmpty {
                                    Text(label)
                                        .font(.system(size: 8, weight: .regular))
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineLimit(1)
                                }
                            }
                            .frame(width: 45)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.1))
                            )
                        }
                        .contextMenu {
                            Button {
                                editingWaypoint = waypoint
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                spotifyController.removeWaypoint(waypoint)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .transition(.chipAppear)
                    }
                }
                .padding(.horizontal, 12)
                .frame(minWidth: 250)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: spotifyController.waypoints)
            }
            .frame(height: 60)
        }
        .frame(width: 250)
        .padding(.vertical, 12)
        .glassBackground()
        .environment(\.colorScheme, .dark)
        .sheet(item: $editingWaypoint) { waypoint in
            WaypointEditSheet(waypoint: waypoint)
                .environmentObject(spotifyController)
        }
    }
}

struct WaypointEditSheet: View {
    @EnvironmentObject var spotifyController: SpotifyController
    let waypoint: Waypoint

    @State private var label: String
    @State private var selectedColorHex: String
    @Environment(\.dismiss) private var dismiss

    private let colorPalette = [
        "#FF5E5E", "#FFBB5C", "#FFD93D", "#6BCB77",
        "#4D96FF", "#B983FF", "#FF869E", "#54BAB9"
    ]

    init(waypoint: Waypoint) {
        self.waypoint = waypoint
        _label = State(initialValue: waypoint.label ?? "")
        _selectedColorHex = State(initialValue: waypoint.colorHex)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Label") {
                    TextField("Optional label", text: $label)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 16) {
                        ForEach(colorPalette, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex) ?? .blue)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColorHex.uppercased() == hex.uppercased() ? 3 : 0)
                                        .padding(2)
                                )
                                .onTapGesture { selectedColorHex = hex }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Edit Waypoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        spotifyController.updateWaypoint(
                            waypoint,
                            label: label.isEmpty ? nil : label,
                            colorHex: selectedColorHex
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Extensions & Modifiers

extension Int {
    func formatAsTime() -> String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

extension View {
    func glassBackground() -> some View {
        self.modifier(GlassBackground())
    }

    func trackTransition(id: String?, duration: Double = 0.3) -> some View {
        self
            .id(id)
            .transition(.opacity)
            .animation(.easeInOut(duration: duration), value: id)
    }
}

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.25)

                    Color.white.opacity(0.10)
                        .blendMode(.overlay)
                }
            }
            .cornerRadius(35)
            .overlay(
                RoundedRectangle(cornerRadius: 35)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.5), location: 0.0),
                                .init(color: .white.opacity(0.1), location: 0.4),
                                .init(color: .clear, location: 0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .blendMode(.overlay)
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

extension AnyTransition {
    static var slideUpFade: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }

    static var chipAppear: AnyTransition {
        .scale(scale: 0.75).combined(with: .opacity)
    }
}

#Preview {
    ContentView()
        .environmentObject(SpotifyController())
}
