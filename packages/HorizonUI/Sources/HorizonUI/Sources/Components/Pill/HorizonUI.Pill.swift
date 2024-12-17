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
                case .outline(let outline):
                    return outline.backgroundColor
                case .solid(let solid):
                    return solid.backgroundColor
                case .inline(let inline):
                    return inline.backgroundColor
                }
            }
            
            var borderColor: Color {
                switch self {
                case .outline(let outline):
                    return outline.borderColor
                case .solid(let solid):
                    return solid.borderColor
                case .inline(let inline):
                    return inline.borderColor
                }
            }
            
            var textColor: Color {
                switch self {
                case .outline(let outline):
                    return outline.textColor
                case .solid(let solid):
                    return solid.textColor
                case .inline(let inline):
                    return inline.textColor
                }
            }
        }

        private let title: String
        private let style: Pill.Style
        private let isSmall: Bool
        private let isUppercased: Bool
        private let icon: Image?
        private let cornerRadius: CornerRadius = .level4
        private let drawBorder: Bool
        
        public init(
            title: String,
            style: Pill.Style = .outline(Style.Outline.default),
            isSmall: Bool = false,
            isUppercased: Bool,
            icon: Image?
        ) {
            self.title = title
            self.style = style
            self.isSmall = isSmall
            self.isUppercased = isUppercased
            self.icon = icon
            
            if case .outline = style {
                drawBorder = true
            } else {
                drawBorder = false
            }
        }

        public var body: some View {
            HStack(spacing: .huiSpaces.primitives.xxSmall) {
                if let icon {
                    icon
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(style.textColor)
                }
                Text(isUppercased ? title.uppercased() : title.capitalized)
                    .huiTypography(isUppercased ? .tag : .labelSmall)
                    .foregroundStyle(style.textColor)
            }
            .padding(.horizontal, isSmall ? .huiSpaces.primitives.xSmall : .huiSpaces.primitives.small)
            .padding(.vertical, isSmall ? .huiSpaces.primitives.xxSmall : .huiSpaces.primitives.xSmall)
            .background(style.backgroundColor)
            .huiCornerRadius(level: cornerRadius)
            .huiBorder(
                level: drawBorder ? .level1 : nil,
                color: style.borderColor,
                radius: cornerRadius.attributes.radius
            )
            .frame(minHeight: isSmall ? 25 : 33)
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
