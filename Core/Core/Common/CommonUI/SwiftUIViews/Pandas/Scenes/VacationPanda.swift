//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public struct VacationPanda: PandaScene {
    public var name: String { "vacation" }
    public var foreground: AnyView { AnyView(HammockPanda(imageName: "PandaNoEvents")) }
    public var background: AnyView { AnyView(SwiftUI.EmptyView()) }
    public var isParallaxDisabled: Bool { false }

    public var offset: (background: CGSize, foreground: CGSize) {(
        background: CGSize(width: 0, height: 0),
        foreground: CGSize(width: 0, height: 0))
    }
    public var height: CGFloat { 168 }

    public init() {}
}

private struct HammockPanda: View {
    @State private var swayOffset: CGFloat = 0
    @State private var swayAngle: Double = 0
    private let imageName: String

    public init(imageName: String) {
        self.imageName = imageName
    }

    @ViewBuilder
    public var body: some View {
        Image(imageName, bundle: .core)
            .offset(x: swayOffset)
            .rotationEffect(.degrees(swayAngle))
            .animation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true),
                value: swayOffset
            )
            .animation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true),
                value: swayAngle
            )
            .onAppear {
                swayOffset = 8.0  // Gentle side-to-side movement
                swayAngle = 2.0   // Slight rotation as hammock rocks
            }
    }
}

struct VacationPanda_Previews: PreviewProvider {
    static var previews: some View {
        InteractivePanda(scene: VacationPanda())
    }
}
