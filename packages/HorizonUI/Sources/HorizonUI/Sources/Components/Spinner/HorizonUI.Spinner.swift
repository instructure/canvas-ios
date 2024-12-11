//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

extension HorizonUI {
    struct Spinner: View {
        // MARK: - Dependencies

        private let showBackground: Bool
        private let size: SpinnerSize

        // MARK: - Private

        private let backgroundColor = Color(red: 232/255, green: 234/255, blue: 236/255)
        private let foregroundColor = Color(red: 9/255, green: 80/255, blue: 140/255)

        // MARK: - Init

        init(size: SpinnerSize = .medium, showBackground: Bool = false) {
            self.size = size
            self.showBackground = showBackground
        }

        var body: some View {
            ZStack {
                if showBackground {
                    SpinnerCircle(
                        color: backgroundColor,
                        diameter: size.dimension,
                        isFullCircle: true,
                        strokeWidth: size.strokeWidth
                    )
                }
                SpinnerCircle(
                    color: foregroundColor,
                    diameter: size.dimension,
                    isFullCircle: false,
                    strokeWidth: size.strokeWidth
                )
            }
            .frame(
                width: size.dimension + size.strokeWidth,
                height: size.dimension + size.strokeWidth
            )
        }
    }
}

private struct SpinnerCircle: View {
    // MARK: - Dependencies

    let color: Color
    let diameter: CGFloat
    let isFullCircle: Bool
    let strokeWidth: CGFloat

    // MARK: - Private

    @State private var rotation: Double = 0

    var body: some View {
        PartialCircleShape(diameter: diameter, isFullCircle: isFullCircle)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: strokeWidth,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    .linear(duration: 1)
                        .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

private struct PartialCircleShape: Shape {
    let diameter: CGFloat
    let isFullCircle: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = diameter/2

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(isFullCircle ? 360 : 270),
            clockwise: false
        )

        return path
    }
}

#Preview {
    HorizonUI.Spinner(showBackground: true)
}
