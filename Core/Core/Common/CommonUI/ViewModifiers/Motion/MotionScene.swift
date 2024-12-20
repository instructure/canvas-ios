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

/**
 The main purpose of this view is to provide a shared MotionDetector object to all views in its body.
 */
public struct MotionScene<Content>: View where Content: View {
    @ObservedObject private var motionDetector = MotionDetector()
    private let layers: (MotionDetector) -> Content

    public init(@ViewBuilder _ layers: @escaping (MotionDetector) -> Content) {
        self.layers = layers
    }

    public var body: some View {
        ZStack {
            layers(motionDetector)
        }
    }
}
