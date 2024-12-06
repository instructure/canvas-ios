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
    struct Fonts: Sendable {
        fileprivate init() {}

        enum Variants: String, CaseIterable {
            case figreeRegular = "Figree-Regular"
            case figreeSemiBold = "Figtree-SemiBold"
            case manropeRegular = "Manrope-Regular"
            case manropeBold = "Manrope-Bold"
        }

        let manropeRegular12: Font = .scaledFont(name: .manropeRegular, size: 12)

        let manropeBold28: Font = .scaledFont(name: .manropeBold, size: 28)
        let manropeBold24: Font = .scaledFont(name: .manropeBold, size: 24)
        let manropeBold20: Font = .scaledFont(name: .manropeBold, size: 20)

        let figtreeRegular16: Font = .scaledFont(name: .figreeRegular, size: 16)
        let figtreeRegular14: Font = .scaledFont(name: .figreeRegular, size: 14)
        let figtreeRegular12: Font = .scaledFont(name: .figreeRegular, size: 12)

        let figtreeSemibold16: Font = .scaledFont(name: .figreeSemiBold, size: 16)
        let figtreeSemibolt14: Font = .scaledFont(name: .figreeSemiBold, size: 14)
        let figtreeSemibold12: Font = .scaledFont(name: .figreeSemiBold, size: 12)
    }

    static let fonts = HorizonUI.Fonts()
}

extension Font {
    static let huiFonts = HorizonUI.fonts

    fileprivate static func scaledFont(name: HorizonUI.Fonts.Variants, size: Double) -> Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return Font.custom(name.rawValue, size: scaledSize)
    }
}
