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

    public init(scene: PandaScene, title: Text? = nil, subtitle: Text? = nil) {
        self.scene = scene
        self.title = title
        self.subtitle = subtitle
    }

    @ViewBuilder
    public var body: some View {
        VStack(spacing: 0) {
            MotionScene { detector in
                let offset = scene.offset
                scene.background
                    .motion(detector, horizontalMultiplier: -40, verticalMultiplier: -10)
                    .offset(offset.background)
                scene.foreground
                    .motion(detector, horizontalMultiplier: 40, verticalMultiplier: 10)
                    .offset(offset.foreground)
            }
            .frame(height: scene.height)
            .padding(.bottom, 25)
            .zIndex(1)

            if let title = title {
                title
                    .font(.bold24)
                    .foregroundColor(.textDarkest)
                    .padding(.bottom, 8)
            }

            if let subtitle = subtitle {
                subtitle
                    .font(.regular16)
                    .foregroundColor(.textDarkest)
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
