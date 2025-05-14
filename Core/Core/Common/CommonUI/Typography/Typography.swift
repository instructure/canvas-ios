//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct Typography {
    /** This is a multiplier for a font's original line height. */
    public enum LineHeight: CGFloat, CaseIterable, Identifiable {
        case fontDefault = 1
        case fit = 1.125
        case condensed = 1.25
        case normal = 1.5
        case double = 2

        public static var body: LineHeight { Style.body.lineHeight }

        public var id: String { name }
        public var name: String {
            switch self {
            case .fontDefault: return "Font Default"
            case .fit: return "Fit"
            case .condensed: return "Condensed"
            case .normal: return "Normal"
            case .double:  return "Double"
            }
        }

        /** Returns how many points of line spacing will achieve the same effect as setting the line height. */
        public func lineSpacing(for font: UIFont) -> CGFloat {
            let fontLineHeight = font.lineHeight
            return (rawValue * fontLineHeight) - fontLineHeight
        }

        /** Returns the modified line height for the given font in points. */
        public func toPoints(for font: UIFont) -> CGFloat { rawValue * font.lineHeight }
    }

    public enum Style {
        case body
        /** Above textCellTitle in case the cell has 3 rows. */
        case textCellTopLabel
        case textCellTitle
        /** Below textCellTitle. */
        case textCellSupportingText
        /** Below textCellTitle. */
        case textCellSupportingTextBold
        /** Below textCellSupportingText in case the cell has 3 rows. */
        case textCellBottomLabel

        public var lineHeight: LineHeight {
            switch self {
            case .body: return k5 ? .fontDefault : .condensed
            case .textCellTopLabel: return .condensed
            case .textCellBottomLabel: return .condensed
            case .textCellTitle: return .fit
            case .textCellSupportingText: return .condensed
            case .textCellSupportingTextBold: return .condensed
            }
        }

        public var fontName: UIFont.Name {
            switch self {
            case .body: return .regular16
            case .textCellTopLabel: return .bold14
            case .textCellBottomLabel: return .regular14
            case .textCellTitle: return .bold16
            case .textCellSupportingText: return .regular14
            case .textCellSupportingTextBold: return .bold14
            }
        }

        public var uiFont: UIFont { UIFont.scaledNamedFont(fontName) }
        public var font: Font { Font(uiFont) }
        public static var unscaledBodyUIFont: UIFont { UIFont.applicationFont(ofSize: 16, weight: .regular) }

        private var k5: Bool { AppEnvironment.shared.k5.isK5Enabled }
    }

    public static let Spacings = (
        textCellTopPadding: CGFloat(8),
        textCellBottomPadding: CGFloat(8),
        textCellIconLeadingPadding: CGFloat(18),
        textCellIconTopPadding: CGFloat(10),
        textCellIconTrailingPadding: CGFloat(12)
    )
}
