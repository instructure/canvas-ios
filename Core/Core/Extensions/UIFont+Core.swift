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

import Foundation

public extension UIFont {
    public enum Name: String {
        case body, label, title
    }

    /// Get a named font style, that is dynamically scaled.
    ///
    /// See https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
    public static func scaledNamedFont(_ name: Name) -> UIFont {
        switch name {
        case .body:
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16, weight: .regular))
        case .label:
            return UIFontMetrics(forTextStyle: .callout).scaledFont(for: .systemFont(ofSize: 16, weight: .medium))
        case .title:
            return UIFontMetrics(forTextStyle: .title3).scaledFont(for: .systemFont(ofSize: 20, weight: .semibold))
        }
    }
}
