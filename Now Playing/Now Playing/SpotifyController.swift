//
//  SpotifyController.swift
//  Now Playing
//
//  Created by Brandon Lamer-Connolly on 7/19/24.
//

import Combine
import SpotifyiOS
import SwiftUI

@MainActor
final class SpotifyController: NSObject, ObservableObject {
    let spotifyClientID =
        Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_API_CLIENT_ID")
        as? String
    let spotifyRedirectURL = URL(
        string: "spotify-ios-quick-start://spotify-login-callback"
    )!

    var accessToken: String?
    @Published var currentTrackURI: String?
    @Published var currentTrackName: String?
    @Published var currentTrackArtist: String?
    @Published var currentTrackDuration: Int?
    @Published var currentTrackImage: UIImage?
    @Published var isPaused: Bool = true

    @Published var currentTrackPosition: Int = 0
    private var timer: Timer?

    private var connectCancellable: AnyCancellable?

    private var disconnectCancellable: AnyCancellable?

    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)

        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
        } else if (parameters?[SPTAppRemoteErrorDescriptionKey]) != nil {
            // Handle the error
        }
    }

    func authorize() {
        self.appRemote.authorizeAndPlayURI("")
    }

    lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID!,
        redirectURL: spotifyRedirectURL
    )

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(
            configuration: configuration,
            logLevel: .debug
        )
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    func connect() {
        if self.appRemote.connectionParameters.accessToken != nil {
            appRemote.connect()
        }
    }

    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }

    override init() {
        super.init()
        connectCancellable = NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification
        )
        .receive(on: DispatchQueue.main)
        .sink { _ in
            self.connect()
        }

        disconnectCancellable = NotificationCenter.default.publisher(
            for: UIApplication.willResignActiveNotification
        )
        .receive(on: DispatchQueue.main)
        .sink { _ in
            self.disconnect()
        }
    }

    func fetchImage() {
        appRemote.playerAPI?.getPlayerState { (result, error) in
            if let error = error {
                print("Error getting player state: \(error)")
            } else if let playerState = result as? SPTAppRemotePlayerState {
                self.appRemote.imageAPI?.fetchImage(
                    forItem: playerState.track,
                    with: CGSize(width: 300, height: 300),
                    callback: { (image, error) in
                        if let error = error {
                            print(
                                "Error fetching track image: \(error.localizedDescription)"
                            )
                        } else if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.currentTrackImage = image
                            }
                        }
                    }
                )
            }
        }
    }

    func skipToPrevious() {
        appRemote.playerAPI?.skip(toPrevious: { [weak self] result, error in
            if let error = error {
                print(
                    "Error skipping to previous: \(error.localizedDescription)"
                )
            }
        })
    }

    func play() {
        appRemote.playerAPI?.resume({ [weak self] result, error in
            if let error = error {
                print("Error playing: \(error.localizedDescription)")
            }
        })
    }

    func pause() {
        appRemote.playerAPI?.pause({ [weak self] result, error in
            if let error = error {
                print("Error pausing: \(error.localizedDescription)")
            }
        })
    }

    func skipToNext() {
        appRemote.playerAPI?.skip(toNext: { [weak self] result, error in
            if let error = error {
                print("Error skipping to next: \(error.localizedDescription)")
            }
        })
    }

    func skipBackward() {
        appRemote.playerAPI?.getPlayerState { (result, error) in
            if let error = error {
                print(
                    "Error getting player state: \(error.localizedDescription)"
                )
            } else if let playerState = result as? SPTAppRemotePlayerState {
                let currentPosition = playerState.playbackPosition
                let newPosition = max(0, currentPosition - 15000)  // Ensure we don't go below 0

                self.appRemote.playerAPI?.seek(
                    toPosition: newPosition,
                    callback: { (result, error) in
                        if let error = error {
                            print(
                                "Error seeking backward: \(error.localizedDescription)"
                            )
                        }
                    }
                )
            }
        }
    }

    func skipForward() {
        appRemote.playerAPI?.getPlayerState { (result, error) in
            if let error = error {
                print(
                    "Error getting player state: \(error.localizedDescription)"
                )
            } else if let playerState = result as? SPTAppRemotePlayerState {
                let currentPosition = playerState.playbackPosition
                let newPosition = currentPosition + 15000
                // Note: If newPosition > track duration, Spotify usually handles it by skipping to next.

                self.appRemote.playerAPI?.seek(
                    toPosition: newPosition,
                    callback: { (result, error) in
                        if let error = error {
                            print(
                                "Error seeking forward: \(error.localizedDescription)"
                            )
                        }
                    }
                )
            }
        }
    }
    // [NEW] Timer Methods
    private func startTimer() {
        stopTimer()  // Prevent duplicate timers
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] _ in
            guard let self = self else { return }
            if self.currentTrackPosition
                < (self.currentTrackDuration ?? Int.max)
            {
                self.currentTrackPosition += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension SpotifyController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                print(
                    "Error subscribing to player state: \(error.localizedDescription)"
                )
            } else {
                print("Successfully subscribed to player state")
            }
        })
    }

    func appRemote(
        _ appRemote: SPTAppRemote,
        didFailConnectionAttemptWithError error: Error?
    ) {
        // Handle the connection failure
    }

    func appRemote(
        _ appRemote: SPTAppRemote,
        didDisconnectWithError error: Error?
    ) {
        // Handle the connection loss
    }
}

extension SpotifyController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.currentTrackURI = playerState.track.uri
        self.currentTrackName = playerState.track.name
        self.currentTrackArtist = playerState.track.artist.name
        self.currentTrackDuration = Int(playerState.track.duration) / 1000
        self.isPaused = playerState.isPaused

        // [NEW] Update position and manage timer
        self.currentTrackPosition = Int(playerState.playbackPosition) / 1000

        if self.isPaused {
            stopTimer()
        } else {
            startTimer()
        }

        fetchImage()
    }
}
