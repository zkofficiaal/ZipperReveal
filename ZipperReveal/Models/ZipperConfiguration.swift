//
//  ZipperConfiguration.swift
//  ZipperReveal
//
//  Created by Z.K   on 11/09/2026.
//  Central configuration for the zipper reveal animation.
//

import SwiftUI

/// Contains all adjustable values used by the zipper animation.
struct ZipperConfiguration {

    // MARK: - Animation Timing

    /// Time spent showing the completely closed zipper.
    let closedHoldDuration: TimeInterval = 0.85

    /// Time required for the zipper to open.
    let openingDuration: TimeInterval = 0.55

    /// Time spent showing the completely opened phone.
    let openedHoldDuration: TimeInterval = 0.80

    /// Time required for the zipper to close.
    let closingDuration: TimeInterval = 0.40

    // MARK: - Zipper Size

    /// Width of the complete zipper/fabric object.
    let zipperWidthRatio: CGFloat = 0.55

    /// Height of the zipper object.
    let zipperHeightRatio: CGFloat = 0.72

    /// Width of the center zipper track.
    let centerTrackWidthRatio: CGFloat = 0.085

    // MARK: - Slider

    /// Width of the zipper slider.
    let sliderWidthRatio: CGFloat = 0.105

    /// Height of the zipper slider.
    let sliderHeightRatio: CGFloat = 0.085

    // MARK: - Teeth

    /// Number of visible zipper teeth.
    let toothCount: Int = 34

    /// Width of each zipper tooth.
    let toothWidthRatio: CGFloat = 0.060

    /// Height of each zipper tooth.
    let toothHeightRatio: CGFloat = 0.012

    // MARK: - Fabric

    /// Maximum horizontal movement of each fabric side.
    let maximumFabricSeparationRatio: CGFloat = 0.19

    /// Controls how long the zipper rails stay wide before sweeping inward.
    let openingCurveControlRatio: CGFloat = 0.82

    /// Maximum temporary tilt of the zipper slider while it starts/stops moving.
    let maximumSliderTiltDegrees: CGFloat = 7

    /// Portion of the progress range used for the slider tilt.
    let sliderTiltWindow: CGFloat = 0.12

    /// Amount of visible diagonal stitching.
    let stitchingOpacity: CGFloat = 0.32

    // MARK: - Phone

    /// Width of the phone relative to the available canvas.
    let phoneWidthRatio: CGFloat = 0.36

    /// Height of the phone relative to the available canvas.
    let phoneHeightRatio: CGFloat = 0.70

    /// Phone corner radius.
    let phoneCornerRadiusRatio: CGFloat = 0.045

    // MARK: - Derived Animation Duration

    /// Complete animation cycle.
    var cycleDuration: TimeInterval {
        closedHoldDuration
        + openingDuration
        + openedHoldDuration
        + closingDuration
    }
    
    /// Color of the fabric on either side of the zipper.
    var fabricColor: Color {
        Color(white: 0.15) // Adjust to your preferred dark/light shade
    }
}
