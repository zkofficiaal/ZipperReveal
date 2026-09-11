//
//  ZipperGeometry.swift
//  ZipperReveal
//
//  Created by Z.K  on 11/09/2026.
//
//  Geometry calculations used by the zipper reveal.
//

import SwiftUI

/// Contains all geometry calculations used by the zipper reveal.
///
/// The opening is V-shaped: the two zipper rails start apart near the
/// top and converge toward the slider as the user drags downward.
struct ZipperGeometry {

    // MARK: - Canvas

    let canvasSize: CGSize

    // MARK: - Configuration

    let configuration: ZipperConfiguration

    // MARK: - Canvas Center

    var centerX: CGFloat { canvasSize.width / 2 }
    var centerY: CGFloat { canvasSize.height / 2 }

    // MARK: - Phone

    var phoneWidth: CGFloat {
        canvasSize.width * configuration.phoneWidthRatio
    }

    var phoneHeight: CGFloat {
        canvasSize.height * configuration.phoneHeightRatio
    }

    var phoneRect: CGRect {
        CGRect(
            x: centerX - phoneWidth / 2,
            y: centerY - phoneHeight / 2,
            width: phoneWidth,
            height: phoneHeight
        )
    }

    // MARK: - Zipper

    var zipperWidth: CGFloat {
        canvasSize.width * configuration.zipperWidthRatio
    }

    var zipperHeight: CGFloat {
        canvasSize.height * configuration.zipperHeightRatio
    }

    var zipperTop: CGFloat { centerY - zipperHeight / 2 }
    var zipperBottom: CGFloat { zipperTop + zipperHeight }
    var zipperLeft: CGFloat { centerX - zipperWidth / 2 }
    var zipperRight: CGFloat { centerX + zipperWidth / 2 }

    // MARK: - V Shape

    /// Half the distance between the two rails at the top of the V.
    /// Increase this value to make the V wider.
    var topRailHalfWidth: CGFloat {
        zipperWidth * 0.30
    }

    var topLeftRailX: CGFloat {
        centerX - topRailHalfWidth
    }

    var topRightRailX: CGFloat {
        centerX + topRailHalfWidth
    }

    /// Y coordinate where the V opening reaches the slider.
    func openingY(progress: CGFloat) -> CGFloat {
        sliderY(progress: progress)
    }

    /// X coordinate of the left V rail at a given Y position.
    func leftRailX(at y: CGFloat, progress: CGFloat) -> CGFloat {
        let p = progress.clamped(lowerBound: 0, upperBound: 1)
        let sliderY = openingY(progress: p)

        guard y <= sliderY else {
            return centerTrackLeft
        }

        let denominator = Swift.max(sliderY - zipperTop, 0.001)
        let t = ((y - zipperTop) / denominator)
            .clamped(lowerBound: 0, upperBound: 1)

        return topLeftRailX
            + (centerX - topLeftRailX) * t
    }

    /// X coordinate of the right V rail at a given Y position.
    func rightRailX(at y: CGFloat, progress: CGFloat) -> CGFloat {
        let p = progress.clamped(lowerBound: 0, upperBound: 1)
        let sliderY = openingY(progress: p)

        guard y <= sliderY else {
            return centerTrackRight
        }

        let denominator = Swift.max(sliderY - zipperTop, 0.001)
        let t = ((y - zipperTop) / denominator)
            .clamped(lowerBound: 0, upperBound: 1)

        return topRightRailX
            + (centerX - topRightRailX) * t
    }

    // MARK: - Center Track

    var centerTrackWidth: CGFloat {
        canvasSize.width * configuration.centerTrackWidthRatio
    }

    var centerTrackLeft: CGFloat {
        centerX - centerTrackWidth / 2
    }

    var centerTrackRight: CGFloat {
        centerX + centerTrackWidth / 2
    }

    // MARK: - Slider

    var sliderWidth: CGFloat {
        canvasSize.width * configuration.sliderWidthRatio
    }

    var sliderHeight: CGFloat {
        canvasSize.height * configuration.sliderHeightRatio
    }

    var sliderTopY: CGFloat {
        zipperTop + sliderHeight * 0.35
    }

    var sliderBottomY: CGFloat {
        zipperBottom - sliderHeight * 0.80
    }

    func sliderY(progress: CGFloat) -> CGFloat {
        let p = progress.clamped(lowerBound: 0, upperBound: 1)

        return sliderTopY
            + (sliderBottomY - sliderTopY) * p
    }

    // MARK: - Fabric Separation

    /// Moves the outside fabric edges slightly outward while the V opening grows.
    func fabricSeparation(progress: CGFloat) -> CGFloat {
        let p = progress.clamped(lowerBound: 0, upperBound: 1)

        return canvasSize.width
            * configuration.maximumFabricSeparationRatio
            * p
    }

    // MARK: - Fabric Paths

    /// Points for the left fabric panel. The inner edge follows the V rail.
    func leftFabricPathPoints(progress: CGFloat) -> [CGPoint] {
        let p = progress.clamped(lowerBound: 0, upperBound: 1)
        let sliderY = openingY(progress: p)
        let outerLeft = zipperLeft - fabricSeparation(progress: p)

        return [
            CGPoint(x: outerLeft, y: zipperTop),
            CGPoint(x: outerLeft, y: zipperBottom),
            CGPoint(x: centerTrackLeft, y: zipperBottom),
            CGPoint(x: centerTrackLeft, y: sliderY),
            CGPoint(x: topLeftRailX, y: zipperTop)
        ]
    }

    /// Points for the right fabric panel. The inner edge follows the V rail.
    func rightFabricPathPoints(progress: CGFloat) -> [CGPoint] {
        let p = progress.clamped(lowerBound: 0, upperBound: 1)
        let sliderY = openingY(progress: p)
        let outerRight = zipperRight + fabricSeparation(progress: p)

        return [
            CGPoint(x: outerRight, y: zipperTop),
            CGPoint(x: outerRight, y: zipperBottom),
            CGPoint(x: centerTrackRight, y: zipperBottom),
            CGPoint(x: centerTrackRight, y: sliderY),
            CGPoint(x: topRightRailX, y: zipperTop)
        ]
    }

    // MARK: - Opening Edges

    func leftOpeningPoint(progress: CGFloat) -> CGPoint {
        CGPoint(x: topLeftRailX, y: zipperTop)
    }

    func rightOpeningPoint(progress: CGFloat) -> CGPoint {
        CGPoint(x: topRightRailX, y: zipperTop)
    }

    // MARK: - Slider Center

    func sliderCenter(progress: CGFloat) -> CGPoint {
        CGPoint(x: centerX, y: sliderY(progress: progress))
    }

    // MARK: - Teeth

    var toothSpacing: CGFloat {
        zipperHeight / CGFloat(configuration.toothCount)
    }

    func toothY(index: Int) -> CGFloat {
        zipperTop
            + CGFloat(index) * toothSpacing
            + toothSpacing * 0.5
    }

    /// X coordinate of a tooth on either side of the V-shaped opening.
    func toothX(side: CGFloat, y: CGFloat, progress: CGFloat) -> CGFloat {
        let p = progress.clamped(lowerBound: 0, upperBound: 1)
        let sliderY = openingY(progress: p)

        if y <= sliderY {
            let denominator = Swift.max(sliderY - zipperTop, 0.001)
            let t = ((y - zipperTop) / denominator)
                .clamped(lowerBound: 0, upperBound: 1)

            let topX = side < 0 ? topLeftRailX : topRightRailX

            return topX + (centerX - topX) * t
        }

        return side < 0 ? centerTrackLeft : centerTrackRight
    }

    // MARK: - Utility

    func roundedRectPath(rect: CGRect, cornerRadius: CGFloat) -> Path {
        Path(roundedRect: rect, cornerRadius: cornerRadius)
    }
}

// MARK: - CGFloat Clamping

extension CGFloat {

    func clamped(
        lowerBound: CGFloat,
        upperBound: CGFloat
    ) -> CGFloat {
        Swift.min(
            Swift.max(self, lowerBound),
            upperBound
        )
    }
}
