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

            var font: Font {
                switch self {
                case .h1: return .huiFonts.manropeBold28
                case .h2: return .huiFonts.manropeBold24
                case .h3: return .huiFonts.manropeBold20
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

#Preview {
    VStack(spacing: 8) {
        HorizonUI.Typography(
            text: "First text",
            name: .h1,
            color: .huiColors.primitives.blue57
        )
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
