//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI

public struct IndeterminateCircularProgressViewStyle: ProgressViewStyle {
    public static let size: CGFloat = 32

    @State private var isVisible = false
    @State private var fillWidth: CGFloat = 0.1
    @State private var fillRotate: Angle = .zero
    @State private var rotate: Angle = .zero

    private let easeAnimation = Animation.timingCurve(
        0.25, 0.1, 0.25, 1.0,
        duration: 0.875
    )
    private let animationTimer = Timer.publish(
        every: 0.875,
        on: .main,
        in: .common
    ).autoconnect()

    public func makeBody(configuration _: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(
                    Color.accentColor,
                    lineWidth: 3
                )
                .opacity(0.2)
            Circle()
                .trim(from: 0, to: fillWidth)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(fillRotate)
                .onReceive(animationTimer) { _ in
                    progressAnimation()
                }
                .rotationEffect(rotate)
                .onAppear {
                    fillWidth = 0.1
                    rotate = .zero
                    fillRotate = .zero
                    isVisible = true

                    // Until the animation timer's first fire we still need to show some animation
                    progressAnimation()

                    // This repeating animation caused other parts of the UI to animate their appearance repeatedly on iOS 14.0 and below.
                    if #available(iOS 14.1, *) {
                        withAnimation(.linear(duration: 2.25).repeatForever(autoreverses: false)) {
                            rotate = Angle(radians: 2 * .pi)
                        }
                    }
                }
                .onDisappear {
                    animationTimer.upstream.connect().cancel()
                }
                .accessibility(label: Text("Loading", bundle: .core))
        }
        .frame(width: Self.size, height: Self.size)
    }

    private func progressAnimation() {
        withAnimation(easeAnimation) {
            fillRotate += Angle(radians: fillWidth == 0.1 ? 0.5 * .pi : 1.5 * .pi)
            fillWidth = fillWidth == 0.1 ? 0.725 : 0.1
        }
    }
}

extension ProgressViewStyle where Self == IndeterminateCircularProgressViewStyle {
    static var indeterminateCircular: IndeterminateCircularProgressViewStyle { .init() }
}

struct IndeterminateCircularProgressViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircular)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView()
            .progressViewStyle(.indeterminateCircular)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)

        ProgressView()
            .progressViewStyle(.indeterminateCircular)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView()
            .progressViewStyle(.indeterminateCircular)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
