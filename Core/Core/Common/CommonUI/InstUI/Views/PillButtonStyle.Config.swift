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

extension InstUI.PillButtonStyle {

    public struct Config {
        public let foregroundColor: Color
        public let backgroundColor: Color
        public let strokeColor: Color
        private let strokeWidth: CGFloat

        private init(
            foregroundColor: Color,
            backgroundColor: Color,
            strokeColor: Color,
            strokeWidth: CGFloat
        ) {
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
            self.strokeColor = strokeColor
            self.strokeWidth = strokeWidth
        }

        public func strokeWidth(uiScale: CGFloat) -> CGFloat {
            strokeWidth * uiScale
        }
    }
}

extension InstUI.PillButtonStyle.Config {

    public static var brandFilled: Self {
        Self(
            foregroundColor: .textLightest,
            backgroundColor: .brandPrimary,
            strokeColor: .clear,
            strokeWidth: 0
        )
    }

    public static var defaultOutlined: Self {
        Self(
            foregroundColor: .textDarkest,
            backgroundColor: .clear,
            strokeColor: .borderMedium,
            strokeWidth: 1.5
        )
    }

    public static func filled(color: Color) -> Self {
        Self(
            foregroundColor: .textLightest,
            backgroundColor: color,
            strokeColor: .clear,
            strokeWidth: 0
        )
    }

    public static func outlined(textColor: Color, borderColor: Color) -> Self {
        Self(
            foregroundColor: textColor,
            backgroundColor: .clear,
            strokeColor: borderColor,
            strokeWidth: 1.5
        )
    }

    public static func outlined(color: Color) -> Self {
        outlined(textColor: color, borderColor: color)
    }
}

#if DEBUG

#Preview {
    PillButtonStorybook()
}

#endif
