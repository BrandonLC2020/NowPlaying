//
//  SpotifyController.swift
//  Now Playing
//
//  Created by Brandon Lamer-Connolly on 7/19/24.
//

import Combine
import SpotifyiOS
import SwiftUI
import WidgetKit

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
    @Published var currentUserDisplayName: String?
    @Published var currentUserImage: UIImage?
    @Published var isPaused: Bool = true {
        didSet { saveState() }
    }

    @Published var currentTrackPosition: Int = 0
    @Published var skipInterval: Int = 15
    @Published var waypoints: [Waypoint] = []
    @Published var isShuffling: Bool = false
    @Published var repeatMode: UInt = 0
    private var timer: Timer?

    private var connectCancellable: AnyCancellable?

    // Predefined colors for waypoints
    private let waypointColors = [
        "#FF5E5E", "#FFBB5C", "#FFD93D", "#6BCB77", "#4D96FF", "#B983FF", "#FF869E", "#54BAB9"
    ]

    func addWaypoint() {
        let position = currentTrackPosition
        // Prevent duplicate waypoints at same second
        guard !waypoints.contains(where: { $0.position == position }) else { return }

        let colorHex = waypointColors[waypoints.count % waypointColors.count]
        let newWaypoint = Waypoint(position: position, colorHex: colorHex)
        waypoints.append(newWaypoint)
        waypoints.sort { $0.position < $1.position }
        print("Waypoint added: \(newWaypoint.position)s. Total waypoints: \(waypoints.count)")
        saveWaypoints()
    }

    func seek(to seconds: Int) {
        appRemote.playerAPI?.seek(toPosition: seconds * 1000, callback: { (_, error) in
            if let error = error {
                print("Error seeking: \(error.localizedDescription)")
            }
        })
    }

    func seekToWaypoint(_ waypoint: Waypoint) {
        seek(to: waypoint.position)
    }

    func removeWaypoint(_ waypoint: Waypoint) {
        waypoints.removeAll { $0.id == waypoint.id }
        saveWaypoints()
    }

    private func saveWaypoints() {
        guard let trackURI = currentTrackURI else { return }
        if let encoded = try? JSONEncoder().encode(waypoints) {
            UserDefaults.standard.set(encoded, forKey: "waypoints_\(trackURI)")
        }
    }

    private func loadWaypoints(for trackURI: String) {
        if let data = UserDefaults.standard.data(forKey: "waypoints_\(trackURI)"),
           let decoded = try? JSONDecoder().decode([Waypoint].self, from: data) {
            self.waypoints = decoded
        } else {
            self.waypoints = []
        }
    }

    private var disconnectCancellable: AnyCancellable?

    private func saveState() {
        let state = PlaybackState(
            trackName: currentTrackName ?? "Not Playing",
            artistName: currentTrackArtist ?? "Unknown Artist",
            isPaused: isPaused,
            trackURI: currentTrackURI ?? "",
            duration: currentTrackDuration ?? 0,
            position: currentTrackPosition,
            lastUpdated: Date()
        )
        PlaybackStateManager.shared.save(state)
        PlaybackStateManager.shared.saveImage(currentTrackImage)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)

        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
            fetchUserProfile()
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

    func logout() {
        disconnect()
        self.accessToken = nil
        self.currentTrackName = nil
        self.currentTrackArtist = nil
        self.currentTrackImage = nil
        self.currentUserDisplayName = nil
        self.currentUserImage = nil
        self.currentTrackURI = nil
        self.waypoints = []
        self.appRemote.connectionParameters.accessToken = nil
        stopTimer()
        PlaybackStateManager.shared.clear()
        saveState()
    }

    private func fetchUserProfile() {
        guard let accessToken = self.accessToken else { return }

        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                   if let displayName = json["display_name"] as? String {
                        DispatchQueue.main.async {
                            self.currentUserDisplayName = displayName
                        }
                    }

                    if let images = json["images"] as? [[String: Any]],
                       let firstImage = images.first,
                       let imageUrl = firstImage["url"] as? String {
                        Task { @MainActor in
                            self.fetchUserImage(from: imageUrl)
                        }
                    }
                }
            } catch {
                print("Error decoding user profile: \(error)")
            }
        }.resume()
    }

    private func fetchUserImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.currentUserImage = image
            }
        }.resume()
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
        appRemote.playerAPI?.skip(toPrevious: { [weak self] _, error in
            if let error = error {
                print(
                    "Error skipping to previous: \(error.localizedDescription)"
                )
            }
        })
    }

    func play() {
        appRemote.playerAPI?.resume({ [weak self] _, error in
            if let error = error {
                print("Error playing: \(error.localizedDescription)")
            }
        })
    }

    func pause() {
        appRemote.playerAPI?.pause({ [weak self] _, error in
            if let error = error {
                print("Error pausing: \(error.localizedDescription)")
            }
        })
    }

    func skipToNext() {
        appRemote.playerAPI?.skip(toNext: { [weak self] _, error in
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
                let newPosition = max(0, currentPosition - (self.skipInterval * 1000))  // Ensure we don't go below 0

                self.appRemote.playerAPI?.seek(
                    toPosition: newPosition,
                    callback: { (_, error) in
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
                let newPosition = currentPosition + (self.skipInterval * 1000)
                // Note: If newPosition > track duration, Spotify usually handles it by skipping to next.

                self.appRemote.playerAPI?.seek(
                    toPosition: newPosition,
                    callback: { (_, error) in
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

    func toggleShuffle() {
        appRemote.playerAPI?.setShuffle(!isShuffling, callback: { _, error in
            if let error = error {
                print("Error setting shuffle: \(error.localizedDescription)")
            }
        })
    }

    func toggleRepeat() {
        appRemote.playerAPI?.getPlayerState { (result, error) in
            if let playerState = result as? SPTAppRemotePlayerState {
                let currentMode = playerState.playbackOptions.repeatMode
                var nextMode = currentMode

                // Cycle: off (0) -> track (1) -> context (2) -> off (0)
                if currentMode.rawValue == 0 {
                    nextMode = .track
                } else if currentMode.rawValue == 1 {
                    nextMode = .context
                } else {
                    nextMode = .off
                }

                self.appRemote.playerAPI?.setRepeatMode(nextMode, callback: { _, error in
                    if let error = error {
                        print("Error setting repeat mode: \(error.localizedDescription)")
                    }
                })
            }
        }
    }

    // [NEW] Timer Methods
    private func startTimer() {
        stopTimer()  // Prevent duplicate timers
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.currentTrackPosition
                    < (self.currentTrackDuration ?? Int.max) {
                    self.currentTrackPosition += 1
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension SpotifyController: @preconcurrency SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (_, error) in
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

extension SpotifyController: @preconcurrency SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        let oldURI = self.currentTrackURI
        self.currentTrackURI = playerState.track.uri

        if oldURI != self.currentTrackURI, let newURI = self.currentTrackURI {
            loadWaypoints(for: newURI)
        }

        self.currentTrackName = playerState.track.name
        self.currentTrackArtist = playerState.track.artist.name
        self.currentTrackDuration = Int(playerState.track.duration) / 1000
        self.isPaused = playerState.isPaused
        self.isShuffling = playerState.playbackOptions.isShuffling
        self.repeatMode = playerState.playbackOptions.repeatMode.rawValue

        // [NEW] Update position and manage timer
        self.currentTrackPosition = Int(playerState.playbackPosition) / 1000

        if self.isPaused {
            stopTimer()
        } else {
            startTimer()
        }

        fetchImage()
        saveState()
    }
}
