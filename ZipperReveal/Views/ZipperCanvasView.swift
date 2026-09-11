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
            geometry: geometry
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

        // The opened fabric is a true V shape.
        // Its inner edge starts wide at the top and converges
        // exactly to the slider.
        drawVFabric(
            context: &context,
            geometry: geometry,
            progress: p,
            side: .left
        )

        drawVFabric(
            context: &context,
            geometry: geometry,
            progress: p,
            side: .right
        )

        // The two zipper rails follow the same V geometry.
        drawOpeningEdges(
            context: &context,
            geometry: geometry,
            progress: p
        )

        // Only the zipper tape below the slider remains visible.
        drawCenterTape(
            context: &context,
            geometry: geometry,
            startY: geometry.sliderY(progress: p)
        )

        // Teeth are positioned directly on the V rails.
        drawTeeth(
            context: &context,
            geometry: geometry,
            progress: p
        )
    }

    // MARK: - V Fabric

    private enum VFabricSide {
        case left
        case right
    }

    private func drawVFabric(
        context: inout GraphicsContext,
        geometry: ZipperGeometry,
        progress: CGFloat,
        side: VFabricSide
    ) {

        let points =
            side == .left
            ? geometry.leftFabricPathPoints(progress: progress)
            : geometry.rightFabricPathPoints(progress: progress)

        guard points.count >= 5 else {
            return
        }

        var fabricPath =
            Path()

        fabricPath.move(
            to: points[0]
        )

        for point in points.dropFirst() {
            fabricPath.addLine(
                to: point
            )
        }

        fabricPath.closeSubpath()

        context.fill(
            fabricPath,
            with: .color(
                Color.black.opacity(0.98)
            )
        )

        // Clip the existing fabric texture to the V panel.
        context.drawLayer { layer in

            layer.clip(
                to: fabricPath
            )

            let bounds =
                CGRect(
                    x: geometry.zipperLeft
                        - geometry.fabricSeparation(progress: progress),
                    y: geometry.zipperTop,
                    width: geometry.zipperWidth
                        + geometry.fabricSeparation(progress: progress) * 2,
                    height: geometry.zipperHeight
                )

            drawFabricGrid(
                context: &layer,
                rect: bounds
            )

            drawDiamondStitching(
                context: &layer,
                rect: bounds
            )
        }

        context.stroke(
            fabricPath,
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

        let leftTop =
            CGPoint(
                x: geometry.topLeftRailX,
                y: geometry.zipperTop
            )

        let rightTop =
            CGPoint(
                x: geometry.topRightRailX,
                y: geometry.zipperTop
            )

        let slider =
            geometry.sliderCenter(
                progress: progress
            )

        // Left V rail.
        var leftPath =
            Path()

        leftPath.move(
            to: leftTop
        )

        leftPath.addLine(
            to: slider
        )

        context.stroke(
            leftPath,
            with: .color(
                Color.white.opacity(0.82)
            ),
            lineWidth: 1.1
        )

        // Right V rail.
        var rightPath =
            Path()

        rightPath.move(
            to: rightTop
        )

        rightPath.addLine(
            to: slider
        )

        context.stroke(
            rightPath,
            with: .color(
                Color.white.opacity(0.82)
            ),
            lineWidth: 1.1
        )

        // Dark shadow follows both rails to give the zipper
        // the same depth as the reference.
        var shadow =
            Path()

        shadow.move(
            to: leftTop
        )

        shadow.addLine(
            to: slider
        )

        shadow.move(
            to: rightTop
        )

        shadow.addLine(
            to: slider
        )

        context.stroke(
            shadow,
            with: .color(
                Color.black.opacity(0.62)
            ),
            lineWidth: 3
        )
    }

    // MARK: - Center Tape

    private func drawCenterTape(
        context: inout GraphicsContext,
        geometry: ZipperGeometry,
        startY: CGFloat? = nil
    ) {

        let rect =
            CGRect(
                x: geometry.centerTrackLeft,
                y: startY ?? geometry.zipperTop,
                width: geometry.centerTrackWidth,
                height: geometry.zipperBottom - (startY ?? geometry.zipperTop)
            )

        // Outer dark tape.
        context.fill(
            Path(
                rect
            ),
            with: .color(
                Color.black.opacity(0.96)
            )
        )

        // Left metallic highlight.
        let leftHighlight =
            CGRect(
                x: rect.minX + rect.width * 0.08,
                y: rect.minY,
                width: rect.width * 0.10,
                height: rect.height
            )

        context.fill(
            Path(
                leftHighlight
            ),
            with: .color(
                Color.white.opacity(0.13)
            )
        )

        // Right shadow.
        let rightShadow =
            CGRect(
                x: rect.maxX - rect.width * 0.16,
                y: rect.minY,
                width: rect.width * 0.12,
                height: rect.height
            )

        context.fill(
            Path(
                rightShadow
            ),
            with: .color(
                Color.black.opacity(0.75)
            )
        )

        // Thin border.
        context.stroke(
            Path(rect),
            with: .color(
                Color.white.opacity(0.15)
            ),
            lineWidth: 0.7
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

            let y =
                geometry.toothY(
                    index: index
                )

            let leftX =
                geometry.toothX(
                    side: -1,
                    y: y,
                    progress: progress
                )

            let rightX =
                geometry.toothX(
                    side: 1,
                    y: y,
                    progress: progress
                )

            drawTooth(
                context: &context,
                x: leftX,
                y: y,
                width: toothWidth,
                height: toothHeight
            )

            drawTooth(
                context: &context,
                x: rightX,
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

        let center =
            geometry.sliderCenter(
                progress: progress
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

        context.fill(
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

        context.fill(
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

        context.stroke(
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

        context.fill(
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

        context.stroke(
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
