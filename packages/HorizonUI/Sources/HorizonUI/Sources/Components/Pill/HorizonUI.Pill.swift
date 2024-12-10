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
            case `default`
            case danger

            var color: Color {
                switch self {
                case .default:
                    // TODO: replace with UI Colors/Text/Body
                    return .black
                case .danger:
                    // TODO: replace with UI Colors/Surface/Error
                    return .red
                }
            }
        }

        private let title: String
        private let style: Pill.Style
        private let isBordered: Bool
        private let isUppercased: Bool
        private let icon: Pill.PlaceholderIcon?
        private let cornerRadius: CornerRadius = .level4
        
        public init(
            title: String,
            style: Pill.Style,
            isBordered: Bool,
            isUppercased: Bool,
            icon: Pill.PlaceholderIcon?
        ) {
            self.title = title
            self.style = style
            self.isBordered = isBordered
            self.isUppercased = isUppercased
            self.icon = icon
        }

        public var body: some View {
            HStack(spacing: .huiSpaces.primitives.xxSmall) {
                if let icon {
                    icon
                        .frame(width: 18, height: 18)
                        .foregroundStyle(style.color)
                }
                HorizonUI.Typography(
                    text: isUppercased ? title.uppercased() : title.capitalized,
                    name: isUppercased ? .tag : .labelSmall,
                    color: style.color
                )
            }
            .padding(.horizontal, .huiSpaces.primitives.small)
            .padding(.vertical, .huiSpaces.primitives.xSmall)
            .huiCornerRadius(level: cornerRadius)
            .huiBorder(
                level: isBordered ? .level1 : nil,
                color: style.color,
                radius: cornerRadius.attributes.radius
            )
        }
    }
}

#Preview {
    VStack {
        HorizonUI.Pill(
            title: "Some text",
            style: .default,
            isBordered: true,
            isUppercased: true,
            icon: HorizonUI.Pill.PlaceholderIcon(name: "calendar")
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
