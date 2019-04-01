//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

public extension UIFont {
    public enum Name: String, CaseIterable {
        case body, bodyMedium, bodySmall, bodySmallItalic, button, buttonSmall, caption, cardTitle, cardSubtitle, dotSeparator, heading, label
        case rowTitle, rowSubtitle, title, title2, title3, tabBarIconTitle

        case regular11Monodigit, regular14, regular20, regular20Monodigit, regular30
        case medium12
        case semibold14, semibold16, semibold20
        case bold24
    }

    /// Get a named font style, that is dynamically scaled.
    ///
    /// See https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
    public static func scaledNamedFont(_ name: Name) -> UIFont {
        switch name {
        case .body:
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16, weight: .regular))
        case .bodyMedium:
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 14, weight: .medium))
        case .bodySmallItalic:
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: .italicSystemFont(ofSize: 14))
        case .caption:
            return UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 12, weight: .semibold))
        case .cardTitle:
            return UIFontMetrics(forTextStyle: .callout).scaledFont(for: .systemFont(ofSize: 16, weight: .semibold))
        case .dotSeparator:
            return UIFontMetrics(forTextStyle: .caption2).scaledFont(for: .systemFont(ofSize: 10, weight: .regular))
        case .heading:
            return UIFontMetrics(forTextStyle: .title1).scaledFont(for: .systemFont(ofSize: 24, weight: .heavy))
        case .label:
            return UIFontMetrics(forTextStyle: .callout).scaledFont(for: .systemFont(ofSize: 16, weight: .medium))
        case .rowSubtitle:
            return UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 12, weight: .regular))
        case .title2:
            return UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 17, weight: .bold))
        case .title3:
            return UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 16, weight: .medium))
        case .buttonSmall:
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 14, weight: .semibold))
        case .tabBarIconTitle:
            return UIFontMetrics(forTextStyle: .title3).scaledFont(for: .systemFont(ofSize: 10, weight: .medium))

        case .regular14, .bodySmall:
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 14, weight: .regular))
        case .regular20, .rowTitle:
            return UIFontMetrics(forTextStyle: .callout).scaledFont(for: .systemFont(ofSize: 16, weight: .semibold))
        case .regular30:
            return UIFontMetrics(forTextStyle: .title1).scaledFont(for: .systemFont(ofSize: 30, weight: .regular))

        case .medium12:
            return UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 12, weight: .medium))

        case .semibold14, .cardSubtitle:
            return UIFontMetrics(forTextStyle: .callout).scaledFont(for: .systemFont(ofSize: 14, weight: .semibold))
        case .semibold16, .button:
            return UIFontMetrics(forTextStyle: .callout).scaledFont(for: .systemFont(ofSize: 16, weight: .semibold))
        case .semibold20, .title:
            return UIFontMetrics(forTextStyle: .title3).scaledFont(for: .systemFont(ofSize: 20, weight: .semibold))

        case .bold24:
            return UIFontMetrics(forTextStyle: .headline).scaledFont(for: .systemFont(ofSize: 24, weight: .bold))

        case .regular11Monodigit:
            return UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .monospacedDigitSystemFont(ofSize: 11, weight: .regular))
        case .regular20Monodigit:
            return UIFontMetrics(forTextStyle: .title3).scaledFont(for: .monospacedDigitSystemFont(ofSize: 20, weight: .regular))
        }
    }
}
