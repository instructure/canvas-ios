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
        public let borderColor: Color
        private let borderWidth: CGFloat

        private init(
            foregroundColor: Color,
            backgroundColor: Color,
            borderColor: Color,
            borderWidth: CGFloat
        ) {
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
        }

        public func borderWidth(uiScale: CGFloat) -> CGFloat {
            borderWidth * uiScale
        }

        /// Buttons without a background color are considered outlined style buttons
        public var isOutlined: Bool {
            backgroundColor == .clear
        }

        public func backgroundColor(isPressed: Bool, isDarkMode: Bool) -> Color {
            // Filled styles always have solid backgrounds and selection is handled with opacity
            guard isOutlined else {
                return backgroundColor
            }

            if isPressed {
                // In dark mode we need stronger colors to be as prominent as in light mode
                let opacity = isDarkMode ? 0.3 : 0.1
                return borderColor.opacity(opacity)
            } else {
                return Color.clear
            }
        }

        public func opacity(isPressed: Bool, isEnabled: Bool) -> Double {
            if isOutlined {
                return isEnabled ? 1.0 : 0.7
            }
            return isPressed || !isEnabled ? 0.7 : 1.0
        }
    }
}

extension InstUI.PillButtonStyle.Config {

    public static var brandFilled: Self {
        Self(
            foregroundColor: .textLightest,
            backgroundColor: .brandPrimary,
            borderColor: .clear,
            borderWidth: 0
        )
    }

    public static var defaultOutlined: Self {
        Self(
            foregroundColor: .textDarkest,
            backgroundColor: .clear,
            borderColor: .borderMedium,
            borderWidth: 1
        )
    }

    public static func filled(color: Color) -> Self {
        Self(
            foregroundColor: .textLightest,
            backgroundColor: color,
            borderColor: .clear,
            borderWidth: 0
        )
    }

    public static func outlined(textColor: Color, borderColor: Color) -> Self {
        Self(
            foregroundColor: textColor,
            backgroundColor: .clear,
            borderColor: borderColor,
            borderWidth: 1
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
