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
        private let size: HorizonUI.Spinner.Size

        // MARK: - Private

        private let backgroundColor:Color = Color(red: 232/255, green: 234/255, blue: 236/255)
        private let foregroundColor = Color(red: 9/255, green: 80/255, blue: 140/255)
        @State private var rotation: Double = 0

        // MARK: - Init

        init(size: HorizonUI.Spinner.Size = .medium, showBackground: Bool = false) {
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
                .rotationEffect(.degrees(rotation))
                .animation(
                    .linear(duration: 1.0).repeatForever(autoreverses: false),
                    value: rotation
                )
            }
            .frame(
                width: size.dimension + size.strokeWidth,
                height: size.dimension + size.strokeWidth
            )
            .onAppear {
                rotation = 360
            }
        }
    }
}

private struct SpinnerCircle: View {
    // MARK: - Dependencies

    let color: Color
    let diameter: CGFloat
    let isFullCircle: Bool
    let strokeWidth: CGFloat

    var body: some View {
        PartialCircleShape(diameter: diameter, isFullCircle: isFullCircle)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: strokeWidth,
                    lineCap: .round
                )
            )
    }
}

private struct PartialCircleShape: Shape {
    let diameter: CGFloat
    var arcDegrees: CGFloat

    init(diameter: CGFloat, arcDegrees: CGFloat) {
        self.diameter = diameter
        self.arcDegrees = arcDegrees
    }

    var animatableData: CGFloat {
        get { arcDegrees }
        set { arcDegrees = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = diameter/2

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(arcDegrees),
            clockwise: false
        )

        return path
    }
}

#Preview {
    HorizonUI.Spinner(showBackground: true)
}
