//
//  Now_PlayingApp.swift
//  Now Playing
//
//  Created by Brandon Lamer-Connolly on 10/25/23.
//

import SwiftUI

@main
struct Now_PlayingApp: App {
    @StateObject var spotifyController = SpotifyController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotifyController)
                .onOpenURL { url in
                    spotifyController.setAccessToken(from: url)
                }
        }
    }
}
