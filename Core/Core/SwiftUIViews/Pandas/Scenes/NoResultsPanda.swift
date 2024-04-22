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

public struct NoResultsPanda: PandaScene {
    public var name: String { "noresults" }
    public var foreground: AnyView { AnyView(Image("PandaNoResults", bundle: .core)) }
    public var background: AnyView { AnyView(SwiftUI.EmptyView()) }
    public var isParallaxDisabled: Bool { false }

    public var offset: (background: CGSize, foreground: CGSize) {(
        background: CGSize(width: 0, height: 0),
        foreground: CGSize(width: 0, height: 0))
    }
    public var height: CGFloat { 168 }

    public init() {}
}

struct NoResultsPanda_Previews: PreviewProvider {
    static var previews: some View {
        InteractivePanda(scene: NoResultsPanda())
    }
}
