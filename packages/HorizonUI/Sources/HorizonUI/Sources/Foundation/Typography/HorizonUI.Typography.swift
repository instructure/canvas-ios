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
    struct Typography: ViewModifier {
        public enum Name: CaseIterable {
            case h1
            case h2
            case h3
            case p1
            case p2
            case p3
            case tag
            case labelLargeBold
            case labelMediumBold
            case labelSmallBold
            case labelSmall
            case buttonTextLarge
            case buttonTextMedium

            var font: Font {
                switch self {
                case .h1: return .huiFonts.manropeBold28
                case .h2: return .huiFonts.manropeBold24
                case .h3: return .huiFonts.manropeBold20
                case .p1: return .huiFonts.figtreeRegular16
                case .p2: return .huiFonts.figtreeRegular14
                case .p3: return .huiFonts.figtreeRegular12
                case .tag: return .huiFonts.manropeRegular12
                case .labelLargeBold: return .huiFonts.figtreeSemibold16
                case .labelMediumBold: return .huiFonts.figtreeSemibolt14
                case .labelSmallBold: return .huiFonts.figtreeSemibold12
                case .labelSmall: return .huiFonts.figtreeRegular12
                case .buttonTextLarge: return .huiFonts.figtreeRegular16
                case .buttonTextMedium: return .huiFonts.figtreeRegular14
                }
            }

            var letterSpacing: CGFloat {
                switch self {
                case .h1: return 0
                case .h2: return 0
                case .h3: return 0
                case .p1: return 0
                case .p2: return 0
                case .p3: return 0
                case .tag: return 0.5
                case .labelLargeBold: return 0
                case .labelMediumBold: return 0
                case .labelSmallBold: return 0.25
                case .labelSmall: return 0.25
                case .buttonTextLarge: return 0
                case .buttonTextMedium: return 0
                }
            }

            var lineSpacing: CGFloat {
                switch self {
                case .h1: return 39.2
                case .h2: return 33.6
                case .h3: return 28
                case .p1: return 22.4
                case .p2: return 19.6
                case .p3: return 16.8
                // TODO: Need to check with the team
                case .tag: return 16.8
                case .labelLargeBold: return 22.4
                case .labelMediumBold: return 19.6
                case .labelSmallBold: return 16.8
                case .labelSmall: return 16.8
                case .buttonTextLarge: return 22.4
                case .buttonTextMedium: return 19.6
                }
            }
        }

        private let name: Name

        init(_ name: Name) {
            self.name = name
        }

        public func body(content: Content) -> some View{
            content
                .font(name.font)
                .lineSpacing(name.lineSpacing)
                .tracking(name.letterSpacing)
        }
    }
}

public extension View {
    func huiTypography(_ name: HorizonUI.Typography.Name) -> some View {
        modifier(HorizonUI.Typography(name))
    }
}

#Preview {
    VStack(spacing: 8) {
        Text("First text H1")
            .foregroundStyle(Color.huiColors.primitives.blue57)
            .huiTypography(.h1)
        Text("Second text H2")
            .foregroundStyle(Color.huiColors.primitives.blue57)
            .huiTypography(.h2)
    }
}
