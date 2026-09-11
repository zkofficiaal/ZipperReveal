//
//  ZipperGeometry.swift
//  ZipperReveal
//
//  Geometry calculations used by the zipper animation.
//

import SwiftUI

/// Contains geometry calculations for the zipper reveal.
struct ZipperGeometry {

    // MARK: - Canvas

    let canvasSize: CGSize

    // MARK: - Configuration

    let configuration: ZipperConfiguration

    // MARK: - Canvas Center

    /// Horizontal center of the canvas.
    var centerX: CGFloat {
        canvasSize.width / 2
    }

    /// Vertical center of the canvas.
    var centerY: CGFloat {
        canvasSize.height / 2
    }

    // MARK: - Phone

    /// Width of the phone.
    var phoneWidth: CGFloat {
        canvasSize.width * configuration.phoneWidthRatio
    }

    /// Height of the phone.
    var phoneHeight: CGFloat {
        canvasSize.height * configuration.phoneHeightRatio
    }

    /// Rectangle containing the phone.
    var phoneRect: CGRect {
        CGRect(
            x: centerX - phoneWidth / 2,
            y: centerY - phoneHeight / 2,
            width: phoneWidth,
            height: phoneHeight
        )
    }

    // MARK: - Zipper

    /// Total zipper width.
    var zipperWidth: CGFloat {
        canvasSize.width * configuration.zipperWidthRatio
    }

    /// Total zipper height.
    var zipperHeight: CGFloat {
        canvasSize.height * configuration.zipperHeightRatio
    }

    /// Top edge of the zipper.
    var zipperTop: CGFloat {
        centerY - zipperHeight / 2
    }

    /// Bottom edge of the zipper.
    var zipperBottom: CGFloat {
        zipperTop + zipperHeight
    }

    /// Left edge of the zipper.
    var zipperLeft: CGFloat {
        centerX - zipperWidth / 2
    }

    /// Right edge of the zipper.
    var zipperRight: CGFloat {
        centerX + zipperWidth / 2
    }

    // MARK: - Center Track

    /// Width of the center zipper track.
    var centerTrackWidth: CGFloat {
        canvasSize.width * configuration.centerTrackWidthRatio
    }

    /// Left edge of center track.
    var centerTrackLeft: CGFloat {
        centerX - centerTrackWidth / 2
    }

    /// Right edge of center track.
    var centerTrackRight: CGFloat {
        centerX + centerTrackWidth / 2
    }

    // MARK: - Slider

    /// Slider width.
    var sliderWidth: CGFloat {
        canvasSize.width * configuration.sliderWidthRatio
    }

    /// Slider height.
    var sliderHeight: CGFloat {
        canvasSize.height * configuration.sliderHeightRatio
    }

    /// Top slider position.
    var sliderTopY: CGFloat {
        zipperTop + sliderHeight * 0.35
    }

    /// Bottom slider position.
    var sliderBottomY: CGFloat {
        zipperBottom - sliderHeight * 0.80
    }

    /// Slider Y position based on animation progress.
    ///
    /// 0 = top
    /// 1 = bottom
    func sliderY(progress: CGFloat) -> CGFloat {

        let clampedProgress = progress.clamped(
            lowerBound: 0,
            upperBound: 1
        )

        return sliderTopY
        + (sliderBottomY - sliderTopY) * clampedProgress
    }

    // MARK: - Fabric Separation

    /// Current fabric separation.
    func fabricSeparation(progress: CGFloat) -> CGFloat {

        let clampedProgress = progress.clamped(
            lowerBound: 0,
            upperBound: 1
        )

        return canvasSize.width
        * configuration.maximumFabricSeparationRatio
        * clampedProgress
    }

    // MARK: - Fabric Rectangles

    /// Rectangle for the left fabric.
    func leftFabricRect(progress: CGFloat) -> CGRect {

        let separation = fabricSeparation(progress: progress)

        let left = zipperLeft - separation
        let right = centerX - centerTrackWidth / 2

        return CGRect(
            x: left,
            y: zipperTop,
            width: max(0, right - left),
            height: zipperHeight
        )
    }

    /// Rectangle for the right fabric.
    func rightFabricRect(progress: CGFloat) -> CGRect {

        let separation = fabricSeparation(progress: progress)

        let left = centerX + centerTrackWidth / 2
        let right = zipperRight + separation

        return CGRect(
            x: left,
            y: zipperTop,
            width: max(0, right - left),
            height: zipperHeight
        )
    }

    // MARK: - Opening Edges

    /// Left opening edge.
    func leftOpeningPoint(progress: CGFloat) -> CGPoint {

        let separation = fabricSeparation(progress: progress)

        let x =
            centerX
            - centerTrackWidth / 2
            - separation

        let y =
            zipperTop
            + zipperHeight * progress

        return CGPoint(
            x: x,
            y: y
        )
    }

    /// Right opening edge.
    func rightOpeningPoint(progress: CGFloat) -> CGPoint {

        let separation = fabricSeparation(progress: progress)

        let x =
            centerX
            + centerTrackWidth / 2
            + separation

        let y =
            zipperTop
            + zipperHeight * progress

        return CGPoint(
            x: x,
            y: y
        )
    }

    /// Center point of the zipper slider.
    func sliderCenter(progress: CGFloat) -> CGPoint {

        CGPoint(
            x: centerX,
            y: sliderY(progress: progress)
        )
    }

    // MARK: - Teeth

    /// Vertical distance between zipper teeth.
    var toothSpacing: CGFloat {

        zipperHeight
        / CGFloat(configuration.toothCount)
    }

    /// Returns the Y coordinate of a zipper tooth.
    func toothY(index: Int) -> CGFloat {

        zipperTop
        + CGFloat(index) * toothSpacing
        + toothSpacing * 0.5
    }

    // MARK: - Utility

    /// Creates a rounded rectangle path.
    func roundedRectPath(
        rect: CGRect,
        cornerRadius: CGFloat
    ) -> Path {

        Path(
            roundedRect: rect,
            cornerRadius: cornerRadius
        )
    }
}

// MARK: - CGFloat Clamping

extension CGFloat {

    /// Restricts a CGFloat to a specified range.
    func clamped(
        lowerBound: CGFloat,
        upperBound: CGFloat
    ) -> CGFloat {

        min(
            max(self, lowerBound),
            upperBound
        )
    }
}
