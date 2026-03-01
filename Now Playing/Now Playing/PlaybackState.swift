//
//  PlaybackState.swift
//  Now Playing
//
//  Created by Gemini on 2/28/26.
//

import Foundation
import SwiftUI

struct PlaybackState: Codable {
    var trackName: String
    var artistName: String
    var isPaused: Bool
    var trackURI: String
    var duration: Int
    var position: Int
    var lastUpdated: Date
    
    static let empty = PlaybackState(
        trackName: "Not Playing",
        artistName: "Unknown Artist",
        isPaused: true,
        trackURI: "",
        duration: 0,
        position: 0,
        lastUpdated: Date()
    )
}

class PlaybackStateManager {
    static let shared = PlaybackStateManager()
    
    // In a real app, you'd use an App Group ID here
    private let suiteName = "group.com.brandonlamer-connolly.nowplaying"
    private let storageKey = "playbackState"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    func save(_ state: PlaybackState) {
        if let encoded = try? JSONEncoder().encode(state) {
            sharedDefaults?.set(encoded, forKey: storageKey)
            // Also save to standard for local use if needed
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func load() -> PlaybackState {
        let data = sharedDefaults?.data(forKey: storageKey) ?? UserDefaults.standard.data(forKey: storageKey)
        if let data = data, let decoded = try? JSONDecoder().decode(PlaybackState.self, from: data) {
            return decoded
        }
        return .empty
    }
    
    func saveImage(_ image: UIImage?) {
        guard let image = image, let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)?
            .appendingPathComponent("currentTrackImage.jpg")
        
        // Fallback to caches if App Group is not available
        let fallbackURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("currentTrackImage.jpg")
        
        try? data.write(to: url ?? fallbackURL!)
    }
    
    func loadImage() -> UIImage? {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)?
            .appendingPathComponent("currentTrackImage.jpg")
        
        let fallbackURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("currentTrackImage.jpg")
        
        if let data = try? Data(contentsOf: url ?? fallbackURL!) {
            return UIImage(data: data)
        }
        return nil
    }
}
