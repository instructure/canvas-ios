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

public protocol PandaScene {
    /** The name of the scene is used to look up default background and foreground images. */
    var name: String { get }
    /** The offset of the background and foreground views from the center of the view. */
    var offset: (background: CGSize, foreground: CGSize) { get }
    /**
     The total height of the scene. This value must be set in a way that if you add a background color to the panda view
     then both the panda and the panda background should be inside the colored background and
     there should be some spacing below the scene so the title text doesn't get too close to it.
     */
    var height: CGFloat { get }
    var background: AnyView { get }
    var foreground: AnyView { get }
    var isParallaxDisabled: Bool { get }
}

public extension PandaScene {
    var backgroundFileName: String { "panda-\(name)-background" }
    var foregroundFileName: String { "panda-\(name)-foreground" }
    var foreground: AnyView { AnyView(BouncyImage(imageFileName: foregroundFileName)) }
    var background: AnyView { AnyView(ImageBackground(scene: self)) }
    var isParallaxDisabled: Bool { false }
}
