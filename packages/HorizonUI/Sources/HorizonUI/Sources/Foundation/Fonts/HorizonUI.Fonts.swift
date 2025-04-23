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
        // MARK: Private
        
        fileprivate init() {}

        private struct VariantAndSize : Sendable{
            let variant: Variants
            let size: Double

            func scaledFont() -> Font {
                let scaledSize = UIFontMetrics.default.scaledValue(for: size)
                return Font.custom(variant.rawValue, size: scaledSize)
            }

            func uiFont() -> UIFont {
                let font = UIFont(name: variant.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
                return UIFontMetrics.default.scaledFont(for: font)
            }
        }

        private static let manropeR12: VariantAndSize = .init(variant: .manropeRegular, size: 12)

        private static let manropeB28: VariantAndSize = .init(variant: .manropeBold, size: 28)
        private static let manropeB24: VariantAndSize = .init(variant: .manropeBold, size: 24)
        private static let manropeB20: VariantAndSize = .init(variant: .manropeBold, size: 20)

        private static let manropeSB16: VariantAndSize = .init(variant: .manropeSemiBold, size: 16)
        
        private static let figtreeR16: VariantAndSize = .init(variant: .figtreeRegular, size: 16)
        private static let figtreeR14: VariantAndSize = .init(variant: .figtreeRegular, size: 14)
        private static let figtreeR12: VariantAndSize = .init(variant: .figtreeRegular, size: 12)

        private static let figtreeSB16: VariantAndSize = .init(variant: .figtreeSemiBold, size: 16)
        private static let figtreeSB14: VariantAndSize = .init(variant: .figtreeSemiBold, size: 14)
        private static let figtreeSB12: VariantAndSize = .init(variant: .figtreeSemiBold, size: 12)

        // MARK: Public

        enum Variants: String, CaseIterable, Sendable {
            case figtreeRegular = "Figtree-Regular"
            case figtreeSemiBold = "Figtree-SemiBold"
            case manropeRegular = "Manrope-Regular"
            case manropeBold = "Manrope-Bold"
            case manropeSemiBold = "Manrope-SemiBold"
        }

        let manropeRegular12: Font = HorizonUI.Fonts.manropeR12.scaledFont()

        let manropeBold28: Font = HorizonUI.Fonts.manropeB28.scaledFont()
        let manropeBold24: Font = HorizonUI.Fonts.manropeB24.scaledFont()
        let manropeBold20: Font = HorizonUI.Fonts.manropeB20.scaledFont()

        let manropeSemiBold16: Font = HorizonUI.Fonts.manropeSB16.scaledFont()
        
        let figtreeRegular16: Font = HorizonUI.Fonts.figtreeR16.scaledFont()
        let figtreeRegular14: Font = HorizonUI.Fonts.figtreeR14.scaledFont()
        let figtreeRegular12: Font = HorizonUI.Fonts.figtreeR12.scaledFont()

        let figtreeSemibold16: Font = HorizonUI.Fonts.figtreeSB16.scaledFont()
        let figtreeSemibold14: Font = HorizonUI.Fonts.figtreeSB14.scaledFont()
        let figtreeSemibold12: Font = HorizonUI.Fonts.figtreeSB12.scaledFont()

        public func uiFont(font: Font) -> UIFont {
            switch font {
            case manropeRegular12: return HorizonUI.Fonts.manropeR12.uiFont()
            case manropeBold28: return HorizonUI.Fonts.manropeB28.uiFont()
            case manropeBold24: return HorizonUI.Fonts.manropeB24.uiFont()
            case manropeBold20: return HorizonUI.Fonts.manropeB20.uiFont()
            case manropeSemiBold16: return HorizonUI.Fonts.manropeSB16.uiFont()
            case figtreeRegular16: return HorizonUI.Fonts.figtreeR16.uiFont()
            case figtreeRegular14: return HorizonUI.Fonts.figtreeR14.uiFont()
            case figtreeRegular12: return HorizonUI.Fonts.figtreeR12.uiFont()
            case figtreeSemibold16: return HorizonUI.Fonts.figtreeSB16.uiFont()
            case figtreeSemibold14: return HorizonUI.Fonts.figtreeSB14.uiFont()
            default: return HorizonUI.Fonts.figtreeSB12.uiFont()
            }
        }
    }

    static let fonts = HorizonUI.Fonts()
}
extension Font {
    static let huiFonts = HorizonUI.fonts
}
