//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public extension Font {
    static var regular10: Font { Font(UIFont.scaledNamedFont(.regular10)) }
    static var regular11Monodigit: Font { Font(UIFont.scaledNamedFont(.regular11Monodigit)) }
    static var regular12: Font { Font(UIFont.scaledNamedFont(.regular12)) }
    static var regular13: Font { Font(UIFont.scaledNamedFont(.regular13)) }
    static var regular14: Font { Font(UIFont.scaledNamedFont(.regular14)) }
    static var regular14Italic: Font { Font(UIFont.scaledNamedFont(.regular14Italic)) }
    static var regular15: Font { Font(UIFont.scaledNamedFont(.regular15)) }
    static var regular16: Font { Font(UIFont.scaledNamedFont(.regular16)) }
    static var regular17: Font { Font(UIFont.scaledNamedFont(.regular17)) }
    static var regular20: Font { Font(UIFont.scaledNamedFont(.regular20)) }
    static var regular22: Font { Font(UIFont.scaledNamedFont(.regular22)) }
    static var regular23: Font { Font(UIFont.scaledNamedFont(.regular23)) }
    static var regular24: Font { Font(UIFont.scaledNamedFont(.regular24)) }
    static var regular20Monodigit: Font { Font(UIFont.scaledNamedFont(.regular20Monodigit)) }
    static var regular30: Font { Font(UIFont.scaledNamedFont(.regular30)) }

    static var medium10: Font { Font(UIFont.scaledNamedFont(.medium10)) }
    static var medium12: Font { Font(UIFont.scaledNamedFont(.medium12)) }
    static var medium14: Font { Font(UIFont.scaledNamedFont(.medium14)) }
    static var medium16: Font { Font(UIFont.scaledNamedFont(.medium16)) }
    static var medium20: Font { Font(UIFont.scaledNamedFont(.medium20)) }

    static var semibold11: Font { Font(UIFont.scaledNamedFont(.semibold11)) }
    static var semibold12: Font { Font(UIFont.scaledNamedFont(.semibold12)) }
    static var semibold13: Font { Font(UIFont.scaledNamedFont(.semibold13)) }
    static var semibold14: Font { Font(UIFont.scaledNamedFont(.semibold14)) }
    static var semibold16: Font { Font(UIFont.scaledNamedFont(.semibold16)) }
    static var semibold17: Font { Font(UIFont.scaledNamedFont(.semibold17)) }
    static var semibold16Italic: Font { Font(UIFont.scaledNamedFont(.semibold16Italic)) }
    static var semibold18: Font { Font(UIFont.scaledNamedFont(.semibold18)) }
    static var semibold20: Font { Font(UIFont.scaledNamedFont(.semibold20)) }
    static var semibold22: Font { Font(UIFont.scaledNamedFont(.semibold22)) }
    static var semibold23: Font { Font(UIFont.scaledNamedFont(.semibold23)) }
    static var semibold28: Font { Font(UIFont.scaledNamedFont(.semibold28)) }
    static var semibold38: Font { Font(UIFont.scaledNamedFont(.semibold38)) }

    static var bold10: Font { Font(UIFont.scaledNamedFont(.bold10)) }
    static var bold11: Font { Font(UIFont.scaledNamedFont(.bold11)) }
    static var bold12: Font { Font(UIFont.scaledNamedFont(.bold12)) }
    static var bold13: Font { Font(UIFont.scaledNamedFont(.bold13)) }
    static var bold14: Font { Font(UIFont.scaledNamedFont(.bold14)) }
    static var bold15: Font { Font(UIFont.scaledNamedFont(.bold15)) }
    static var bold16: Font { Font(UIFont.scaledNamedFont(.bold16)) }
    static var bold17: Font { Font(UIFont.scaledNamedFont(.bold17)) }
    static var bold20: Font { Font(UIFont.scaledNamedFont(.bold20)) }
    static var bold22: Font { Font(UIFont.scaledNamedFont(.bold22)) }
    static var bold24: Font { Font(UIFont.scaledNamedFont(.bold24)) }
    static var bold34: Font { Font(UIFont.scaledNamedFont(.bold34)) }

    static var heavy24: Font { Font(UIFont.scaledNamedFont(.heavy24)) }

    /// Use this where you need for the font to respect restriction on dynamic font size
    /// applied automatically mostly by components like navigation bars.
    static func scaledRestrictly(_ fontName: UIFont.Name) -> Font {
        if fontName.isMonospaced {
            return .system(fontName.style, design: .monospaced)
        } else {
            let name = UIFont
                .applicationFontName(weight: fontName.weight, isItalic: fontName.isItalic)
            return .custom(name, size: fontName.fontSize, relativeTo: fontName.style)
        }
    }
}

extension UIFont.Name {

    var weight: UIFont.Weight {
        switch rawValue.lowercased() {
        case let n where n.hasPrefix("regular"):
            return .regular
        case let n where n.hasPrefix("medium"):
            return .medium
        case let n where n.hasPrefix("semibold"):
            return .semibold
        case let n where n.hasPrefix("bold"):
            return .bold
        case let n where n.hasPrefix("heavy"):
            return .heavy
        default:
            return .regular
        }
    }

    var isItalic: Bool {
        rawValue.lowercased().contains("italic")
    }

    var fontSize: CGFloat {
        let digits = Int(
            rawValue
                .components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined()
        ) ?? 0
        return CGFloat(digits)
    }

    var isMonospaced: Bool {
        rawValue.lowercased().contains("monodigit")
    }

    var style: Font.TextStyle {
        switch self {
        case .regular10, .regular11Monodigit, .regular12, .regular13, .regular14, .regular14Italic,
                .regular15, .regular16, .regular17, .regular22, .regular23, .regular24,
                .medium12, .medium14,
                .semibold11, .semibold12, .semibold13,
                .bold10, .bold11, .bold12, .bold13:
            return .body
        case .regular20, .semibold14, .semibold16, .semibold16Italic, .semibold17:
            return .callout
        case .regular30, .medium20, .heavy24:
            return .title
        case .medium16, .semibold18, .bold14, .bold15, .bold16, .bold17:
            return .title2
        case .regular20Monodigit, .medium10, .semibold20,
                .semibold22, .semibold23, .semibold28, .semibold38, .bold20, .bold22:
            return .title3
        case .bold24, .bold34:
            return .largeTitle
        }
    }
}
