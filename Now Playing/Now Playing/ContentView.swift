//
//  ContentView.swift
//  Now Playing
//
//  Created by Brandon Lamer-Connolly on 10/25/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var spotifyController: SpotifyController

    var body: some View {
        ZStack {
            // MARK: - Background Layer
            if let trackImage = spotifyController.currentTrackImage {
                Image(uiImage: trackImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .blur(radius: 40)
                    .overlay(Color.black.opacity(0.3))
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
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                        } else {
                            Button(action: { spotifyController.pause() }) {
                                Image(systemName: "pause.fill")
                                    .font(.largeTitle)
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
                            Image(systemName: "gobackward.15")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.9))
                        }

                        Button(action: { spotifyController.skipForward() }) {
                            Image(systemName: "goforward.15")
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
