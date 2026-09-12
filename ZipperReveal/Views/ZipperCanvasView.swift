//
//  ZipperCanvasView.swift
//  ZipperReveal
//
//  Created by Z.K   on 11/09/2026.
//
//  Procedural zipper rendering using SwiftUI Canvas.
//

import SwiftUI

struct ZipperCanvasView: View {

    // MARK: - Inputs

    /// Current zipper opening progress.
    ///
    /// 0 = closed
    /// 1 = completely open
    let progress: CGFloat

    /// Current zipper animation phase.
    let phase: ZipperPhase

    /// Central configuration.
    let configuration:
        ZipperConfiguration

    // MARK: - Body

    var body: some View {

        let currentProgress =
            progress.clamped(
                lowerBound: 0,
                upperBound: 1
            )

        GeometryReader { proxy in

            let size =
                proxy.size

            Canvas(
                opaque: false,
                colorMode: .linear,
                rendersAsynchronously: true
            ) { context, canvasSize in

                // MARK: Geometry

                let geometry =
                    ZipperGeometry(
                        canvasSize: canvasSize,
                        configuration: configuration
                    )

                // MARK: Smooth Zipper Transition

                // Keep the zipper fully visible while the user is opening it.
                // Near the end, smoothly fade the zipper artwork away so the
                // clean phone screen is revealed progressively instead of
                // switching instantly at a hard threshold.
                let zipperOpacity =
                    smoothStepOpacity(
                        progress: currentProgress,
                        fadeStart: 0.82
                    )

                context.opacity =
                    zipperOpacity

                if currentProgress <= 0.001 {

                    drawClosedZipper(
                        context: &context,
                        geometry: geometry
                    )

                } else {

                    drawOpeningZipper(
                        context: &context,
                        geometry: geometry,
                        progress: currentProgress
                    )
                }

                // MARK: Slider

                // The slider stays visible and follows the finger all the
                // way to the bottom. Only the zipper/fabric artwork fades.
                context.opacity = 1

                drawSlider(
                    context: &context,
                    geometry: geometry,
                    progress: currentProgress
                )
            }

            // Small invisible overlay guarantees GeometryReader
            // participates in layout correctly.
            .frame(
                width: size.width,
                height: size.height
            )
        }
    }

    // MARK: - Closed Zipper

    private func drawClosedZipper(
        context: inout GraphicsContext,
        geometry: ZipperGeometry
    ) {

        // Draw the complete fabric.
        drawFabric(
            context: &context,
            geometry: geometry,
            rect: CGRect(
                x: geometry.zipperLeft,
                y: geometry.zipperTop,
                width: geometry.zipperWidth,
                height: geometry.zipperHeight
            )
        )

        // Draw center zipper tape.
        drawCenterTape(
            context: &context,
            geometry: geometry,
            progress: 0
        )

        // Draw zipper teeth.
        drawTeeth(
            context: &context,
            geometry: geometry,
            progress: 0
        )

        // Add subtle central shadow.
        drawCenterShadow(
            context: &context,
            geometry: geometry
        )
    }

    // MARK: - Opening Zipper

    private func drawOpeningZipper(
        context: inout GraphicsContext,
        geometry: ZipperGeometry,
        progress: CGFloat
    ) {

        let p =
            progress.clamped(
                lowerBound: 0,
                upperBound: 1
            )

        // MARK: Left Fabric

        var leftFabric = Path()
        let leftOuter = geometry.zipperLeft - geometry.fabricSeparation(progress: p)
        let sliderY = geometry.sliderY(progress: p)

        leftFabric.move(
            to: CGPoint(x: leftOuter, y: geometry.zipperTop)
        )
        leftFabric.addLine(
            to: CGPoint(x: leftOuter, y: geometry.zipperBottom)
        )
        leftFabric.addLine(
            to: CGPoint(x: geometry.centerTrackLeft, y: geometry.zipperBottom)
        )
        leftFabric.addLine(
            to: CGPoint(x: geometry.centerTrackLeft, y: sliderY)
        )

        let sampleCount = 28
        for index in stride(from: sampleCount, through: 0, by: -1) {
            let y = sliderY
                - (sliderY - geometry.zipperTop)
                * CGFloat(index)
                / CGFloat(sampleCount)

            leftFabric.addLine(
                to: CGPoint(
                    x: geometry.leftRailX(at: y, progress: p),
                    y: y
                )
            )
        }
        leftFabric.closeSubpath()

        drawFabricPath(
            context: &context,
            path: leftFabric
        )

        // MARK: Right Fabric

        var rightFabric = Path()
        let rightOuter = geometry.zipperRight + geometry.fabricSeparation(progress: p)

        rightFabric.move(
            to: CGPoint(x: rightOuter, y: geometry.zipperTop)
        )
        rightFabric.addLine(
            to: CGPoint(x: rightOuter, y: geometry.zipperBottom)
        )
        rightFabric.addLine(
            to: CGPoint(x: geometry.centerTrackRight, y: geometry.zipperBottom)
        )
        rightFabric.addLine(
            to: CGPoint(x: geometry.centerTrackRight, y: sliderY)
        )

        for index in 0...sampleCount {
            let y = geometry.zipperTop
                + (sliderY - geometry.zipperTop)
                * CGFloat(index)
                / CGFloat(sampleCount)

            rightFabric.addLine(
                to: CGPoint(
                    x: geometry.rightRailX(at: y, progress: p),
                    y: y
                )
            )
        }
        rightFabric.closeSubpath()

        drawFabricPath(
            context: &context,
            path: rightFabric
        )

        // MARK: Opening Edges

        drawOpeningEdges(
            context: &context,
            geometry: geometry,
            progress: p
        )

        // MARK: Center Tape

        drawCenterTape(
            context: &context,
            geometry: geometry,
            progress: p
        )

        // MARK: Teeth

        drawTeeth(
            context: &context,
            geometry: geometry,
            progress: p
        )
    }

    private func drawFabricPath(
        context: inout GraphicsContext,
        path: Path
    ) {

        context.fill(
            path,
            with: .color(
                Color.black.opacity(0.98)
            )
        )

        context.drawLayer { layer in
            layer.clip(
                to: path
            )

            drawFabricGrid(
                context: &layer,
                rect: path.boundingRect
            )

            drawDiamondStitching(
                context: &layer,
                rect: path.boundingRect
            )
        }

        context.stroke(
            path,
            with: .color(
                Color.white.opacity(0.72)
            ),
            lineWidth: 1.15
        )
    }

    // MARK: - Fabric

    private func drawFabric(
        context: inout GraphicsContext,
        geometry: ZipperGeometry,
        rect: CGRect
    ) {

        guard rect.width > 0 else {
            return
        }

        // Base fabric.
        let fabricPath =
            Path(
                roundedRect: rect,
                cornerRadius: 16
            )

        context.fill(
            fabricPath,
            with: .color(
                Color.black.opacity(0.98)
            )
        )

        // Very subtle fabric highlight.
        let highlightRect =
            CGRect(
                x: rect.minX,
                y: rect.minY,
                width: rect.width,
                height: rect.height * 0.025
            )

        context.fill(
            Path(
                roundedRect:
                    highlightRect,
                cornerRadius: 3
            ),
            with: .color(
                Color.white.opacity(0.045)
            )
        )

        // Fabric grid.
        drawFabricGrid(
            context: &context,
            rect: rect
        )

        // Diamond stitching.
        drawDiamondStitching(
            context: &context,
            rect: rect
        )

        // Fabric outer border.
        context.stroke(
            fabricPath,
            with: .color(
                Color.white.opacity(0.72)
            ),
            lineWidth: 1.15
        )
    }

    // MARK: - Fabric Grid

    private func drawFabricGrid(
        context: inout GraphicsContext,
        rect: CGRect
    ) {

        let horizontalSpacing =
            max(
                8,
                rect.height / 45
            )

        var y =
            rect.minY

        while y <= rect.maxY {

            var line =
                Path()

            line.move(
                to: CGPoint(
                    x: rect.minX,
                    y: y
                )
            )

            line.addLine(
                to: CGPoint(
                    x: rect.maxX,
                    y: y
                )
            )

            context.stroke(
                line,
                with: .color(
                    Color.white.opacity(0.025)
                ),
                lineWidth: 0.45
            )

            y += horizontalSpacing
        }

        let verticalSpacing =
            max(
                7,
                rect.width / 24
            )

        var x =
            rect.minX

        while x <= rect.maxX {

            var line =
                Path()

            line.move(
                to: CGPoint(
                    x: x,
                    y: rect.minY
                )
            )

            line.addLine(
                to: CGPoint(
                    x: x,
                    y: rect.maxY
                )
            )

            context.stroke(
                line,
                with: .color(
                    Color.white.opacity(0.022)
                ),
                lineWidth: 0.45
            )

            x += verticalSpacing
        }
    }

    // MARK: - Diamond Stitching

    private func drawDiamondStitching(
        context: inout GraphicsContext,
        rect: CGRect
    ) {

        let diamondHeight =
            max(
                50,
                rect.height / 7
            )

        var top =
            rect.minY

        while top < rect.maxY {

            let bottom =
                min(
                    rect.maxY,
                    top + diamondHeight
                )

            let middle =
                top
                + (bottom - top) / 2

            let left =
                rect.minX

            let right =
                rect.maxX

            let center =
                rect.midX

            // Left diagonal.
            var leftLine =
                Path()

            leftLine.move(
                to: CGPoint(
                    x: left,
                    y: middle
                )
            )

            leftLine.addLine(
                to: CGPoint(
                    x: center,
                    y: top
                )
            )

            context.stroke(
                leftLine,
                with: .color(
                    Color.white.opacity(
                        configuration.stitchingOpacity
                        * 0.25
                    )
                ),
                lineWidth: 0.7
            )

            // Right diagonal.
            var rightLine =
                Path()

            rightLine.move(
                to: CGPoint(
                    x: center,
                    y: top
                )
            )

            rightLine.addLine(
                to: CGPoint(
                    x: right,
                    y: middle
                )
            )

            context.stroke(
                rightLine,
                with: .color(
                    Color.white.opacity(
                        configuration.stitchingOpacity
                        * 0.25
                    )
                ),
                lineWidth: 0.7
            )

            // Bottom diagonals.
            var bottomLeft =
                Path()

            bottomLeft.move(
                to: CGPoint(
                    x: left,
                    y: middle
                )
            )

            bottomLeft.addLine(
                to: CGPoint(
                    x: center,
                    y: bottom
                )
            )

            context.stroke(
                bottomLeft,
                with: .color(
                    Color.white.opacity(
                        configuration.stitchingOpacity
                        * 0.25
                    )
                ),
                lineWidth: 0.7
            )

            var bottomRight =
                Path()

            bottomRight.move(
                to: CGPoint(
                    x: center,
                    y: bottom
                )
            )

            bottomRight.addLine(
                to: CGPoint(
                    x: right,
                    y: middle
                )
            )

            context.stroke(
                bottomRight,
                with: .color(
                    Color.white.opacity(
                        configuration.stitchingOpacity
                        * 0.25
                    )
                ),
                lineWidth: 0.7
            )

            top += diamondHeight
        }
    }

    // MARK: - Opening Edges

    private func drawOpeningEdges(
        context: inout GraphicsContext,
        geometry: ZipperGeometry,
        progress: CGFloat
    ) {

        let sliderPoint =
            geometry.sliderCenter(
                progress: progress
            )

        let sampleCount = 36

        var leftPath = Path()
        leftPath.move(
            to: geometry.leftOpeningPoint(
                progress: progress
            )
        )

        for index in 1...sampleCount {
            let y = geometry.zipperTop
                + (sliderPoint.y - geometry.zipperTop)
                * CGFloat(index)
                / CGFloat(sampleCount)

            leftPath.addLine(
                to: CGPoint(
                    x: geometry.leftRailX(at: y, progress: progress),
                    y: y
                )
            )
        }

        context.stroke(
            leftPath,
            with: .color(
                Color.white.opacity(0.75)
            ),
            lineWidth: 1.0
        )

        var rightPath = Path()
        rightPath.move(
            to: geometry.rightOpeningPoint(
                progress: progress
            )
        )

        for index in 1...sampleCount {
            let y = geometry.zipperTop
                + (sliderPoint.y - geometry.zipperTop)
                * CGFloat(index)
                / CGFloat(sampleCount)

            rightPath.addLine(
                to: CGPoint(
                    x: geometry.rightRailX(at: y, progress: progress),
                    y: y
                )
            )
        }

        context.stroke(
            rightPath,
            with: .color(
                Color.white.opacity(0.75)
            ),
            lineWidth: 1.0
        )

        // Small dark shadow directly behind the opening rails.
        context.stroke(
            leftPath,
            with: .color(
                Color.black.opacity(0.65)
            ),
            lineWidth: 3
        )

        context.stroke(
            rightPath,
            with: .color(
                Color.black.opacity(0.65)
            ),
            lineWidth: 3
        )
    }

    // MARK: - Center Tape

    private func drawCenterTape(
        context: inout GraphicsContext,
        geometry: ZipperGeometry,
        progress: CGFloat
    ) {

        let p = progress.clamped(lowerBound: 0, upperBound: 1)
        let sliderY = geometry.sliderY(progress: p)
        let sampleCount = 36
        let tapeWidth = geometry.centerTrackWidth * 0.42

        // The open section flares with the same curved rails as the teeth.
        if p > 0.001 {
            var leftTape = Path()
            var rightTape = Path()

            let firstY = geometry.zipperTop
            let firstLeft = geometry.leftRailX(at: firstY, progress: p)
            let firstRight = geometry.rightRailX(at: firstY, progress: p)

            leftTape.move(
                to: CGPoint(x: firstLeft - tapeWidth / 2, y: firstY)
            )
            rightTape.move(
                to: CGPoint(x: firstRight + tapeWidth / 2, y: firstY)
            )

            for index in 0...sampleCount {
                let y = geometry.zipperTop
                    + (sliderY - geometry.zipperTop)
                    * CGFloat(index)
                    / CGFloat(sampleCount)

                let leftX = geometry.leftRailX(at: y, progress: p)
                let rightX = geometry.rightRailX(at: y, progress: p)

                leftTape.addLine(
                    to: CGPoint(x: leftX - tapeWidth / 2, y: y)
                )
                rightTape.addLine(
                    to: CGPoint(x: rightX + tapeWidth / 2, y: y)
                )
            }

            for index in stride(from: sampleCount, through: 0, by: -1) {
                let y = geometry.zipperTop
                    + (sliderY - geometry.zipperTop)
                    * CGFloat(index)
                    / CGFloat(sampleCount)
                let leftX = geometry.leftRailX(at: y, progress: p)
                leftTape.addLine(
                    to: CGPoint(x: leftX + tapeWidth / 2, y: y)
                )
            }

            for index in stride(from: sampleCount, through: 0, by: -1) {
                let y = geometry.zipperTop
                    + (sliderY - geometry.zipperTop)
                    * CGFloat(index)
                    / CGFloat(sampleCount)
                let rightX = geometry.rightRailX(at: y, progress: p)
                rightTape.addLine(
                    to: CGPoint(x: rightX - tapeWidth / 2, y: y)
                )
            }

            leftTape.closeSubpath()
            rightTape.closeSubpath()

            context.fill(
                leftTape,
                with: .color(Color.black.opacity(0.96))
            )
            context.fill(
                rightTape,
                with: .color(Color.black.opacity(0.96))
            )
        }

        // The lower, still-meshed section stays a straight center track.
        let lowerRect = CGRect(
            x: geometry.centerTrackLeft,
            y: sliderY,
            width: geometry.centerTrackWidth,
            height: Swift.max(0, geometry.zipperBottom - sliderY)
        )

        context.fill(
            Path(lowerRect),
            with: .color(Color.black.opacity(0.96))
        )

        let leftHighlight = CGRect(
            x: geometry.centerTrackLeft + geometry.centerTrackWidth * 0.08,
            y: sliderY,
            width: geometry.centerTrackWidth * 0.10,
            height: Swift.max(0, geometry.zipperBottom - sliderY)
        )

        context.fill(
            Path(leftHighlight),
            with: .color(Color.white.opacity(0.13))
        )

        let rightShadow = CGRect(
            x: geometry.centerTrackRight - geometry.centerTrackWidth * 0.16,
            y: sliderY,
            width: geometry.centerTrackWidth * 0.12,
            height: Swift.max(0, geometry.zipperBottom - sliderY)
        )

        context.fill(
            Path(rightShadow),
            with: .color(Color.black.opacity(0.75))
        )
    }

    // MARK: - Teeth

    private func drawTeeth(
        context: inout GraphicsContext,
        geometry: ZipperGeometry,
        progress: CGFloat
    ) {

        let toothWidth =
            geometry.canvasSize.width
            * configuration.toothWidthRatio

        let toothHeight =
            geometry.canvasSize.height
            * configuration.toothHeightRatio

        for index in 0..<configuration.toothCount {

            let y = geometry.toothY(index: index)

            drawTooth(
                context: &context,
                x: geometry.toothX(
                    side: -1,
                    y: y,
                    progress: progress
                ),
                y: y,
                width: toothWidth,
                height: toothHeight
            )

            drawTooth(
                context: &context,
                x: geometry.toothX(
                    side: 1,
                    y: y,
                    progress: progress
                ),
                y: y,
                width: toothWidth,
                height: toothHeight
            )
        }
    }

    // MARK: - Single Tooth

    private func drawTooth(
        context: inout GraphicsContext,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) {

        let rect =
            CGRect(
                x: x - width / 2,
                y: y - height / 2,
                width: width,
                height: height
            )

        let tooth =
            Path(
                roundedRect: rect,
                cornerRadius: height * 0.35
            )

        // Tooth body.
        context.fill(
            tooth,
            with: .color(
                Color.gray.opacity(0.80)
            )
        )

        // Metallic top edge.
        var highlight =
            Path()

        highlight.move(
            to: CGPoint(
                x: rect.minX,
                y: rect.minY + 0.6
            )
        )

        highlight.addLine(
            to: CGPoint(
                x: rect.maxX,
                y: rect.minY + 0.6
            )
        )

        context.stroke(
            highlight,
            with: .color(
                Color.white.opacity(0.34)
            ),
            lineWidth: 0.55
        )

        // Tooth shadow.
        var shadow =
            Path()

        shadow.move(
            to: CGPoint(
                x: rect.minX,
                y: rect.maxY - 0.4
            )
        )

        shadow.addLine(
            to: CGPoint(
                x: rect.maxX,
                y: rect.maxY - 0.4
            )
        )

        context.stroke(
            shadow,
            with: .color(
                Color.black.opacity(0.75)
            ),
            lineWidth: 0.7
        )
    }

    // MARK: - Center Shadow

    private func drawCenterShadow(
        context: inout GraphicsContext,
        geometry: ZipperGeometry
    ) {

        let shadowWidth =
            geometry.centerTrackWidth * 0.35

        let shadow =
            CGRect(
                x: geometry.centerX
                    - shadowWidth / 2,
                y: geometry.zipperTop,
                width: shadowWidth,
                height: geometry.zipperHeight
            )

        context.fill(
            Path(
                shadow
            ),
            with: .color(
                Color.black.opacity(0.55)
            )
        )
    }

    // MARK: - Slider

    private func drawSlider(
        context: inout GraphicsContext,
        geometry: ZipperGeometry,
        progress: CGFloat
    ) {

        let tiltWindow = Swift.max(
            configuration.sliderTiltWindow,
            0.001
        )

        let tiltProgress: CGFloat
        let tiltDirection: CGFloat

        switch phase {
        case .opening:
            tiltProgress = (progress / tiltWindow)
                .clamped(lowerBound: 0, upperBound: 1)
            tiltDirection = 1

        case .closing:
            tiltProgress = ((1 - progress) / tiltWindow)
                .clamped(lowerBound: 0, upperBound: 1)
            tiltDirection = -1

        default:
            tiltProgress = 1
            tiltDirection = 0
        }

        let tilt =
            configuration.maximumSliderTiltDegrees
            * sin(
                (1 - tiltProgress)
                * .pi
                / 2
            )
            * tiltDirection

        let center =
            geometry.sliderCenter(
                progress: progress
            )

        context.drawLayer { layer in
            layer.translateBy(
                x: center.x,
                y: center.y
            )
            layer.rotate(
                by: Angle(
                    degrees: Double(tilt)
                )
            )
            layer.translateBy(
                x: -center.x,
                y: -center.y
            )


                let width =
                    geometry.sliderWidth

                let height =
                    geometry.sliderHeight

                let rect =
                    CGRect(
                        x: center.x - width / 2,
                        y: center.y - height / 2,
                        width: width,
                        height: height
                    )

                // MARK: Slider Shadow

                let shadowRect =
                    rect.offsetBy(
                        dx: 1.5,
                        dy: 2.5
                    )

                layer.fill(
                    Path(
                        roundedRect:
                            shadowRect,
                        cornerRadius:
                            width * 0.18
                    ),
                    with: .color(
                        Color.black.opacity(0.85)
                    )
                )

                // MARK: Slider Body

                let sliderPath =
                    Path(
                        roundedRect:
                            rect,
                        cornerRadius:
                            width * 0.18
                    )

                layer.fill(
                    sliderPath,
                    with: .linearGradient(
                        Gradient(
                            colors: [
                                Color.gray.opacity(0.90),
                                Color.black.opacity(0.95),
                                Color.gray.opacity(0.55)
                            ]
                        ),
                        startPoint: CGPoint(
                            x: rect.minX,
                            y: rect.minY
                        ),
                        endPoint: CGPoint(
                            x: rect.maxX,
                            y: rect.maxY
                        )
                    )
                )

                // MARK: Slider Border

                layer.stroke(
                    sliderPath,
                    with: .color(
                        Color.white.opacity(0.23)
                    ),
                    lineWidth: 0.8
                )

                // MARK: Slider Opening Hole

                let holeRect =
                    CGRect(
                        x: rect.midX - width * 0.20,
                        y: rect.midY - height * 0.20,
                        width: width * 0.40,
                        height: height * 0.42
                    )

                layer.fill(
                    Path(
                        roundedRect:
                            holeRect,
                        cornerRadius:
                            width * 0.08
                    ),
                    with: .color(
                        Color.black.opacity(0.88)
                    )
                )

                // MARK: Slider Highlight

                var highlight =
                    Path()

                highlight.move(
                    to: CGPoint(
                        x: rect.minX + width * 0.18,
                        y: rect.minY + height * 0.16
                    )
                )

                highlight.addLine(
                    to: CGPoint(
                        x: rect.maxX - width * 0.18,
                        y: rect.minY + height * 0.16
                    )
                )

                layer.stroke(
                    highlight,
                    with: .color(
                        Color.white.opacity(0.28)
                    ),
                    lineWidth: 0.8
                )
    
    }

    // MARK: - Smooth Transition

    /// Returns a smooth 1...0 opacity value as progress moves from
    /// `fadeStart` to 1.
    ///
    /// Smoothstep avoids a sudden visual jump at the end of the zipper
    /// interaction.
    private func smoothStepOpacity(
        progress: CGFloat,
        fadeStart: CGFloat
    ) -> CGFloat {

        let normalized =
            (progress - fadeStart)
            / (1 - fadeStart)

        let clamped =
            normalized.clamped(
                lowerBound: 0,
                upperBound: 1
            )

        let eased =
            clamped
            * clamped
            * (3 - 2 * clamped)

        return 1 - eased
    }

}
