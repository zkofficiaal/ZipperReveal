//
//  ZipperRevealView.swift
//  ZipperReveal
//
//  Created by Z.K   on 11/09/2026.

//  Main screen for the zipper reveal animation.
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

            // MARK: Animation

            TimelineView(
                .animation(
                    minimumInterval: 1.0 / 60.0
                )
            ) { timeline in

                let state =
                    viewModel.state(
                        at: timeline.date
                    )

                GeometryReader { proxy in

                    ZStack {

                        // MARK: Phone

                        PhoneContentView(
                            configuration:
                                viewModel.configuration
                        )

                        // MARK: Zipper

                        ZipperCanvasView(
                            progress:
                                state.progress,
                            phase:
                                state.phase,
                            configuration:
                                viewModel.configuration
                        )
                    }

                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height
                    )
                }
            }

            // MARK: Controls

            controls
        }

        // MARK: Full Screen

        .ignoresSafeArea()
    }

    // MARK: - Controls

    private var controls: some View {

        VStack {

            Spacer()

            HStack(
                spacing: 14
            ) {

                // MARK: Play / Pause

                Button {

                    viewModel.togglePlayback()

                } label: {

                    Image(
                        systemName:
                            viewModel.isPlaying
                            ? "pause.fill"
                            : "play.fill"
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
