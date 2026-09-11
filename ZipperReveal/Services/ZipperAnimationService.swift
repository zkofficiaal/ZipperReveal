//
//  ZipperAnimationService.swift
//  ZipperReveal
//
//  Calculates the zipper animation state from elapsed time.
//

import Foundation
import SwiftUI

/// Immutable result produced by the animation service.
struct ZipperAnimationState {

    /// Current animation phase.
    let phase: ZipperPhase

    /// Opening amount from 0 to 1.
    let progress: CGFloat
}

/// Responsible only for calculating animation progress.
///
/// It does not draw anything and does not own UI state.
struct ZipperAnimationService {

    // MARK: - Configuration

    let configuration: ZipperConfiguration

    // MARK: - State Calculation

    /// Calculates the current zipper state.
    ///
    /// - Parameter elapsedTime:
    ///   Number of seconds elapsed since animation start.
    ///
    /// - Returns:
    ///   Current phase and opening progress.
    func state(
        at elapsedTime: TimeInterval
    ) -> ZipperAnimationState {

        let cycleDuration =
            configuration.cycleDuration

        guard cycleDuration > 0 else {
            return ZipperAnimationState(
                phase: .closed,
                progress: 0
            )
        }

        // Repeat the timeline forever.
        let cycleTime =
            elapsedTime
            .truncatingRemainder(
                dividingBy: cycleDuration
            )

        // MARK: Closed Hold

        if cycleTime
            < configuration.closedHoldDuration {

            return ZipperAnimationState(
                phase: .closed,
                progress: 0
            )
        }

        // MARK: Opening

        let openingStart =
            configuration.closedHoldDuration

        let openingEnd =
            openingStart
            + configuration.openingDuration

        if cycleTime < openingEnd {

            let rawProgress =
                (cycleTime - openingStart)
                / configuration.openingDuration

            let progress =
                easedProgress(
                    rawProgress
                )

            return ZipperAnimationState(
                phase: .opening,
                progress: progress
            )
        }

        // MARK: Open Hold

        let openedStart =
            openingEnd

        let openedEnd =
            openedStart
            + configuration.openedHoldDuration

        if cycleTime < openedEnd {

            return ZipperAnimationState(
                phase: .opened,
                progress: 1
            )
        }

        // MARK: Closing

        let closingStart =
            openedEnd

        let closingEnd =
            closingStart
            + configuration.closingDuration

        if cycleTime < closingEnd {

            let rawProgress =
                (cycleTime - closingStart)
                / configuration.closingDuration

            let progress =
                1
                - easedProgress(
                    rawProgress
                )

            return ZipperAnimationState(
                phase: .closing,
                progress: progress
            )
        }

        // MARK: Safety Fallback

        return ZipperAnimationState(
            phase: .closed,
            progress: 0
        )
    }

    // MARK: - Easing

    /// Smoothstep easing.
    ///
    /// This produces:
    ///
    /// slow → fast → slow
    ///
    /// instead of a robotic linear movement.
    private func easedProgress(
        _ value: TimeInterval
    ) -> CGFloat {

        let t =
            CGFloat(
                value
            )
            .clamped(
                lowerBound: 0,
                upperBound: 1
            )

        return t * t * (3 - 2 * t)
    }
}
