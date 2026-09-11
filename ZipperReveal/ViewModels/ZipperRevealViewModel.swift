//
//  ZipperRevealViewModel.swift
//  ZipperReveal
//
//  Created by Z.K   on 11/09/2026.
//
//  Direct gesture-driven zipper interaction state.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class ZipperRevealViewModel: ObservableObject {

    // MARK: - Published State

    /// 0 = closed, 1 = fully open.
    @Published private(set) var progress: CGFloat = 0

    /// Visual phase derived from the current progress and drag direction.
    @Published private(set) var phase: ZipperPhase = .closed

    // MARK: - Configuration

    let configuration: ZipperConfiguration

    // MARK: - Drag State

    /// Progress at the exact moment the current drag starts.
    private var dragStartProgress: CGFloat = 0

    private var isDragging = false

    // MARK: - Initialization

    init() {
        self.configuration = ZipperConfiguration()
    }

    // MARK: - Drag

    /// Stores the current progress as the origin for a new drag.
    func beginDrag() {
        dragStartProgress = progress
        isDragging = true
    }

    /// Converts vertical finger/cursor movement into 0...1 progress.
    ///
    /// Positive translation opens the zipper.
    /// Negative translation closes it.
    /// The value is assigned directly so there is no animation lag.
    func updateDrag(
        translationY: CGFloat,
        zipperTravel: CGFloat
    ) {
        guard zipperTravel > 0 else {
            return
        }

        if !isDragging {
            beginDrag()
        }

        let normalizedTranslation =
            translationY / zipperTravel

        let newProgress =
            dragStartProgress + normalizedTranslation

        progress = newProgress.clamped(
            lowerBound: 0,
            upperBound: 1
        )

        updatePhase(
            translationY: translationY
        )
    }

    /// Ends the drag without changing progress.
    /// The zipper stays exactly where the finger was released.
    func endDrag() {
        isDragging = false
        updatePhase()
    }

    // MARK: - Reset

    func reset() {
        progress = 0
        dragStartProgress = 0
        isDragging = false
        phase = .closed
    }

    // MARK: - Phase

    private func updatePhase(
        translationY: CGFloat = 0
    ) {
        if progress <= 0.001 {
            phase = .closed
        } else if progress >= 0.999 {
            phase = .opened
        } else if translationY > 0.001 {
            phase = .opening
        } else if translationY < -0.001 {
            phase = .closing
        }
    }
}
