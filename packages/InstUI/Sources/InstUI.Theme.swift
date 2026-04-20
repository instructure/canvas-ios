//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

extension InstUI {
    public struct Theme: Sendable {
        public static let `default`: InstUI.Theme = {
            // swiftlint:disable:next force_try
            try! InstUI.Theme()
        }()

        public let colors: InstUI.Semantic.Color
        public let size: InstUI.Semantic.Size
        public let spacing: InstUI.Semantic.Spacing
        public let borderRadius: InstUI.Semantic.BorderRadius
        public let borderWidth: InstUI.Semantic.BorderWidth
        public let fontSize: InstUI.Semantic.FontSize
        public let opacity: InstUI.Semantic.Opacity
        public let fontWeights: InstUI.Semantic.FontWeight
        public let fontFamilies: InstUI.Semantic.FontFamily

        public init() throws {
            try self.init(
                colorLoader: InstUI.Semantic.ColorLoader(),
                layoutLoader: InstUI.Semantic.LayoutLoader()
            )
        }

        public init(
            colorLoader: InstUI.Semantic.ColorLoader,
            layoutLoader: InstUI.Semantic.LayoutLoader
        ) throws {
            self.colors = try colorLoader.load()
            let layout = try layoutLoader.load()
            self.size = layout.size
            self.spacing = layout.spacing
            self.borderRadius = layout.borderRadius
            self.borderWidth = layout.borderWidth
            self.fontSize = layout.fontSize
            self.opacity = layout.opacity
            self.fontWeights = layout.fontWeights
            self.fontFamilies = layout.fontFamilies
        }
    }
}
