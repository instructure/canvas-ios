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
        private let background: AnyShapeStyle
        private let foreground: Color
        private let isSmall: Bool

        // MARK: - Primary and Secondary Button Dependencies

        private let fillsWidth: Bool
        private let leading: Image?
        private let trailing: Image?

        // MARK: - Icon Button Dependencies

        private let badge: String?
        private let badgeStyle: HorizonUI.Badge.Style?
        private let icon: Image?

        fileprivate init(
            background: any ShapeStyle,
            foreground: Color,
            isSmall: Bool = false,
            fillsWidth: Bool = false,
            leading: Image? = nil,
            trailing: Image? = nil
        ) {
            self.background = AnyShapeStyle(background)
            self.foreground = foreground
            self.isSmall = isSmall
            self.fillsWidth = fillsWidth
            self.leading = leading
            self.trailing = trailing

            self.badge = nil
            self.badgeStyle = nil
            self.icon = nil
        }

        fileprivate init(
            background: any ShapeStyle,
            foreground: Color,
            badgeStyle: HorizonUI.Badge.Style,
            isSmall: Bool = false,
            icon: Image,
            badge: String? = nil
        ) {
            self.background = AnyShapeStyle(background)
            self.badge = badge
            self.badgeStyle = badgeStyle
            self.foreground = foreground
            self.icon = icon
            self.isSmall = isSmall

            self.fillsWidth = false
            self.leading = nil
            self.trailing = nil
        }

        public func makeBody(configuration: Configuration) -> some View {
            if icon != nil {
                return AnyView(makeIconOnlyButtonType(configuration: configuration))
            }
            return AnyView(makePrimaryButtonType(configuration: configuration))
        }

        private func makePrimaryButtonType(configuration: Configuration) -> any View {
            HStack {
                leading?
                    .renderingMode(.template)
                    .foregroundColor(foreground)

                configuration.label

                trailing?
                    .renderingMode(.template)
                    .foregroundColor(foreground)
            }
            .huiTypography(.buttonTextLarge)
            .padding(.horizontal, .huiSpaces.primitives.mediumSmall)
            .frame(height: isSmall ? 40 : 44)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .background(background)
            .foregroundStyle(foreground)
            .cornerRadius(isSmall ? 20 : 22)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
        }

        private func makeIconOnlyButtonType(configuration: Configuration) -> any View {
            guard let icon = icon else {
                return EmptyView()
            }
            return ZStack {
                icon
                    .renderingMode(.template)
                    .frame(width: isSmall ? 40 : 44, height: isSmall ? 40 : 44)
                    .background(background)
                    .foregroundStyle(foreground)
                    .cornerRadius(isSmall ? 20 : 22)
                    .foregroundColor(foreground)
                    .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)

                if let badge = badge,
                   let badgeStyle = badgeStyle
                {
                    HorizonUI.Badge(type: .number(badge), style: badgeStyle)
                        .offset(x: 15, y: -15)
                }
            }
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
                        Color(hexString: "#09508C"),
                        Color(hexString: "#02672D"),
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
                return Color.huiColors.text.warning
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
            background: type.background,
            foreground: type.foregroundColor,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    public static func iconOnly(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        badge: String? = nil,
        icon: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        .init(
            background: type.background,
            foreground: type.foregroundColor,
            badgeStyle: type.badgeStyle,
            isSmall: isSmall,
            icon: icon ?? (type == .ai ? HorizonUI.icons.ai : HorizonUI.icons.add),
            badge: badge
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
            background: type.background,
            foreground: type.foregroundColor,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    public static func iconOnly(
        _ type: HorizonUI.ButtonStyles.ButtonType,
        isSmall: Bool = false,
        badge: String? = nil,
        icon: Image? = nil
    ) -> HorizonUI.ButtonStyles {
        HorizonUI.ButtonStyles.init(
            background: type.background,
            foreground: type.foregroundColor,
            badgeStyle: type.badgeStyle,
            isSmall: isSmall,
            icon: icon ?? (type == .ai ? HorizonUI.icons.ai : HorizonUI.icons.add),
            badge: badge
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
                            .buttonStyle(HorizonUI.ButtonStyles.iconOnly(type, badge: "99"))
                            .disabled(true)
                        Button("AI Button") {}
                            .buttonStyle(HorizonUI.ButtonStyles.primary(type))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 88 / 100, green: 88 / 100, blue: 88 / 100))
    }
}
