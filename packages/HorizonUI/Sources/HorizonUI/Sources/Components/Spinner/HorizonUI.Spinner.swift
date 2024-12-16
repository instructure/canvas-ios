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

import Combine
import SwiftUI

extension HorizonUI {
    struct Spinner: View {
        // MARK: - Dependencies

        private let showBackground: Bool
        private let size: HorizonUI.Spinner.Size

        // MARK: - Private

        private let spinDuration = 3.0
        private let backgroundColor: Color = Color.huiColors.lineAndBorders.lineDivider
        private let foregroundColor = Color.huiColors.surface.institution
        @State private var rotation: Double = 0

        // MARK: - Init

        init(size: HorizonUI.Spinner.Size = .medium, showBackground: Bool = false) {
            self.size = size
            self.showBackground = showBackground
        }

        var body: some View {
            ZStack {
                if self.showBackground {
                    SpinnerCircle(
                        color: self.backgroundColor,
                        diameter: self.size.dimension,
                        strokeWidth: self.size.strokeWidth,
                        animated: false
                    )
                }
                SpinnerCircle(
                    color: self.foregroundColor,
                    diameter: self.size.dimension,
                    strokeWidth: self.size.strokeWidth
                )
                .rotationEffect(.degrees(rotation))
                .animation(
                    .linear(duration: spinDuration).repeatForever(autoreverses: false),
                    value: rotation
                )
            }
            .frame(
                width: self.size.dimension + self.size.strokeWidth,
                height: self.size.dimension + self.size.strokeWidth
            )
            .onAppear {
                self.rotation = 360
            }
        }
    }
}

private struct SpinnerCircle: View {
    // MARK: - Dependencies

    private let animated: Bool
    private let color: Color
    private let diameter: CGFloat
    private let strokeWidth: CGFloat

    // MARK: - Configuration

    private static let longStroke = 310.0
    private static let shortStroke = 10.0
    private static let short = 0.5
    private static let long = 1.25

    // MARK: - State

    @State private var timeout: Double? {
        didSet {
            guard let timeout = self.timeout else { return }

            self.timer = Timer.publish(
                every: self.animated ? timeout : TimeInterval.greatestFiniteMagnitude,
                on: .main,
                in: .common
            )
            .autoconnect()

            if animated && self.strokeLength == SpinnerCircle.longStroke {
                self.strokeLength = SpinnerCircle.shortStroke
            } else if animated {
                self.strokeLength = SpinnerCircle.longStroke
            } else {
                self.strokeLength = 360.0
            }

            self.startDegrees = self.endDegrees
            self.endDegrees = self.startDegrees + self.strokeLength
        }
    }
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @State private var endDegrees: Double = 360.0
    @State private var startDegrees: Double = 0.0
    @State private var strokeLength = SpinnerCircle.shortStroke

    // MARK: - init

    init(color: Color,
         diameter: CGFloat,
         strokeWidth: CGFloat,
         animated: Bool = true
    ) {
        self.animated = animated
        self.color = color
        self.diameter = diameter
        self.strokeWidth = strokeWidth
        self.endDegrees = 0.0 + (animated ? SpinnerCircle.shortStroke : 360.0)
        self.timeout = SpinnerCircle.long
        self.timer = Timer.publish(
            every: 0.05,
            on: .main,
            in: .common
        )
        .autoconnect()
    }

    var body: some View {
        PartialCircleShape(
            diameter: self.diameter,
            startDegrees: self.startDegrees,
            endDegrees: self.endDegrees
        )
        .stroke(
            self.color,
            style: StrokeStyle(
                lineWidth: self.strokeWidth,
                lineCap: .round
            )
        )
        .animation(
            .easeInOut(duration: self.timeout ?? 0.0),
            value: self.endDegrees
        )
        .animation(
            .easeInOut(duration: self.timeout ?? 0.0),
            value: self.startDegrees
        )
        .onReceive(self.timer) { _ in
            self.timeout = self.timeout == SpinnerCircle.long ? SpinnerCircle.short : SpinnerCircle.long
        }
    }
}

private extension View {
    func conditionalModifier<Content: View>( _ condition: Bool, modifier: (Self) -> Content ) -> some View {
        if condition {
            return AnyView(modifier(self))
        } else {
            return AnyView(self)
        }
    }
}

private struct PartialCircleShape: Shape {
    private let diameter: CGFloat
    private var startDegrees: CGFloat
    private var endDegrees: CGFloat

    init(diameter: CGFloat, startDegrees: CGFloat, endDegrees: CGFloat) {
        self.diameter = diameter
        self.startDegrees = startDegrees
        self.endDegrees = endDegrees
    }

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(self.startDegrees, self.endDegrees) }
        set {
            self.startDegrees = newValue.first
            self.endDegrees = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = self.diameter / 2

        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(self.startDegrees),
            endAngle: .degrees(self.endDegrees),
            clockwise: false
        )

        return path
    }
}

#Preview {
    HorizonUI.Spinner(showBackground: true)
}
