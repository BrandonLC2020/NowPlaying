//
//  AuthorizationView.swift
//  Now Playing
//
//  Created by Brandon Lamer-Connolly on 1/3/26.
//

import SwiftUI

struct AuthorizationView: View {
    @EnvironmentObject var spotifyController: SpotifyController

    var body: some View {
        VStack {
            Image("AppIcon")
                .resizable()
                .cornerRadius(30.0)
                .scaledToFill()
                .frame(width: 200, height: 200)
                .padding()
            Button("Connect to Spotify") {
                spotifyController.authorize()
            }
            .font(.headline)
            .padding()
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AuthorizationView()
        .environmentObject(SpotifyController())
}
