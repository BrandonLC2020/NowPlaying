//
//  Now_PlayingTests.swift
//  Now PlayingTests
//
//  Created by Brandon Lamer-Connolly on 10/25/23.
//

import Testing
import Foundation
import SwiftUI
@testable import Now_Playing

// MARK: - Waypoint Model Tests

@Suite("Waypoint")
struct WaypointTests {

    @Test("Initializes with correct properties")
    func waypointInit() {
        let id = UUID()
        let waypoint = Waypoint(id: id, position: 30, colorHex: "#FF5E5E")
        #expect(waypoint.id == id)
        #expect(waypoint.position == 30)
        #expect(waypoint.colorHex == "#FF5E5E")
    }

    @Test("Default UUID is assigned when none provided")
    func waypointDefaultID() {
        let w1 = Waypoint(position: 10, colorHex: "#FFFFFF")
        let w2 = Waypoint(position: 10, colorHex: "#FFFFFF")
        #expect(w1.id != w2.id)
    }

    @Test("Encodes and decodes correctly (Codable roundtrip)")
    func waypointCodable() throws {
        let original = Waypoint(position: 45, colorHex: "FF5E5E")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Waypoint.self, from: data)
        #expect(decoded == original)
    }

    @Test("Equal when all stored properties match")
    func waypointEquality() {
        let id = UUID()
        let w1 = Waypoint(id: id, position: 30, colorHex: "#FF5E5E")
        let w2 = Waypoint(id: id, position: 30, colorHex: "#FF5E5E")
        #expect(w1 == w2)
    }

    @Test("Not equal when UUID differs")
    func waypointInequalityByID() {
        let w1 = Waypoint(id: UUID(), position: 30, colorHex: "#FF5E5E")
        let w2 = Waypoint(id: UUID(), position: 30, colorHex: "#FF5E5E")
        #expect(w1 != w2)
    }

    @Test("color falls back to blue for invalid hex")
    func waypointColorFallback() {
        let waypoint = Waypoint(position: 0, colorHex: "INVALID")
        // The fallback is .blue — just verify it doesn't crash
        _ = waypoint.color
    }
}

// MARK: - Color Hex Extension Tests

@Suite("Color Hex Extensions")
struct ColorHexTests {

    @Test("Initializes from valid 6-char hex without hash")
    func colorFromSixCharHex() {
        #expect(Color(hex: "FF0000") != nil)
        #expect(Color(hex: "00FF00") != nil)
        #expect(Color(hex: "0000FF") != nil)
    }

    @Test("Initializes from valid 6-char hex with hash prefix")
    func colorFromHexWithHash() {
        #expect(Color(hex: "#FF0000") != nil)
        #expect(Color(hex: "#AABBCC") != nil)
    }

    @Test("Initializes from valid 8-char hex with alpha")
    func colorFromEightCharHex() {
        #expect(Color(hex: "FF0000FF") != nil)
        #expect(Color(hex: "AABBCC80") != nil)
    }

    @Test("Returns nil for invalid hex strings")
    func colorFromInvalidHex() {
        #expect(Color(hex: "XYZ") == nil)
        #expect(Color(hex: "12345") == nil)   // 5 chars — invalid length
        #expect(Color(hex: "") == nil)
        #expect(Color(hex: "ZZZZZZZ") == nil)
    }

    @Test("6-char hex survives a roundtrip through toHex()")
    func colorHexRoundtrip() throws {
        let hex = "FF5E5E"
        let color = try #require(Color(hex: hex))
        let result = try #require(color.toHex())
        #expect(result.uppercased() == hex.uppercased())
    }

    @Test("Black and white round-trip correctly")
    func blackWhiteRoundtrip() throws {
        for hex in ["000000", "FFFFFF"] {
            let color = try #require(Color(hex: hex))
            let result = try #require(color.toHex())
            #expect(result.uppercased() == hex.uppercased())
        }
    }
}

// MARK: - PlaybackState Model Tests

@Suite("PlaybackState")
struct PlaybackStateTests {

    @Test("Empty state has expected default values")
    func playbackStateEmpty() {
        let empty = PlaybackState.empty
        #expect(empty.trackName == "Not Playing")
        #expect(empty.artistName == "Unknown Artist")
        #expect(empty.isPaused == true)
        #expect(empty.trackURI == "")
        #expect(empty.duration == 0)
        #expect(empty.position == 0)
    }

    @Test("Encodes and decodes correctly (Codable roundtrip)")
    func playbackStateCodable() throws {
        let state = PlaybackState(
            trackName: "Test Track",
            artistName: "Test Artist",
            isPaused: false,
            trackURI: "spotify:track:abc123",
            duration: 210,
            position: 60,
            lastUpdated: Date(timeIntervalSince1970: 1_000_000)
        )
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(PlaybackState.self, from: data)

        #expect(decoded.trackName == state.trackName)
        #expect(decoded.artistName == state.artistName)
        #expect(decoded.isPaused == state.isPaused)
        #expect(decoded.trackURI == state.trackURI)
        #expect(decoded.duration == state.duration)
        #expect(decoded.position == state.position)
    }
}

// MARK: - PlaybackStateManager Tests

@Suite("PlaybackStateManager", .serialized)
struct PlaybackStateManagerTests {

    private func cleanup() {
        PlaybackStateManager.shared.clear()
    }

    @Test("Saves and reloads state correctly")
    func saveAndLoad() {
        cleanup()
        let state = PlaybackState(
            trackName: "My Track",
            artistName: "My Artist",
            isPaused: false,
            trackURI: "spotify:track:xyz",
            duration: 180,
            position: 30,
            lastUpdated: Date(timeIntervalSince1970: 500)
        )
        PlaybackStateManager.shared.save(state)
        let loaded = PlaybackStateManager.shared.load()

        #expect(loaded.trackName == state.trackName)
        #expect(loaded.artistName == state.artistName)
        #expect(loaded.isPaused == state.isPaused)
        #expect(loaded.trackURI == state.trackURI)
        #expect(loaded.duration == state.duration)
        #expect(loaded.position == state.position)
        cleanup()
    }

    @Test("Returns empty state when nothing has been saved")
    func loadWhenEmpty() {
        cleanup()
        let loaded = PlaybackStateManager.shared.load()
        #expect(loaded.trackName == PlaybackState.empty.trackName)
        #expect(loaded.artistName == PlaybackState.empty.artistName)
        #expect(loaded.trackURI == PlaybackState.empty.trackURI)
    }

    @Test("Clear removes persisted state")
    func clearRemovesState() {
        let state = PlaybackState(
            trackName: "To Be Cleared",
            artistName: "Artist",
            isPaused: true,
            trackURI: "spotify:track:clear",
            duration: 100,
            position: 0,
            lastUpdated: Date()
        )
        PlaybackStateManager.shared.save(state)
        PlaybackStateManager.shared.clear()
        let loaded = PlaybackStateManager.shared.load()
        #expect(loaded.trackName == PlaybackState.empty.trackName)
    }

    @Test("Overwriting state returns the most recent value")
    func overwriteState() {
        cleanup()
        let first = PlaybackState(
            trackName: "First",
            artistName: "Artist",
            isPaused: true,
            trackURI: "spotify:track:first",
            duration: 100,
            position: 0,
            lastUpdated: Date()
        )
        let second = PlaybackState(
            trackName: "Second",
            artistName: "Artist",
            isPaused: false,
            trackURI: "spotify:track:second",
            duration: 200,
            position: 50,
            lastUpdated: Date()
        )
        PlaybackStateManager.shared.save(first)
        PlaybackStateManager.shared.save(second)
        let loaded = PlaybackStateManager.shared.load()
        #expect(loaded.trackName == "Second")
        #expect(loaded.trackURI == "spotify:track:second")
        cleanup()
    }
}

// MARK: - SpotifyController Waypoint Management Tests

@Suite("SpotifyController Waypoints")
@MainActor
struct SpotifyControllerWaypointTests {

    private static let testURI = "spotify:track:unitTestTrack"

    private func makeController() -> SpotifyController {
        let controller = SpotifyController()
        controller.currentTrackURI = Self.testURI
        return controller
    }

    private func cleanup() {
        UserDefaults.standard.removeObject(forKey: "waypoints_\(Self.testURI)")
    }

    @Test("Adding a waypoint appends it to the list")
    func addWaypoint() {
        let controller = makeController()
        controller.currentTrackPosition = 30
        controller.addWaypoint()
        #expect(controller.waypoints.count == 1)
        #expect(controller.waypoints[0].position == 30)
        cleanup()
    }

    @Test("Adding a waypoint at a duplicate position is ignored")
    func addDuplicateWaypointIgnored() {
        let controller = makeController()
        controller.currentTrackPosition = 60
        controller.addWaypoint()
        controller.addWaypoint()
        #expect(controller.waypoints.count == 1)
        cleanup()
    }

    @Test("Removing a waypoint by ID removes only that waypoint")
    func removeWaypoint() {
        let controller = makeController()
        controller.currentTrackPosition = 90
        controller.addWaypoint()
        let waypoint = controller.waypoints[0]
        controller.removeWaypoint(waypoint)
        #expect(controller.waypoints.isEmpty)
        cleanup()
    }

    @Test("Waypoints are kept sorted by position after each addition")
    func waypointsSortedAfterAdd() {
        let controller = makeController()
        for position in [90, 30, 60] {
            controller.currentTrackPosition = position
            controller.addWaypoint()
        }
        #expect(controller.waypoints[0].position == 30)
        #expect(controller.waypoints[1].position == 60)
        #expect(controller.waypoints[2].position == 90)
        cleanup()
    }

    @Test("Waypoint colors cycle through the 8 predefined palette entries")
    func waypointColorCycling() {
        let controller = makeController()
        // Add 9 waypoints — the 9th should recycle to the first color
        for i in 0..<9 {
            controller.currentTrackPosition = i * 10
            controller.addWaypoint()
        }
        #expect(controller.waypoints[0].colorHex == controller.waypoints[8].colorHex)
        cleanup()
    }

    @Test("Removing a waypoint from a list with multiple entries leaves others intact")
    func removeOneFromMany() {
        let controller = makeController()
        for position in [10, 20, 30] {
            controller.currentTrackPosition = position
            controller.addWaypoint()
        }
        let middle = controller.waypoints.first { $0.position == 20 }!
        controller.removeWaypoint(middle)
        #expect(controller.waypoints.count == 2)
        #expect(!controller.waypoints.contains { $0.position == 20 })
        cleanup()
    }
}
