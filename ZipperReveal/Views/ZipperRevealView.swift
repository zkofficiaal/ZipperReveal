//
//  ZipperRevealView.swift
//  ZipperReveal
//
//  Created by Z.K   on 11/09/2026.
//
//  Main screen for the direct-manipulation zipper reveal.
//

import SwiftUI

struct ZipperRevealView: View {

    // MARK: - ViewModel

    @StateObject
    private var viewModel =
        ZipperRevealViewModel()

    // MARK: - Body

    var body: some View {

        ZStack {

            // MARK: Background

            Color.black
                .ignoresSafeArea()

            // MARK: Zipper / Phone

            GeometryReader { proxy in

                let size =
                    proxy.size

                let geometry =
                    ZipperGeometry(
                        canvasSize: size,
                        configuration:
                            viewModel.configuration
                    )

                ZStack {

                    // MARK: Phone

                    PhoneContentView(
                        configuration:
                            viewModel.configuration
                    )

                    // MARK: Zipper

                    ZipperCanvasView(
                        progress:
                            viewModel.progress,
                        phase:
                            viewModel.phase,
                        configuration:
                            viewModel.configuration
                    )

                    // MARK: Zipper Interaction Area

                    // The whole zipper width/height is interactive.
                    // The user does not need to hit the tiny slider.
                    Color.clear
                        .frame(
                            width:
                                geometry.zipperWidth,
                            height:
                                geometry.zipperHeight
                        )
                        .contentShape(
                            Rectangle()
                        )
                        .position(
                            x:
                                geometry.centerX,
                            y:
                                geometry.centerY
                        )
                        .gesture(
                            zipperDrag(
                                travel:
                                    geometry.sliderBottomY
                                    - geometry.sliderTopY
                            )
                        )
                }
                .frame(
                    width: size.width,
                    height: size.height
                )
            }

            // MARK: Controls

            controls
        }

        // MARK: Full Screen

        .ignoresSafeArea()
    }

    // MARK: - Zipper Drag

    /// Creates the direct finger/cursor interaction.
    private func zipperDrag(
        travel: CGFloat
    ) -> some Gesture {

        DragGesture(
            minimumDistance: 0
        )
        .onChanged { value in

            viewModel.updateDrag(
                translationY:
                    value.translation.height,
                zipperTravel:
                    travel
            )
        }
        .onEnded { _ in
            viewModel.endDrag()
        }
    }

    // MARK: - Controls

    private var controls: some View {

        VStack {

            Spacer()

            HStack(
                spacing: 14
            ) {

                // MARK: Reset

                Button {

                    viewModel.reset()

                } label: {

                    Image(
                        systemName:
                            "arrow.counterclockwise"
                    )
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        Color.white
                    )
                    .frame(
                        width: 48,
                        height: 48
                    )
                    .background(
                        Circle()
                            .fill(
                                Color.white.opacity(0.08)
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                Color.white.opacity(0.18),
                                lineWidth: 1
                            )
                    )
                }
            }

            .padding(
                .bottom,
                36
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

#Preview {
    ZipperRevealView()
}
