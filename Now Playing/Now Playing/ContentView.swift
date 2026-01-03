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
        VStack {
            if let trackName = spotifyController.currentTrackName,
               let trackArtist = spotifyController.currentTrackArtist {
                if let trackImage = spotifyController.currentTrackImage {
                    Image(uiImage: trackImage)
                        .resizable()
                        .frame(width: 300, height: 300)
                }
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
                Button("Connect to Spotify") {
                    spotifyController.authorize()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(SpotifyController())
}
