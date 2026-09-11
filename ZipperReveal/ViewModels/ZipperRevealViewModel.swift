//
//  ZipperRevealViewModel.swift
//  ZipperReveal
//
//  Created by Z.K   on 11/09/2026.
//
//  ViewModel responsible for direct zipper interaction.
//

import Foundation
import Combine
import SwiftUI

/// Owns the zipper's persistent interaction state.
///
/// The zipper is completely gesture-driven:
/// - Drag down increases progress.
/// - Drag up decreases progress.
/// - Releasing the finger keeps the current progress.
/// - A new drag starts from the current progress.
@MainActor
final class ZipperRevealViewModel: ObservableObject {

    // MARK: - Published State

    /// Opening progress from 0 to 1.
    ///
    /// 0 = completely closed.
    /// 1 = completely open.
    @Published private(set) var progress: CGFloat = 0

    /// Current visual phase derived from the user's drag direction.
    @Published private(set) var phase: ZipperPhase = .closed

    // MARK: - Configuration

    /// Central zipper configuration.
    let configuration: ZipperConfiguration

    // MARK: - Drag State

    /// Progress at the moment the current drag begins.
    private var dragStartProgress: CGFloat = 0

    /// Indicates that a zipper drag is currently active.
    private var isDragging = false

    // MARK: - Initialization

    init() {
        self.configuration = ZipperConfiguration()
    }

    // MARK: - Drag Interaction

    /// Starts a new drag from the zipper's current position.
    func beginDrag() {
        dragStartProgress = progress
        isDragging = true
    }

    /// Updates the zipper directly from the finger/cursor translation.
    ///
    /// Positive vertical translation opens the zipper.
    /// Negative vertical translation closes it.
    ///
    /// No animation is applied here so the zipper follows the finger
    /// immediately.
    func updateDrag(
        translationY: CGFloat,
        zipperTravel: CGFloat
    ) {
        guard zipperTravel > 0 else {
            return
        }

        // The first change event establishes the starting point
        // for this drag. Every following event uses the same
        // starting progress, so the movement stays 1:1.
        if !isDragging {
            beginDrag()
        }

        let normalizedTranslation =
            translationY / zipperTravel

        let newProgress =
            dragStartProgress + normalizedTranslation

        progress =
            newProgress.clamped(
                lowerBound: 0,
                upperBound: 1
            )

        updatePhase(
            translationY: translationY
        )
    }

    /// Ends the current drag.
    ///
    /// The current progress is intentionally left untouched.
    func endDrag() {
        isDragging = false
        updatePhase()
    }

    // MARK: - Reset

    /// Returns the zipper to the completely closed position.
    ///
    /// This is a direct state change, not an automatic animation.
    func reset() {
        progress = 0
        dragStartProgress = 0
        isDragging = false
        phase = .closed
    }

    // MARK: - Phase

    /// Updates the visual phase from the current interaction.
    private func updatePhase(
        translationY: CGFloat = 0
    ) {
        if progress <= 0.001 {
            phase = .closed
            return
        }

        if progress >= 0.999 {
            phase = .opened
            return
        }

        if translationY > 0.001 {
            phase = .opening
        } else if translationY < -0.001 {
            phase = .closing
        }
    }
}
