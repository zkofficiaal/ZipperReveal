//
//  ZipperRevealViewModel.swift
//  ZipperReveal
//
//  Created by Z.K   on 11/09/2026.
//  ViewModel responsible for zipper animation playback.
//

import Foundation
import Combine
import SwiftUI

/// Controls the zipper reveal animation.
@MainActor
final class ZipperRevealViewModel: ObservableObject {

    // MARK: - Published State

    /// Controls whether the animation is running.
    @Published private(set) var isPlaying: Bool = true

    // MARK: - Configuration

    /// Central zipper configuration.
    let configuration =
        ZipperConfiguration()

    // MARK: - Animation Service

    /// Calculates animation progress.
    private let animationService:
        ZipperAnimationService

    // MARK: - Timing

    /// Time at which the animation timeline started.
    private var startDate: Date

    /// Elapsed timeline position when paused.
    private var pausedElapsedTime: TimeInterval = 0

    // MARK: - Initialization

    init() {

        let configuration =
            ZipperConfiguration()

        self.configuration =
            configuration

        self.animationService =
            ZipperAnimationService(
                configuration: configuration
            )

        self.startDate =
            Date()
    }

    // MARK: - Current State

    /// Returns the current animation state for a specific timeline date.
    func state(
        at date: Date
    ) -> ZipperAnimationState {

        let elapsedTime: TimeInterval

        if isPlaying {

            elapsedTime =
                date.timeIntervalSince(
                    startDate
                )

        } else {

            elapsedTime =
                pausedElapsedTime
        }

        return animationService.state(
            at: elapsedTime
        )
    }

    // MARK: - Play / Pause

    /// Toggles animation playback.
    func togglePlayback() {

        if isPlaying {

            pause()

        } else {

            play()
        }
    }

    /// Pauses the animation at its current position.
    func pause() {

        guard isPlaying else {
            return
        }

        pausedElapsedTime =
            Date()
            .timeIntervalSince(
                startDate
            )

        isPlaying = false
    }

    /// Resumes the animation from the paused position.
    func play() {

        guard !isPlaying else {
            return
        }

        startDate =
            Date()
            .addingTimeInterval(
                -pausedElapsedTime
            )

        isPlaying = true
    }

    // MARK: - Reset

    /// Resets the zipper to the beginning of the animation.
    func reset() {

        pausedElapsedTime = 0

        startDate = Date()

        isPlaying = true
    }
}
