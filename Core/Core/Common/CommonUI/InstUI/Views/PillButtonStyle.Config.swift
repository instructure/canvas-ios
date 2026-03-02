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

    public struct Config: Equatable {
        public let isFilled: Bool
        public let foregroundColor: Color?
        public let borderColor: Color?

        private init(
            isFilled: Bool,
            foregroundColor: Color?,
            borderColor: Color?
        ) {
            self.isFilled = isFilled
            self.foregroundColor = foregroundColor
            self.borderColor = borderColor
        }
    }
}

extension InstUI.PillButtonStyle.Config {

    public static var tintFilled: Self {
        Self(
            isFilled: true,
            foregroundColor: .textLightest,
            borderColor: .clear
        )
    }

    public static var tintOutlined: Self {
        Self(
            isFilled: false,
            foregroundColor: nil,
            borderColor: nil
        )
    }

    public static var defaultOutlined: Self {
        Self(
            isFilled: false,
            foregroundColor: .textDarkest,
            borderColor: .borderMedium
        )
    }

    public static func customOutlined(textColor: Color, borderColor: Color) -> Self {
        Self(
            isFilled: false,
            foregroundColor: textColor,
            borderColor: borderColor
        )
    }
}

#if DEBUG

#Preview {
    PillButtonStorybook()
}

#endif
