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

public struct MotionModifier: ViewModifier {
    @ObservedObject private var detector: MotionDetector
    private let horizontalMultiplier: Double
    private let verticalMultiplier: Double

    public init(detector: MotionDetector, horizontalMultiplier: Double, verticalMultiplier: Double) {
        self.detector = detector
        self.horizontalMultiplier = horizontalMultiplier
        self.verticalMultiplier = verticalMultiplier
    }

    public func body(content: Content) -> some View {
        content
            .offset(x: CGFloat(horizontalMultiplier * detector.roll), y: CGFloat(verticalMultiplier * detector.pitch))
    }
}

public extension View {

    @ViewBuilder
    func motion(_ detector: MotionDetector, horizontalMultiplier: Double = 0, verticalMultiplier: Double = 0) -> some View {
        modifier(MotionModifier(detector: detector, horizontalMultiplier: horizontalMultiplier, verticalMultiplier: verticalMultiplier))
    }
}
