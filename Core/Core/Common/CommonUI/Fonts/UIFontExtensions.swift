//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import UIKit
import SwiftUI

public extension UIFont {
    enum Name: String, CaseIterable {
        case regular10, regular11Monodigit, regular12, regular13, regular14, regular14Italic, regular15, regular16, regular17, regular20, regular22, regular23, regular24, regular20Monodigit, regular30
        case medium10, medium12, medium14, medium16, medium20
        case semibold11, semibold12, semibold13, semibold14, semibold16, semibold17, semibold16Italic, semibold18, semibold20, semibold22, semibold23, semibold28, semibold38
        case bold10, bold11, bold12, bold13, bold14, bold15, bold16, bold17, bold20, bold22, bold24, bold34
        case heavy24
    }

    /// Get a named font style, that is dynamically scaled.
    ///
    /// See https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
    static func scaledNamedFont(_ name: Name) -> UIFont {
        switch name {
        case .regular10:
            return scaledFont(.caption2, for: applicationFont(ofSize: 10, weight: .regular))
        case .regular11Monodigit:
            return scaledFont(.caption1, for: .monospacedApplicationFont(ofSize: 11, weight: .regular))
        case .regular12:
            return scaledFont(.caption1, for: applicationFont(ofSize: 12, weight: .regular))
        case .regular13:
            return scaledFont(.caption1, for: applicationFont(ofSize: 13, weight: .regular))
        case .regular14:
            return scaledFont(.body, for: applicationFont(ofSize: 14, weight: .regular))
        case .regular14Italic:
            return scaledFont(.body, for: applicationFont(ofSize: 14, weight: .regular, isItalic: true), traits: .traitItalic)
        case .regular15:
            return scaledFont(.body, for: applicationFont(ofSize: 15, weight: .regular))
        case .regular16:
            return scaledFont(.body, for: applicationFont(ofSize: 16, weight: .regular))
        case .regular17:
            return scaledFont(.body, for: applicationFont(ofSize: 17, weight: .regular))
        case .regular20:
            return scaledFont(.callout, for: applicationFont(ofSize: 20, weight: .regular))
        case .regular20Monodigit:
            return scaledFont(.title3, for: .monospacedApplicationFont(ofSize: 20, weight: .regular))
        case .regular22:
            return scaledFont(.body, for: applicationFont(ofSize: 22, weight: .regular))
        case .regular23:
            return scaledFont(.body, for: applicationFont(ofSize: 23, weight: .regular))
        case .regular24:
            return scaledFont(.body, for: applicationFont(ofSize: 24, weight: .regular))
        case .regular30:
            return scaledFont(.title1, for: applicationFont(ofSize: 30, weight: .regular))

        case .medium10:
            return scaledFont(.title3, for: applicationFont(ofSize: 10, weight: .medium))
        case .medium12:
            return scaledFont(.caption1, for: applicationFont(ofSize: 12, weight: .medium))
        case .medium14:
            return scaledFont(.body, for: applicationFont(ofSize: 14, weight: .medium))
        case .medium16:
            return scaledFont(.title2, for: applicationFont(ofSize: 16, weight: .medium))
        case .medium20:
            return scaledFont(.title1, for: applicationFont(ofSize: 20, weight: .medium))

        case .semibold11:
            return scaledFont(.body, for: applicationFont(ofSize: 11, weight: .semibold))
        case .semibold12:
            return scaledFont(.body, for: applicationFont(ofSize: 12, weight: .semibold))
        case .semibold13:
            return scaledFont(.body, for: applicationFont(ofSize: 13, weight: .semibold))
        case .semibold14:
            return scaledFont(.callout, for: applicationFont(ofSize: 14, weight: .semibold))
        case .semibold16:
            return scaledFont(.callout, for: applicationFont(ofSize: 16, weight: .semibold))
        case .semibold16Italic:
            return scaledFont(.callout, for: applicationFont(ofSize: 16, weight: .semibold, isItalic: true), traits: .traitItalic)
        case .semibold17:
            return scaledFont(.callout, for: applicationFont(ofSize: 17, weight: .semibold))
        case .semibold18:
            return scaledFont(.title2, for: applicationFont(ofSize: 18, weight: .semibold))
        case .semibold20:
            return scaledFont(.title3, for: applicationFont(ofSize: 20, weight: .semibold))
        case .semibold22:
            return scaledFont(.title3, for: applicationFont(ofSize: 22, weight: .semibold))
        case .semibold23:
            return scaledFont(.title3, for: applicationFont(ofSize: 23, weight: .semibold))
        case .semibold28:
            return scaledFont(.title3, for: applicationFont(ofSize: 28, weight: .semibold))
        case .semibold38:
            return scaledFont(.title3, for: applicationFont(ofSize: 38, weight: .semibold))

        case .bold10:
            return scaledFont(.body, for: applicationFont(ofSize: 10, weight: .bold))
        case .bold11:
            return scaledFont(.body, for: applicationFont(ofSize: 11, weight: .bold))
        case .bold12:
            return scaledFont(.body, for: applicationFont(ofSize: 12, weight: .bold))
        case .bold13:
            return scaledFont(.body, for: applicationFont(ofSize: 13, weight: .bold))
        case .bold14:
            return scaledFont(.title2, for: applicationFont(ofSize: 14, weight: .bold))
        case .bold15:
            return scaledFont(.title2, for: applicationFont(ofSize: 15, weight: .bold))
        case .bold16:
            return scaledFont(.title2, for: applicationFont(ofSize: 16, weight: .bold))
        case .bold17:
            return scaledFont(.title2, for: applicationFont(ofSize: 17, weight: .bold))
        case .bold20:
            return UIFontMetrics(forTextStyle: .title3).scaledFont(for: applicationFont(ofSize: 20, weight: .bold))
        case .bold22:
            return UIFontMetrics(forTextStyle: .title3).scaledFont(for: applicationFont(ofSize: 22, weight: .bold))
        case .bold24:
            return scaledFont(.largeTitle, for: applicationFont(ofSize: 24, weight: .bold))
        case .bold34:
            return scaledFont(.largeTitle, for: applicationFont(ofSize: 34, weight: .bold))

        case .heavy24:
            return scaledFont(.title1, for: applicationFont(ofSize: 24, weight: .heavy))
        }
    }

    static func monospacedApplicationFont(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        if AppEnvironment.shared.k5.isK5Enabled {
            return applicationFont(ofSize: fontSize, weight: weight)
        } else {
            return .monospacedDigitSystemFont(ofSize: fontSize, weight: weight)
        }
    }

    static func applicationFont(ofSize fontSize: CGFloat, weight: UIFont.Weight, isItalic: Bool = false) -> UIFont {
        let fontName: String = {
            let isK5Font = AppEnvironment.shared.k5.isK5Enabled
            let font = isK5Font ? "BalsamiqSans" : "Lato"
            var suffix = ""

            if isK5Font {
                switch weight {
                case .black, .heavy:
                    suffix = "Bold"
                default:
                    suffix = "Regular"
                }
            } else {
                switch weight {
                case .black, .heavy:
                    suffix = "Black"
                case .bold, .medium:
                    suffix = isItalic ? "BoldItalic" : "Bold"
                case .semibold:
                    suffix = isItalic ? "SemiBoldItalic" : "SemiBold"
                case .regular, .light, .thin, .ultraLight:
                    suffix = isItalic ? "Italic" : "Regular"
                default:
                    suffix = "Regular"
                }
            }

            return "\(font)-\(suffix)"
        }()

        return UIFont(name: fontName, size: fontSize)!
    }

    private static func scaledFont(_ style: TextStyle, for font: UIFont, traits: UIFontDescriptor.SymbolicTraits? = nil) -> UIFont {
        guard let traits = traits else {
            return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
        }
        let descriptor = font.fontDescriptor

        // If `font` doesn't support the requested traits the `withSymbolicTraits` method returns nil.
        guard let descriptorWithSymbolicTraits = descriptor.withSymbolicTraits(descriptor.symbolicTraits.union(traits)) else {
            return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
        }

        let font = UIFont(descriptor: descriptorWithSymbolicTraits, size: descriptor.pointSize)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
}
