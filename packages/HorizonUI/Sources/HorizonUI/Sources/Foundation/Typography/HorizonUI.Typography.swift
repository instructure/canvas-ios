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
    struct Typography: View {
        enum Name: CaseIterable {
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
        }

        private let text: String
        private let name: Typography.Name
        private let color: Color

        init(
            text: String,
            name: Typography.Name,
            color: Color = HorizonUI.colors.primitives.blue57
        ) {
            self.text = text
            self.name = name
            self.color = color
        }

        public var body: some View {
            Text(text)
                .font(name.font)
                .foregroundStyle(color)
        }
    }
}

extension View {
    func h1() -> some View {
        self
            .font(.huiFonts.manropeBold28)
            .lineSpacing(39.2)
            .tracking(0)
    }
    func h2() -> some View {
        self
            .font(.huiFonts.manropeBold24)
            .lineSpacing(33.6)
            .tracking(0)
    }
    func h3() -> some View {
        self
            .font(.huiFonts.manropeBold20)
            .lineSpacing(28)
            .tracking(0)
    }
    func p1() -> some View {
        self
            .font(.huiFonts.figtreeRegular16)
            .lineSpacing(22.4)
            .tracking(0)
    }
    func p2() -> some View {
        self
            .font(.huiFonts.figtreeRegular14)
            .lineSpacing(19.6)
            .tracking(0)
    }
    func p3() -> some View {
        self
            .font(.huiFonts.figtreeRegular12)
            .lineSpacing(16.8)
            .tracking(0)
    }
    func tag() -> some View {
        self
            .font(.huiFonts.manropeRegular12)
            .tracking(0.5)
            .textCase(.uppercase)
    }
    func labelLargeBold() -> some View {
        self
            .font(.huiFonts.figtreeSemibold16)
            .lineSpacing(22.4)
            .tracking(0)
    }
    func labelMediumBold() -> some View {
        self
            .font(.huiFonts.figtreeSemibolt14)
            .lineSpacing(19.6)
            .tracking(0)
    }
    func labelSmallBold() -> some View {
        self
            .font(.huiFonts.figtreeSemibold12)
            .lineSpacing(16.8)
            .tracking(0.25)
    }
    func labelSmall() -> some View {
        self
            .font(.huiFonts.figtreeRegular12)
            .lineSpacing(16.8)
            .tracking(0.25)
    }
    func buttonTextLarge() -> some View {
        self
            .font(.huiFonts.figtreeRegular16)
            .lineSpacing(22.4)
            .tracking(0)
    }
    func buttonTextMedium() -> some View {
        self
            .font(.huiFonts.figtreeRegular14)
            .lineSpacing(19.6)
            .tracking(0)
    }
}

#Preview {
    VStack(spacing: 8) {
        HorizonUI.Typography(
            text: "First text",
            name: .h1,
            color: .huiColors.primitives.blue57
        )
        Text("Second H1")
            .foregroundStyle(Color.huiColors.primitives.blue57)
            .h1()
        HorizonUI.Typography(
            text: "First text",
            name: .h2,
            color: .huiColors.primitives.blue57
        )
        HorizonUI.Typography(
            text: "First text",
            name: .h3,
            color: .huiColors.primitives.blue57
        )
    }
}
