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

extension HorizonUI {
    public struct ButtonStyles: ButtonStyle {
        // MARK: - Common Dependencies

        @Environment(\.isEnabled) private var isEnabled
        private let backgroundColor: AnyShapeStyle
        private let foregroundColor: Color
        private let isSmall: Bool

        // MARK: - Primary and Secondary Button Dependencies

        private let fillsWidth: Bool
        private let leading: Image?
        private let trailing: Image?
        private let smallButtonSize = 32.0
        private let largeButtonSize = 44.0
        private let isTextUnderlined: Bool

        // MARK: - Icon Button Dependencies

        private let badgeNumber: String?
        private let badgeStyle: HorizonUI.Badge.Style?
        private let icon: Image?

        fileprivate init(
            backgroundColor: any ShapeStyle,
            foregroundColor: Color,
            isSmall: Bool = false,
            fillsWidth: Bool = false,
            leading: Image? = nil,
            trailing: Image? = nil,
            isTextUnderlined: Bool = false
        ) {
            self.backgroundColor = AnyShapeStyle(backgroundColor)
            self.foregroundColor = foregroundColor
            self.isSmall = isSmall
            self.fillsWidth = fillsWidth
            self.leading = leading
            self.trailing = trailing
            self.isTextUnderlined = isTextUnderlined

            self.badgeNumber = nil
            self.badgeStyle = nil
            self.icon = nil
        }

        fileprivate init(
            backgroundColor: any ShapeStyle,
            foregroundColor: Color,
            badgeStyle: HorizonUI.Badge.Style,
            isSmall: Bool = false,
            icon: Image,
            badgeNumber: String? = nil
        ) {
            self.backgroundColor = AnyShapeStyle(backgroundColor)
            self.badgeNumber = badgeNumber
            self.badgeStyle = badgeStyle
            self.foregroundColor = foregroundColor
            self.icon = icon
            self.isSmall = isSmall

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
                        .renderingMode(.template)
                        .frame(
                            width: isSmall ? smallButtonSize : largeButtonSize,
                            height: isSmall ? smallButtonSize : largeButtonSize
                        )
                        .background(backgroundColor)
                        .foregroundStyle(foregroundColor)
                        .huiCornerRadius(level: .level6)
                        .foregroundColor(foregroundColor)

                    if let badgeNumber = badgeNumber, let badgeStyle = badgeStyle {
                        HorizonUI.Badge(type: .number(badgeNumber), style: badgeStyle)
                            .offset(x: 15, y: -15)
                    }
                }
            }
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
        }

        private func primaryButton(_ configuration: Configuration) -> some View {
            HStack {
                leading?
                    .renderingMode(.template)
                    .foregroundColor(foregroundColor)

                configuration.label

                trailing?
                    .renderingMode(.template)
                    .foregroundColor(foregroundColor)
            }
            .huiTypography(.buttonTextLarge)
            .underline(isTextUnderlined, pattern: .solid)
            .padding(.horizontal, .huiSpaces.space16)
            .frame(height: isSmall ? smallButtonSize : largeButtonSize)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .huiCornerRadius(level: .level6)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
            .animation(.easeInOut, value: isEnabled)
        }

    }
}

extension HorizonUI.ButtonStyles {
    public enum ButtonType: String, CaseIterable, Identifiable {
        case ai = "AI"
        case beige = "Beige"
        case blue = "Blue"
        case black = "Black"
        case white = "White"
        case red = "Red"

        public var id: String { rawValue }

        var background: any ShapeStyle {
            switch self {
            case .ai:
                return LinearGradient(
                    gradient: Gradient(colors: [
                        .huiColors.surface.institution,
                        .huiColors.primitives.green70,
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .beige:
                return Color.huiColors.surface.pagePrimary
            case .blue:
                return Color.huiColors.surface.institution
            case .black:
                return Color.huiColors.surface.inversePrimary
            case .white:
                return Color.huiColors.surface.pageSecondary
            case .red:
                return Color.huiColors.surface.pageSecondary
            }
        }

        var foregroundColor: Color {
            switch self {
            case .ai:
                return Color.huiColors.text.surfaceColored
            case .beige:
                return Color.huiColors.text.title
            case .blue:
                return Color.huiColors.text.surfaceColored
            case .black:
                return Color.huiColors.text.surfaceColored
            case .white:
                return Color.huiColors.text.title
            case .red:
                return Color.huiColors.text.error
            }
        }

        var linkTextColor: Color {
            switch self {
            case .black:
                return Color.huiColors.text.body
            case .white:
                return Color.huiColors.text.surfaceColored
            case .beige:
                return Color.huiColors.text.beigePrimary
            case .blue:
                return Color.huiColors.surface.institution
            default:
                return Color.huiColors.text.body
            }
        }

        var badgeStyle: HorizonUI.Badge.Style {
            switch self {
            case .ai:
                return .primaryWhite
            case .beige:
                return .primary
            case .blue:
                return .primaryWhite
            case .black:
                return .primaryWhite
            case .white:
                return .primary
            case .red:
                return .primary
            }
        }
    }
}

extension HorizonUI.ButtonStyles {
    public static func primary(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: Image? = nil,
        trailing: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        .init(
            backgroundColor: type.background,
            foregroundColor: type.foregroundColor,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    public static func textLink(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: Image? = nil,
        trailing: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        .init(
            backgroundColor: .clear,
            foregroundColor: type.linkTextColor,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing,
            isTextUnderlined: true
        )
    }

    public static func icon(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        badgeNumber: String? = nil,
        icon: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        .init(
            backgroundColor: type.background,
            foregroundColor: type.foregroundColor,
            badgeStyle: type.badgeStyle,
            isSmall: isSmall,
            icon: icon ?? (type == .ai ? HorizonUI.icons.ai : HorizonUI.icons.add),
            badgeNumber: badgeNumber
        )
    }
}

extension ButtonStyle where Self == HorizonUI.ButtonStyles {
    public static func primary(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: Image? = nil,
        trailing: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        HorizonUI.ButtonStyles.init(
            backgroundColor: type.background,
            foregroundColor: type.foregroundColor,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    public static func textLink(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: Image? = nil,
        trailing: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        HorizonUI.ButtonStyles.init(
            backgroundColor: .clear,
            foregroundColor: type.linkTextColor,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing,
            isTextUnderlined: true
        )
    }

    public static func icon(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        badgeNumber: String? = nil,
        icon: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        HorizonUI.ButtonStyles.init(
            backgroundColor: type.background,
            foregroundColor: type.foregroundColor,
            badgeStyle: type.badgeStyle,
            isSmall: isSmall,
            icon: icon ?? (type == .ai ? HorizonUI.icons.ai : HorizonUI.icons.add),
            badgeNumber: badgeNumber
        )
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    NavigationStack {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(HorizonUI.ButtonStyles.ButtonType.allCases, id: \.self) { type in
                    HStack {
                        Button("AI Icon Button") {}
                            .buttonStyle(HorizonUI.ButtonStyles.icon(type, badgeNumber: "99"))
                            .disabled(true)
                        Button("AI Button") {}
                            .buttonStyle(HorizonUI.ButtonStyles.primary(type))
                        Button("Link Button") {}
                            .buttonStyle(HorizonUI.ButtonStyles.textLink(type))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 88 / 100, green: 88 / 100, blue: 88 / 100))
    }
}
