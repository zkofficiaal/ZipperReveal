//
//  ZipperCanvasView.swift
//  ZipperReveal
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

        GeometryReader { proxy in

            let size =
                proxy.size

            let geometry =
                ZipperGeometry(
                    canvasSize: size,
                    configuration: configuration
                )

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

                // MARK: Closed State

                if progress <= 0.001 {

                    drawClosedZipper(
                        context: &context,
                        geometry: geometry
                    )

                } else {

                    // MARK: Open / Opening State

                    drawOpeningZipper(
                        context: &context,
                        geometry: geometry,
                        progress: progress
                    )
                }

                // MARK: Slider

                drawSlider(
                    context: &context,
                    geometry: geometry,
                    progress: progress
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

        let leftRect =
            geometry.leftFabricRect(
                progress: progress
            )

        let rightRect =
            geometry.rightFabricRect(
                progress: progress
            )

        // MARK: Left Fabric

        drawFabric(
            context: &context,
            geometry: geometry,
            rect: leftRect
        )

        // MARK: Right Fabric

        drawFabric(
            context: &context,
            geometry: geometry,
            rect: rightRect
        )

        // MARK: Opening Edges

        drawOpeningEdges(
            context: &context,
            geometry: geometry,
            progress: progress
        )

        // MARK: Center Tape

        drawCenterTape(
            context: &context,
            geometry: geometry
        )

        // MARK: Teeth

        drawTeeth(
            context: &context,
            geometry: geometry,
            progress: progress
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

        let leftPoint =
            geometry.leftOpeningPoint(
                progress: progress
            )

        let rightPoint =
            geometry.rightOpeningPoint(
                progress: progress
            )

        let sliderPoint =
            geometry.sliderCenter(
                progress: progress
            )

        // Left opening path.
        var leftPath =
            Path()

        leftPath.move(
            to: CGPoint(
                x: geometry.centerX
                    - geometry.centerTrackWidth / 2,
                y: geometry.zipperTop
            )
        )

        leftPath.addQuadCurve(
            to: sliderPoint,
            control: CGPoint(
                x: geometry.centerX
                    - geometry.zipperWidth * 0.19,
                y: geometry.zipperTop
                    + geometry.zipperHeight * 0.40
            )
        )

        context.stroke(
            leftPath,
            with: .color(
                Color.white.opacity(0.75)
            ),
            lineWidth: 1.0
        )

        // Right opening path.
        var rightPath =
            Path()

        rightPath.move(
            to: CGPoint(
                x: geometry.centerX
                    + geometry.centerTrackWidth / 2,
                y: geometry.zipperTop
            )
        )

        rightPath.addQuadCurve(
            to: sliderPoint,
            control: CGPoint(
                x: geometry.centerX
                    + geometry.zipperWidth * 0.19,
                y: geometry.zipperTop
                    + geometry.zipperHeight * 0.40
            )
        )

        context.stroke(
            rightPath,
            with: .color(
                Color.white.opacity(0.75)
            ),
            lineWidth: 1.0
        )

        // Small dark shadow directly behind opening.
        var shadow =
            Path()

        shadow.move(
            to: leftPoint
        )

        shadow.addLine(
            to: sliderPoint
        )

        shadow.addLine(
            to: rightPoint
        )

        context.stroke(
            shadow,
            with: .color(
                Color.black.opacity(0.65)
            ),
            lineWidth: 3
        )
    }

    // MARK: - Center Tape

    private func drawCenterTape(
        context: inout GraphicsContext,
        geometry: ZipperGeometry
    ) {

        let rect =
            CGRect(
                x: geometry.centerTrackLeft,
                y: geometry.zipperTop,
                width: geometry.centerTrackWidth,
                height: geometry.zipperHeight
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

            // During the opening, lower teeth remain visually
            // attached to the slider region while upper teeth
            // form the open rails.
            let normalizedY =
                CGFloat(index)
                / CGFloat(
                    max(
                        configuration.toothCount - 1,
                        1
                    )
                )

            let openingThreshold =
                progress

            let sideOffset: CGFloat

            if normalizedY < openingThreshold {

                sideOffset =
                    geometry.fabricSeparation(
                        progress: progress
                    )
                    * normalizedY
                    * 0.32

            } else {

                sideOffset = 0
            }

            drawTooth(
                context: &context,
                x: geometry.centerX
                    - geometry.centerTrackWidth * 0.40
                    - sideOffset,
                y: y,
                width: toothWidth,
                height: toothHeight
            )

            drawTooth(
                context: &context,
                x: geometry.centerX
                    + geometry.centerTrackWidth * 0.40
                    + sideOffset,
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
}
