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

                // MARK: - Foreground Widget Layer
                VStack {
                    if let trackName = spotifyController.currentTrackName,
                       let trackArtist = spotifyController.currentTrackArtist,
                       let trackImage = spotifyController.currentTrackImage
                    {
                        // Album Art
                        Image(uiImage: trackImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 250, maxHeight: 250)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)

                        // Track Name
                        Text(trackName)
                            .font(.title)
                            .lineLimit(2)
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
                        HStack(spacing: 40) {
                            Button(action: { spotifyController.skipToPrevious() }) {
                                Image(systemName: "backward.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }

                            if spotifyController.isPaused {
                                Button(action: { spotifyController.play() }) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 45))
                                        .foregroundColor(.white)
                                }
                            } else {
                                Button(action: { spotifyController.pause() }) {
                                    Image(systemName: "pause.fill")
                                        .font(.system(size: 45))
                                        .foregroundColor(.white)
                                }
                            }

                            Button(action: { spotifyController.skipToNext() }) {
                                Image(systemName: "forward.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 10)
                        .shadow(radius: 2)

                        // [NEW] Progress Bar Layer
                        VStack(spacing: 5) {
                            ProgressView(
                                value: Double(spotifyController.currentTrackPosition),
                                total: Double(spotifyController.currentTrackDuration ?? 1)
                            )
                            .tint(.white)
                            
                            HStack {
                                Text(formatTime(spotifyController.currentTrackPosition))
                                Spacer()
                                Text(formatTime(spotifyController.currentTrackDuration ?? 0))
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .monospacedDigit() // Prevents jitter when numbers change
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .frame(maxWidth: 250)

                        // Secondary Controls
                        HStack(spacing: 60) {
                            Button(action: { spotifyController.skipBackward() }) {
                                Image(systemName: "gobackward.\(skipInterval)")
                                    .font(.title)
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            Button(action: { spotifyController.skipForward() }) {
                                Image(systemName: "goforward.\(skipInterval)")
                                    .font(.title)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(.top, 5)
                        .shadow(radius: 2)

                    } else {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .padding(30)
                // MARK: - Liquid Glass Modifiers
                .background {
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.25)

                        Color.white.opacity(0.10)
                            .blendMode(.overlay)
                    }
                }
                .environment(\.colorScheme, .dark)
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
                .padding(20)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
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
        }
    }

    // [NEW] Helper function to format seconds into mm:ss
    func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
        .environmentObject(SpotifyController())
}
