//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public extension HorizonUI {

    // MARK: - Button Styles Struct

    struct ButtonStyles: ButtonStyle {
        // MARK: - Common Dependencies

        @Environment(\.isEnabled) private var isEnabled
        private let type: HorizonUI.ButtonStyles.ButtonType
        private let isSmall: Bool

        // MARK: - Primary and Secondary Button Dependencies

        private let fillsWidth: Bool
        private let leading: Image?
        private let trailing: Image?
        private let smallButtonSize = 32.0
        private let mediumButtonSize = 44.0
        private let isTextUnderlined: Bool

        // MARK: - Icon Button Dependencies

        private let badgeStyle: HorizonUI.Badge.Style?
        private let badgeType: HorizonUI.Badge.BadgeType?
        private let icon: Image?

        fileprivate init(
            type: HorizonUI.ButtonStyles.ButtonType,
            isSmall: Bool = false,
            fillsWidth: Bool = false,
            leading: Image? = nil,
            trailing: Image? = nil,
            isTextUnderlined: Bool = false
        ) {
            self.type = type
            self.isSmall = isSmall
            self.fillsWidth = fillsWidth
            self.leading = leading
            self.trailing = trailing
            self.isTextUnderlined = isTextUnderlined
            self.badgeStyle = nil
            self.badgeType = nil
            self.icon = nil
        }

        fileprivate init(
            type: HorizonUI.ButtonStyles.ButtonType,
            badgeStyle: HorizonUI.Badge.Style,
            badgeType: HorizonUI.Badge.BadgeType?,
            isSmall: Bool = false,
            icon: Image
        ) {
            self.type = type
            self.badgeStyle = badgeStyle
            self.badgeType = badgeType
            self.isSmall = isSmall
            self.icon = icon

            self.fillsWidth = false
            self.leading = nil
            self.trailing = nil
            self.isTextUnderlined = false
        }

        @ViewBuilder
        public func makeBody(configuration: Configuration) -> some View {
            if icon != nil {
                iconButton(configuration)
            } else {
                primaryButton(configuration)
            }
        }

        private func iconButton(_ configuration: Configuration) -> some View {
            ZStack {
                if let icon = icon {
                    icon
                        .frame(
                            width: isSmall ? smallButtonSize : mediumButtonSize,
                            height: isSmall ? smallButtonSize : mediumButtonSize
                        )
                        .modifier(
                            HorizonButtonModifier(
                                type: type,
                                isEnabled: isEnabled,
                                isTextUnderlined: isTextUnderlined,
                                configuration: configuration
                            )
                        )

                    if let badgeType, let badgeStyle {
                        HorizonUI.Badge(type: badgeType, style: badgeStyle)
                            .offset(x: 15, y: -15)
                    }
                }
            }
        }

        private func primaryButton(_ configuration: Configuration) -> some View {
            let foreground = type.foregroundColor(configuration)
            return HStack {
                leading?
                    .renderingMode(.template)
                    .foregroundColor(foreground)

                configuration.label

                trailing?
                    .renderingMode(.template)
                    .foregroundColor(foreground)
            }
            .huiTypography(.buttonTextLarge)
            .underline(isTextUnderlined, pattern: .solid)
            .padding(.horizontal, .huiSpaces.space16)
            .frame(height: isSmall ? smallButtonSize : mediumButtonSize)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .modifier(
                HorizonButtonModifier(
                    type: type,
                    isEnabled: isEnabled,
                    isTextUnderlined: isTextUnderlined,
                    configuration: configuration
                )
            )
        }
    }
}

// MARK: - Shared Modifier for the Button Styles

struct HorizonButtonModifier: ViewModifier {

    private let configuration: ButtonStyleConfiguration
    private let isEnabled: Bool
    private let isTextUnderlined: Bool
    private let type: HorizonUI.ButtonStyles.ButtonType

    init(
        type: HorizonUI.ButtonStyles.ButtonType,
        isEnabled: Bool,
        isTextUnderlined: Bool,
        configuration: ButtonStyleConfiguration
    ) {
        self.type = type
        self.isEnabled = isEnabled
        self.isTextUnderlined = isTextUnderlined
        self.configuration = configuration
    }

    func body(content: Content) -> some View {
        let foreground = type.foregroundColor(configuration)
        let background = type.background(configuration, isTextUnderlined: isTextUnderlined)
        return content
            .background(background.opacity(isEnabled ? 1.0 : 0.5))
            .foregroundStyle(foreground)
            .overlay(configuration.isPressed && type.hasDarkOverlayWhenPressed ? .black.opacity(0.2) : .clear)
            .huiCornerRadius(level: .level6)
            .overlay {
                RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level6.attributes.radius)
                    .strokeBorder(type.border(configuration, isTextUnderlined: isTextUnderlined), lineWidth: 1)
            }
            .animation(.easeInOut, value: isEnabled)
    }
}

// MARK: - Button Style Definitions

public extension HorizonUI.ButtonStyles {
    enum ButtonType: String, CaseIterable, Identifiable {
        case ai = "AI"
        case black = "Black"
        case danger = "Danger"
        case dangerInverse = "DangerInverse"
        case darkOutline = "DarkOutline"
        case ghost = "Ghost"
        case gray = "Gray"
        case institution = "Institution"
        case white = "White"
        case whiteGrayOutline = "WhiteGrayOutline"
        case whiteOutline = "WhiteOutline"

        public var id: String { rawValue }

        func background(_ configuration: Configuration, isTextUnderlined: Bool = false) -> AnyShapeStyle {
            if(isTextUnderlined) {
                return AnyShapeStyle(Color.clear)
            }
            let colorMap: [Self: Color] = [
                .black: .huiColors.surface.inversePrimary,
                .danger: .huiColors.surface.error,
                .dangerInverse: .huiColors.surface.pageSecondary,
                .darkOutline: .clear,
                .ghost: .clear,
                .gray: .huiColors.surface.pagePrimary,
                .institution: .huiColors.surface.institution,
                .white: .huiColors.surface.pageSecondary,
                .whiteGrayOutline: .huiColors.surface.pageSecondary,
                .whiteOutline: .clear
            ]
            let shapeStyleMap: [Self: AnyShapeStyle] = [
                .ai: AnyShapeStyle(Color.huiColors.surface.igniteAIPrimaryGradient)
            ]
            let pressedColorMap: [Self: Color] = [
                .black: .huiColors.surface.trueBlack,
                .danger: .huiColors.surface.errorPressed,
                .darkOutline: .huiColors.surface.inversePrimary,
                .gray: .huiColors.surface.pageTertiary,
                .whiteOutline: .huiColors.surface.pageSecondary
            ]
            let pressedShapeStyleMap: [Self: AnyShapeStyle] = [
                .ai: AnyShapeStyle(Color.huiColors.surface.igniteAIPrimaryGradient)
            ]
            if let color = pressedColorMap[self], configuration.isPressed {
                return AnyShapeStyle(color)
            }
            if let shapeStyle = pressedShapeStyleMap[self], configuration.isPressed {
                return shapeStyle
            }
            return colorMap[self].map { AnyShapeStyle($0) } ?? shapeStyleMap[self] ?? AnyShapeStyle(Color.clear)
        }

        var badgeStyle: HorizonUI.Badge.Style {
            let badgeMap: [Self: HorizonUI.Badge.Style] = [
                .ai: .primaryWhite,
                .black: .primaryWhite,
                .institution: .primaryWhite,
                .whiteOutline: .primaryWhite
            ]
            return badgeMap[self] ?? .primary
        }

        func border(_ configuration: Configuration, isTextUnderlined: Bool = false) -> AnyShapeStyle {
            if(isTextUnderlined) {
                return AnyShapeStyle(Color.clear)
            }
            let borderMap: [Self: any ShapeStyle] = [
                .darkOutline: Color.huiColors.surface.inversePrimary,
                .whiteGrayOutline: Color.huiColors.lineAndBorders.lineStroke,
                .whiteOutline: Color.huiColors.surface.pageSecondary
            ]
            let borderPressedMap: [Self: any ShapeStyle] = [
                .ghost: Color.huiColors.surface.inversePrimary,
                .white: Color.huiColors.surface.inversePrimary,
                .whiteGrayOutline: Color.huiColors.surface.inversePrimary
            ]
            if let color = borderPressedMap[self], configuration.isPressed {
                return AnyShapeStyle(color)
            }
            return  borderMap[self].map { AnyShapeStyle($0) } ?? AnyShapeStyle(Color.clear)
        }

        func foregroundColor(_ configuration: Configuration) -> Color {
            let foregroundMap: [Self: Color] = [
                .ai: Color.huiColors.text.surfaceColored,
                .black: Color.huiColors.text.surfaceColored,
                .danger: Color.huiColors.text.surfaceColored,
                .dangerInverse: Color.huiColors.text.error,
                .darkOutline: Color.huiColors.text.title,
                .ghost: Color.huiColors.text.title,
                .gray: Color.huiColors.text.title,
                .institution: Color.huiColors.text.surfaceColored,
                .white: Color.huiColors.text.title,
                .whiteGrayOutline: Color.huiColors.text.title,
                .whiteOutline: Color.huiColors.text.surfaceColored
            ]
            let pressedMap: [Self: Color] = [
                .dangerInverse: Color.huiColors.surface.errorPressed,
                .darkOutline: Color.huiColors.text.surfaceColored,
                .whiteOutline: Color.huiColors.text.title
            ]
            if let color = pressedMap[self], configuration.isPressed {
                return color
            }
            return foregroundMap[self] ?? Color.primary
        }

        var hasDarkOverlayWhenPressed: Bool {
            switch self {
            case .ai, .institution:
                return true
            default:
                return false
            }
        }

        var linkTextColor: Color {
            let linkMap: [Self: Color] = [
                .black: Color.huiColors.text.body,
                .gray: Color.huiColors.text.greyPrimary,
                .institution: Color.huiColors.surface.institution,
                .white: Color.huiColors.text.surfaceColored
            ]
            return linkMap[self] ?? Color.huiColors.text.body
        }
    }
}

// MARK: - Static methods for creating buttons

public extension HorizonUI.ButtonStyles {
    static func primary(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: Image? = nil,
        trailing: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        .init(
            type: type,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    static func textLink(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: Image? = nil,
        trailing: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        .init(
            type: type,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing,
            isTextUnderlined: true
        )
    }

    static func icon(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        badgeType: HorizonUI.Badge.BadgeType? = nil,
        icon: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        .init(
            type: type,
            badgeStyle: type.badgeStyle,
            badgeType: badgeType,
            isSmall: isSmall,
            icon: icon ?? (type == .ai ? HorizonUI.icons.ai : HorizonUI.icons.add)
        )
    }
}

// MARK: - Static methods for creating the button styles that are used

public extension ButtonStyle where Self == HorizonUI.ButtonStyles {
    static func primary(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: Image? = nil,
        trailing: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        HorizonUI.ButtonStyles(
            type: type,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    static func textLink(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: Image? = nil,
        trailing: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        HorizonUI.ButtonStyles(
            type: type,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing,
            isTextUnderlined: true
        )
    }

    static func icon(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        badgeType: HorizonUI.Badge.BadgeType? = nil,
        icon: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        HorizonUI.ButtonStyles(
            type: type,
            badgeStyle: type.badgeStyle,
            badgeType: badgeType,
            isSmall: isSmall,
            icon: icon ?? (type == .ai ? HorizonUI.icons.ai : HorizonUI.icons.add)
        )
    }
}

#if DEBUG
#Preview(traits: .sizeThatFitsLayout) {
    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(HorizonUI.ButtonStyles.ButtonType.allCases, id: \.self) { type in
                    HStack {
                        Button("AI Icon Button") {}
                            .buttonStyle(HorizonUI.ButtonStyles.icon(type, badgeType: .number("100")))
                            .disabled(true)
                        Button("Link Button") {}
                            .buttonStyle(HorizonUI.ButtonStyles.textLink(type))
                        Button("\(type) Button") {}
                            .buttonStyle(HorizonUI.ButtonStyles.primary(type))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 88 / 100, green: 88 / 100, blue: 88 / 100))
    }
}
#endif
