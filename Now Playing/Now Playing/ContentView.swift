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

    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Background Layer
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
                        } else {
                            Color.black.ignoresSafeArea()
                        }
                    }
                }

                // MARK: - Foreground Layer
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // Main Content
                        VStack {
                            if let trackName = spotifyController.currentTrackName,
                               let trackArtist = spotifyController.currentTrackArtist,
                               let trackImage = spotifyController.currentTrackImage
                            {
                                // Album Art - Slightly smaller to fit everything
                                Image(uiImage: trackImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

                                // Track Name
                                Text(trackName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(width: 250)
                                    .shadow(radius: 2)

                                // Artist Name
                                Text(trackArtist)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.9))
                                    .frame(width: 250)
                                    .shadow(radius: 2)

                                // Main Controls
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

                                    if spotifyController.isPaused {
                                        Button(action: { spotifyController.play() }) {
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        Button(action: { spotifyController.pause() }) {
                                            Image(systemName: "pause.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white)
                                        }
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
                                .padding(.top, 5)

                                // Progress Bar Layer
                                VStack(spacing: 4) {
                                    ZStack(alignment: .leading) {
                                        ProgressView(
                                            value: Double(spotifyController.currentTrackPosition),
                                            total: Double(spotifyController.currentTrackDuration ?? 1)
                                        )
                                        .tint(.white)
                                        
                                        // Waypoint Markers
                                        GeometryReader { geometry in
                                            ForEach(spotifyController.waypoints) { waypoint in
                                                let percentage = CGFloat(waypoint.position) / CGFloat(spotifyController.currentTrackDuration ?? 1)
                                                Circle()
                                                    .fill(waypoint.color)
                                                    .frame(width: 6, height: 6)
                                                    .offset(x: (geometry.size.width * percentage) - 3, y: 12)
                                            }
                                        }
                                        .frame(height: 12)
                                    }
                                    
                                    HStack {
                                        Text(formatTime(spotifyController.currentTrackPosition))
                                        Spacer()
                                        
                                        Button(action: { spotifyController.addWaypoint() }) {
                                            Image(systemName: "flag.fill")
                                                .foregroundColor(.white)
                                                .font(.caption)
                                                .padding(6)
                                                .background(Circle().fill(.white.opacity(0.15)))
                                        }
                                        
                                        Spacer()
                                        Text(formatTime(spotifyController.currentTrackDuration ?? 0))
                                    }
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                    .monospacedDigit()
                                }
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
                                                    Text(formatTime(waypoint.position))
                                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                                        .foregroundColor(.white)
                                                }
                                                .frame(width: 45)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(.white.opacity(0.1))
                                                )
                                            }
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    spotifyController.removeWaypoint(waypoint)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .frame(minWidth: 250) // Center items when they don't fill the dock
                                }
                                .frame(height: 50)
                            }
                            .frame(width: 250)
                            .padding(.vertical, 12)
                            .glassBackground()
                            .environment(\.colorScheme, .dark)
                        }
                    }
                    .padding(20)
                    
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
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
        }
    }

    // [NEW] Helper function to format seconds into mm:ss
    func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

extension View {
    func glassBackground() -> some View {
        self.modifier(GlassBackground())
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
                                .init(color: .clear, location: 0.6),
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

#Preview {
    ContentView()
        .environmentObject(SpotifyController())
}
