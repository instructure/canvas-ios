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
    struct Badge: View {
        // MARK: - Dependancies
        
        private let type: Badge.BadgeType
        private let style: Badge.Style

        // MARK: - Init

        public init(
            type: Badge.BadgeType,
            style: Badge.Style
        ) {
            self.type = type
            self.style = style
        }

        public var body: some View {
            contentView
                .foregroundStyle(style.foregroundColor)
                .background {
                    Circle()
                        .fill(style.backgroundColor)
                }
        }

        @ViewBuilder
        private var contentView: some View {
            switch type {
            case .number(let number):
                Text(number)
                    .huiTypography(.tag)
                    .frame(minWidth: 19, minHeight: 19)
                    .padding(.huiSpaces.primitives.xxSmall)
            case .icon(let icon):
                icon
                    .resizable()
                    .frame(width: 17, height: 17)
                    .padding(.huiSpaces.primitives.xxxSmall)
            case .solidColor:
                Circle()
                    .fill(.clear)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

#Preview {
    HorizonUI
        .Badge(
            type: .icon(.huiIcons.check),
            style: .success
        )
}

extension HorizonUI.Badge {
    public enum BadgeType {
        case number(String)
        case icon(Image)
        case solidColor
    }

    public enum Style {
        case primary
        case success
        case danger
        case primaryWhite
        case custom(backgroundColor: Color, foregroundColor: Color = .clear)

        var backgroundColor: Color {
            switch self {
            case .primary:
                return .huiColors.surface.institution
            case .custom(let backgroundColor, _):
                return backgroundColor
            case .success: return .huiColors.surface.success
            case .danger: return .huiColors.surface.error
            case .primaryWhite: return .huiColors.surface.pageSecondary
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .success, .danger:
                return .huiColors.text.surfaceColored
            case .primaryWhite:
                return .huiColors.text.body
            case .custom(_, let foregroundColor):
                return foregroundColor
            }
        }
    }
}
