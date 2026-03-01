//
//  PlaybackControlIntents.swift
//  Now Playing
//
//  Created by Gemini on 2/28/26.
//

import AppIntents
import WidgetKit

struct PlayPauseIntent: AppIntent {
    static var title: LocalizedStringResource = "Play/Pause"
    static var description = IntentDescription("Toggles playback.")
    
    func perform() async throws -> some IntentResult {
        // Here we'd ideally trigger the SpotifyController
        // But SpotifyRemote requires a session.
        // For now, let's just update the state and widget
        let state = PlaybackStateManager.shared.load()
        var newState = state
        newState.isPaused.toggle()
        newState.lastUpdated = Date()
        PlaybackStateManager.shared.save(newState)
        
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct SkipNextIntent: AppIntent {
    static var title: LocalizedStringResource = "Skip Next"
    static var description = IntentDescription("Skips to the next track.")
    
    func perform() async throws -> some IntentResult {
        // Increment track position or something to simulate
        var state = PlaybackStateManager.shared.load()
        state.lastUpdated = Date()
        PlaybackStateManager.shared.save(state)
        
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct SkipPreviousIntent: AppIntent {
    static var title: LocalizedStringResource = "Skip Previous"
    static var description = IntentDescription("Skips to the previous track.")
    
    func perform() async throws -> some IntentResult {
        var state = PlaybackStateManager.shared.load()
        state.lastUpdated = Date()
        PlaybackStateManager.shared.save(state)
        
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
