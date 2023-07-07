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

public struct IndeterminateCircleProgressViewStyle: ProgressViewStyle {
    // MARK: - Dependencies

    private let size: CGFloat
    private let lineWidth: CGFloat
    private let color: Color

    // MARK: - Private properties

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

    // MARK: - Init

    init(
        size: CGFloat,
        lineWidth: CGFloat,
        color: Color = .accentColor
    ) {
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
    }

    public func makeBody(configuration _: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(
                    color,
                    lineWidth: lineWidth
                )
                .opacity(0.2)
            Circle()
                .trim(from: 0, to: fillWidth)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(fillRotate)
                .onReceive(animationTimer) { _ in
                    progressAnimation()
                }
                .rotationEffect(rotate)
                .onAppear {
                    DispatchQueue.main.async {
                        fillWidth = 0.1
                        rotate = .zero
                        fillRotate = .zero

                        // Until the animation timer's first fire we still need to show some animation
                        progressAnimation()

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
        .frame(width: size, height: size)
    }

    private func progressAnimation() {
        withAnimation(easeAnimation) {
            fillRotate += Angle(radians: fillWidth == 0.1 ? 0.5 * .pi : 1.5 * .pi)
            fillWidth = fillWidth == 0.1 ? 0.725 : 0.1
        }
    }
}

public extension ProgressViewStyle where Self == IndeterminateCircleProgressViewStyle {
    static func indeterminateCircle(
        size: CGFloat = 32,
        lineWidth: CGFloat = 3,
        color: Color = .accentColor
    ) -> IndeterminateCircleProgressViewStyle {
        IndeterminateCircleProgressViewStyle(
            size: size,
            lineWidth: lineWidth,
            color: color
        )
    }
}

struct IndeterminateCircularProgressViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .previewLayout(.sizeThatFits)

        ProgressView()
            .progressViewStyle(.indeterminateCircle(size: 20, lineWidth: 2))
            .previewLayout(.sizeThatFits)
    }
}
