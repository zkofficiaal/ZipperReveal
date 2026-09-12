//
//  PhoneContentView.swift
//  ZipperReveal
//
//  Created by Z.K   on 11/09/2026.
//  Phone content revealed underneath the zipper.
//

import SwiftUI

struct PhoneContentView: View {

    // MARK: - Configuration

    let configuration:
        ZipperConfiguration

    // MARK: - Body

    var body: some View {

        GeometryReader { proxy in

            let size =
                proxy.size

            // The content fills the available screen.
            // The simulator/device frame is already outside this view,
            // so we do not draw a second phone frame inside the screen.
            let phoneWidth =
                size.width

            let phoneHeight =
                size.height

            ZStack {

                // MARK: Screen

                Color.black

                    .ignoresSafeArea()

                // MARK: Dynamic Island

                Capsule()
                    .fill(
                        Color.black
                    )
                    .frame(
                        width: phoneWidth * 0.16,
                        height: phoneHeight * 0.035
                    )
                    .offset(
                        y: -phoneHeight * 0.455
                )

                // MARK: Hello World

                Text("Hello!\nDevTechZahid")
                    .font(
                        .system(
                            size: phoneWidth * 0.080,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        Color.white
                    )
                    .multilineTextAlignment(
                        .center
                    )
                    .lineSpacing(
                        -2
                )
                
                // MARK: Bottom Decorative Object

                bottomObject(
                    phoneWidth: phoneWidth,
                    phoneHeight: phoneHeight
                )
                .offset(
                    y: phoneHeight * 0.39
                )
            }
            .frame(
                width: phoneWidth,
                height: phoneHeight
            )
        }
    }

    // MARK: - Bottom Object

    /// Small dark decorative object shown at the bottom of the phone.
    @ViewBuilder
    private func bottomObject(
        phoneWidth: CGFloat,
        phoneHeight: CGFloat
    ) -> some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: 4
            )
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.55),
                        Color.black,
                        Color.gray.opacity(0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            RoundedRectangle(
                cornerRadius: 4
            )
            .stroke(
                Color.white.opacity(0.15),
                lineWidth: 0.7
            )

            RoundedRectangle(
                cornerRadius: 2
            )
            .fill(
                Color.black.opacity(0.65)
            )
            .frame(
                width: phoneWidth * 0.035,
                height: phoneHeight * 0.075
            )
            .offset(
                x: phoneWidth * 0.012
            )
        }
        .frame(
            width: phoneWidth * 0.10,
            height: phoneHeight * 0.11
        )
    }
}
