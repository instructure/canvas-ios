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

public struct InteractivePanda: View {
    private let scene: PandaScene
    private let title: Text?
    private let subtitle: Text?

    public init(scene: PandaScene) {
        self.scene = scene
        self.title = nil
        self.subtitle = nil
    }

    public init(scene: PandaScene, title: Text? = nil, subtitle: Text? = nil) {
        self.scene = scene
        self.title = title
        self.subtitle = subtitle
    }

    public init(scene: PandaScene, title: String? = nil, subtitle: String? = nil) {
        self.scene = scene

        if let title {
            self.title = Text(title)
        } else {
            self.title = nil
        }

        if let subtitle {
            self.subtitle = Text(subtitle)
        } else {
            self.subtitle = nil
        }
    }

    @ViewBuilder
    public var body: some View {
        VStack(spacing: 0) {
            MotionScene { detector in
                let noMovement = scene.isParallaxDisabled
                let offset = scene.offset
                let horizontalMultiplier = noMovement ? 0.0 : 40
                let verticalMultiplier = noMovement ? 0.0 : 10
                scene.background
                    .motion(detector, horizontalMultiplier: -horizontalMultiplier, verticalMultiplier: -verticalMultiplier)
                    .offset(offset.background)
                scene.foreground
                    .motion(detector, horizontalMultiplier: horizontalMultiplier, verticalMultiplier: verticalMultiplier)
                    .offset(offset.foreground)
            }
            .frame(height: scene.height)
            .padding(.bottom, 25)
            .zIndex(1)

            if let title = title {
                title
                    .font(.bold20)
                    .foregroundColor(.textDarkest)
                    .padding(.bottom, 8)
            }

            if let subtitle = subtitle {
                subtitle
                    .font(.regular16)
                    .foregroundColor(.textDark)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct InteractivePanda_Previews: PreviewProvider {
    static var previews: some View {
        InteractivePanda(scene: GradesPanda())
    }
}
