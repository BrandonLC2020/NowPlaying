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
                    .overlay(Color.black.opacity(0.3))  // Darkens bg slightly so "liquid" pops
            }

            // MARK: - Foreground Widget Layer
            VStack {
                if let trackName = spotifyController.currentTrackName,
                    let trackArtist = spotifyController.currentTrackArtist,
                    let trackImage = spotifyController.currentTrackImage
                {

                    Image(uiImage: trackImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 250, maxHeight: 250)
                        .cornerRadius(25)
                        .shadow(
                            color: .black.opacity(0.3),
                            radius: 15,
                            x: 0,
                            y: 10
                        )

                    Text(trackName)
                        .font(.title)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .shadow(radius: 2)  // Adds legibility on glass

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
                    .padding(.top, 20)
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
                    // 1. The Blur: Lower opacity = less "frost", more clarity
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.25)  // 50% opacity makes it look like clear water, not frosted glass

                    // 2. The Tint: Adds a tiny bit of white 'substance' so it's not invisible
                    Color.white.opacity(0.10)
                        .blendMode(.overlay)
                }
            }
            .environment(\.colorScheme, .dark)  // Keeps text/icons white
            .cornerRadius(35)
            .overlay(
                // The "Surface Tension" Border
                RoundedRectangle(cornerRadius: 35)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(
                                    color: .white.opacity(0.5),
                                    location: 0.0
                                ),  // Top left highlight
                                .init(
                                    color: .white.opacity(0.1),
                                    location: 0.4
                                ),
                                .init(color: .clear, location: 0.6),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1  // Thinner line for a sharper, wet look
                    )
                    .blendMode(.overlay)  // Helps the border blend into the background colors
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(20)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SpotifyController())
}
