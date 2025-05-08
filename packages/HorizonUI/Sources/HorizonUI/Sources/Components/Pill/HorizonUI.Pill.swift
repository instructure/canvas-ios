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
    struct Pill: View {
        public enum Style {
            case outline(Style.Outline)
            case solid(Style.Solid)
            case inline(Style.Inline)

            var backgroundColor: Color {
                switch self {
                case let .outline(outline):
                    return outline.backgroundColor
                case let .solid(solid):
                    return solid.backgroundColor
                case let .inline(inline):
                    return inline.backgroundColor
                }
            }

            var borderColor: Color {
                switch self {
                case let .outline(outline):
                    return outline.borderColor
                case let .solid(solid):
                    return solid.borderColor
                case let .inline(inline):
                    return inline.borderColor
                }
            }

            var textColor: Color {
                switch self {
                case let .outline(outline):
                    return outline.textColor
                case let .solid(solid):
                    return solid.textColor
                case let .inline(inline):
                    return inline.textColor
                }
            }

            var iconColor: Color {
                switch self {
                case let .outline(outline):
                    return outline.iconColor
                case let .solid(solid):
                    return solid.iconColor
                case let .inline(inline):
                    return inline.iconColor
                }
            }

            var drawBorder: Bool {
                switch self {
                case .outline: return true
                default: return false
                }
            }
        }

        private let title: String
        private let style: Pill.Style
        private let isSmall: Bool
        private let isUppercased: Bool
        private let icon: Image?
        private let cornerRadius: CornerRadius = .level4
        private let horizontalPadding: CGFloat
        private let verticalPadding: CGFloat
        private let minHeight: CGFloat

        public init(
            title: String,
            style: Pill.Style = .outline(Style.Outline.default),
            isSmall: Bool = false,
            isUppercased: Bool = false,
            icon: Image? = nil
        ) {
            self.title = title
            self.style = style
            self.isSmall = isSmall
            self.isUppercased = isUppercased
            self.icon = icon

            if case .inline = style {
                horizontalPadding = 0
                verticalPadding = 0
                minHeight = 17
            } else {
                self.horizontalPadding = isSmall ? .huiSpaces.space8 : .huiSpaces.space12
                self.verticalPadding = isSmall ? .huiSpaces.space4 : .huiSpaces.space8
                self.minHeight = isSmall ? 25 : 33
            }
        }

        public var body: some View {
            HStack(spacing: .huiSpaces.space4) {
                if let icon {
                    icon
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(style.iconColor)
                }
                Text(isUppercased ? title.uppercased() : title.capitalized)
                    .huiTypography(isUppercased ? .tag : .labelSmall)
                    .foregroundStyle(style.textColor)
            }

            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(style.backgroundColor)
            .huiCornerRadius(level: cornerRadius)
            .huiBorder(
                level: style.drawBorder ? .level1 : nil,
                color: style.borderColor,
                radius: cornerRadius.attributes.radius
            )
            .frame(minHeight: minHeight)
        }
    }
}

#Preview {
    VStack {
        HorizonUI.Pill(
            title: "Some text",
            style: .outline(HorizonUI.Pill.Style.Outline.default),
            isUppercased: true,
            icon: .huiIcons.calendarToday
        )
        Spacer()
    }
    .padding(16)
}

public extension HorizonUI.Pill {
    struct PlaceholderIcon: View {
        let name: String

        public var body: some View {
            Image(systemName: name)
        }
    }
}
