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
            if let trackImage = spotifyController.currentTrackImage {
                Image(uiImage: trackImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .blur(radius: 40)
            }
            
            VStack {
                if let trackName = spotifyController.currentTrackName,
                   let trackArtist = spotifyController.currentTrackArtist {
                    Text(trackName)
                        .font(.title)
                    Text(trackArtist)
                        .font(.headline)
                    HStack(spacing: 40) {
                        Button(action: { spotifyController.skipToPrevious() }) {
                            Image(systemName: "backward.fill")
                                .font(.largeTitle)
                        }
                        Button(action: { spotifyController.play() }) {
                            Image(systemName: "play.fill")
                                .font(.largeTitle)
                        }
                        Button(action: { spotifyController.pause() }) {
                            Image(systemName: "pause.fill")
                                .font(.largeTitle)
                        }
                        Button(action: { spotifyController.skipToNext() }) {
                            Image(systemName: "forward.fill")
                                .font(.largeTitle)
                        }
                    }
                } else {
                    // Fallback or loading state if needed, though App logic handles switching
                    ProgressView()
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SpotifyController())
}
