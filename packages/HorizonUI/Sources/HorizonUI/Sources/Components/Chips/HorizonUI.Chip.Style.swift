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

public extension HorizonUI.Chip {
    enum Size: Double {
        case large = 32
        case medium = 24
        case small = 20
    }

    enum ChipState {
        case `default`
        case disable
        case focused
    }

    protocol ChipStyleProtocol {
        associatedtype BackgroundStyle: ShapeStyle
        associatedtype IconStyle: ShapeStyle

        var state: ChipState { get }
        var foregroundColor: Color { get }
        var borderColor: Color { get }
        var focusedBorderColor: Color { get }
        var opacity: Double { get }

        func background(isPressed: Bool) -> BackgroundStyle
        func iconForeground() -> IconStyle
    }

    struct PrimaryStyle: ChipStyleProtocol {
        public let state: ChipState
        public let opacity: Double = 0
        public var foregroundColor: Color { Color.huiColors.text.title }
        public var borderColor: Color { Color.huiColors.lineAndBorders.lineStroke }
        public var focusedBorderColor: Color { Color.huiColors.surface.inversePrimary }

        public func background(isPressed: Bool) -> Color {
            isPressed ? Color.huiColors.surface.hover : Color.huiColors.surface.cardPrimary
        }

        public func iconForeground() -> Color {
            Color.huiColors.text.title
        }

        init(state: ChipState) {
            self.state = state
        }
    }

    struct AIStyle: ChipStyleProtocol {
        public let state: ChipState
        public let opacity: Double = 0.75

        public var foregroundColor: Color { Color.huiColors.text.title }
        public var borderColor: Color { Color.huiColors.lineAndBorders.lineStroke }
        public var focusedBorderColor: Color { Color.huiColors.surface.inversePrimary }

        public  func background(isPressed: Bool) -> LinearGradient {
            Color.huiColors.surface.igniteAIPrimaryGradient
        }

        public  func iconForeground() -> LinearGradient {
            Color.huiColors.surface.igniteAIPrimaryGradient
        }

        init(state: ChipState) {
            self.state = state
        }
    }

    struct CustomStyle: ChipStyleProtocol {
        public let state: ChipState
        public let foregroundColor: Color
        public let borderColor: Color
        public let focusedBorderColor: Color
        public let opacity: Double
        private let backgroundNormal: Color
        private let backgroundPressed: Color
        private let iconColor: Color

        public func background(isPressed: Bool) -> Color {
            isPressed ? backgroundPressed : backgroundNormal
        }

        public func iconForeground() -> Color {
            iconColor
        }

       public init(
            state: ChipState,
            foregroundColor: Color,
            backgroundNormal: Color,
            backgroundPressed: Color,
            borderColor: Color,
            focusedBorderColor: Color,
            iconColor: Color,
            opacity: Double = 0
        ) {
            self.state = state
            self.foregroundColor = foregroundColor
            self.backgroundNormal = backgroundNormal
            self.backgroundPressed = backgroundPressed
            self.borderColor = borderColor
            self.focusedBorderColor = focusedBorderColor
            self.iconColor = iconColor
            self.opacity = opacity
        }
    }

    enum Style {
        case primary(PrimaryStyle)
        case ai(AIStyle)
        case custom(CustomStyle)

        public static func primary(state: ChipState) -> Style {
            .primary(PrimaryStyle(state: state))
        }

        public static func ai(state: ChipState) -> Style {
            .ai(AIStyle(state: state))
        }

        public static func custom(
            state: ChipState,
            foregroundColor: Color,
            backgroundNormal: Color,
            backgroundPressed: Color,
            borderColor: Color,
            focusedBorderColor: Color,
            iconColor: Color,
            opacity: Double = 0
        ) -> Style {
            .custom(CustomStyle(
                state: state,
                foregroundColor: foregroundColor,
                backgroundNormal: backgroundNormal,
                backgroundPressed: backgroundPressed,
                borderColor: borderColor,
                focusedBorderColor: focusedBorderColor,
                iconColor: iconColor,
                opacity: opacity
            ))
        }

        public var state: ChipState {
            switch self {
            case .primary(let style): style.state
            case .ai(let style): style.state
            case .custom(let style): style.state
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary(let style): style.foregroundColor
            case .ai(let style): style.foregroundColor
            case .custom(let style): style.foregroundColor
            }
        }

        var borderColor: Color {
            switch self {
            case .primary(let style): style.borderColor
            case .ai(let style): style.borderColor
            case .custom(let style): style.borderColor
            }
        }

        var focusedBorderColor: Color {
            switch self {
            case .primary(let style): style.focusedBorderColor
            case .ai(let style): style.focusedBorderColor
            case .custom(let style): style.focusedBorderColor
            }
        }

        var opacity: Double {
            switch self {
            case .primary(let style): style.opacity
            case .ai(let style): style.opacity
            case .custom(let style): style.opacity
            }
        }

        func background(isPressed: Bool) -> AnyShapeStyle {
            switch self {
            case .primary(let style): AnyShapeStyle(style.background(isPressed: isPressed))
            case .ai(let style): AnyShapeStyle(style.background(isPressed: isPressed))
            case .custom(let style): AnyShapeStyle(style.background(isPressed: isPressed))
            }
        }

        func iconForeground() -> AnyShapeStyle {
            switch self {
            case .primary(let style): AnyShapeStyle(style.iconForeground())
            case .ai(let style): AnyShapeStyle(style.iconForeground())
            case .custom(let style): AnyShapeStyle(style.iconForeground())
            }
        }
    }
}
