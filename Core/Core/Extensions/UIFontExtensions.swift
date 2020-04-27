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

public extension UIFont {
    enum Name: String, CaseIterable {
        case regular10, regular11Monodigit, regular12, regular14, regular14Italic, regular16, regular20, regular24, regular20Monodigit, regular30
        case medium10, medium12, medium14, medium16, medium20
        case semibold11, semibold12, semibold14, semibold16, semibold16Italic, semibold18, semibold20
        case bold11, bold17, bold20, bold24
        case heavy24
    }

    /// Get a named font style, that is dynamically scaled.
    ///
    /// See https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
    static func scaledNamedFont(_ name: Name) -> UIFont {
        switch name {
        case .regular10:
            return scaledFont(.caption2, for: .systemFont(ofSize: 10, weight: .regular))
        case .regular11Monodigit:
            return scaledFont(.caption1, for: .monospacedDigitSystemFont(ofSize: 11, weight: .regular))
        case .regular12:
            return scaledFont(.caption1, for: .systemFont(ofSize: 12, weight: .regular))
        case .regular14:
            return scaledFont(.body, for: .systemFont(ofSize: 14, weight: .regular))
        case .regular14Italic:
            return scaledFont(.body, for: .systemFont(ofSize: 14, weight: .regular), traits: .traitItalic)
        case .regular16:
            return scaledFont(.body, for: .systemFont(ofSize: 16, weight: .regular))
        case .regular20:
            return scaledFont(.callout, for: .systemFont(ofSize: 20, weight: .regular))
        case .regular20Monodigit:
            return scaledFont(.title3, for: .monospacedDigitSystemFont(ofSize: 20, weight: .regular))
        case .regular24:
            return scaledFont(.body, for: .systemFont(ofSize: 24, weight: .regular))
        case .regular30:
            return scaledFont(.title1, for: .systemFont(ofSize: 30, weight: .regular))

        case .medium10:
            return scaledFont(.title3, for: .systemFont(ofSize: 10, weight: .medium))
        case .medium12:
            return scaledFont(.caption1, for: .systemFont(ofSize: 12, weight: .medium))
        case .medium14:
            return scaledFont(.body, for: .systemFont(ofSize: 14, weight: .medium))
        case .medium16:
            return scaledFont(.title2, for: .systemFont(ofSize: 16, weight: .medium))
        case .medium20:
            return scaledFont(.title1, for: .systemFont(ofSize: 20, weight: .medium))

        case .semibold11:
            return scaledFont(.body, for: .systemFont(ofSize: 11, weight: .semibold))
        case .semibold12:
            return scaledFont(.body, for: .systemFont(ofSize: 12, weight: .semibold))
        case .semibold14:
            return scaledFont(.callout, for: .systemFont(ofSize: 14, weight: .semibold))
        case .semibold16:
            return scaledFont(.callout, for: .systemFont(ofSize: 16, weight: .semibold))
        case .semibold16Italic:
            return scaledFont(.callout, for: .systemFont(ofSize: 16, weight: .semibold), traits: .traitItalic)
        case .semibold18:
            return scaledFont(.title2, for: .systemFont(ofSize: 18, weight: .semibold))
        case .semibold20:
            return scaledFont(.title3, for: .systemFont(ofSize: 20, weight: .semibold))

        case .bold11:
            return scaledFont(.body, for: .systemFont(ofSize: 11, weight: .bold))

        case .bold17:
            return scaledFont(.title2, for: .systemFont(ofSize: 17, weight: .bold))

        case .bold20:
            return UIFontMetrics(forTextStyle: .title3).scaledFont(for: .systemFont(ofSize: 20, weight: .bold))

        case .bold24:
            return scaledFont(.largeTitle, for: .systemFont(ofSize: 24, weight: .bold))

        case .heavy24:
            return scaledFont(.title1, for: .systemFont(ofSize: 24, weight: .heavy))
        }
    }

    private static func scaledFont(_ style: TextStyle, for font: UIFont, traits: UIFontDescriptor.SymbolicTraits? = nil) -> UIFont {
        guard let traits = traits else {
            return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
        }
        let descriptor = font.fontDescriptor
        let font = UIFont(descriptor: descriptor.withSymbolicTraits(descriptor.symbolicTraits.union(traits))!, size: descriptor.pointSize)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
}
