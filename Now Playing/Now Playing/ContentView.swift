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
            }
            
            // MARK: - Foreground Widget Layer
            VStack {
                if let trackName = spotifyController.currentTrackName,
                   let trackArtist = spotifyController.currentTrackArtist,
                   let trackImage = spotifyController.currentTrackImage {
                    
                    Image(uiImage: trackImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 250, maxHeight: 250)
                        .cornerRadius(25)
                        .shadow(radius: 10) // Optional: Adds a nice depth to the album art

                    Text(trackName)
                        .font(.title)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(width: 250)
                    
                    Text(trackArtist)
                        .font(.headline)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 250)
                    
                    // Main Controls (Play/Pause, Next/Prev Track)
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
                    
                    // Secondary Controls (Skip 15s)
                    HStack(spacing: 60) {
                        Button(action: { spotifyController.skipBackward() }) {
                            Image(systemName: "gobackward.15")
                                .font(.title) // Slightly smaller font than main controls
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Button(action: { spotifyController.skipForward() }) {
                            Image(systemName: "goforward.15")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.top, 20)
                    
                } else {
                    // Fallback state
                    ProgressView()
                        .tint(.white)
                }
            }
            .padding(30)
            .background(Color.gray.opacity(0.25))
            .shadow(radius: 10)
            .cornerRadius(25)
            .padding(20)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SpotifyController())
}
