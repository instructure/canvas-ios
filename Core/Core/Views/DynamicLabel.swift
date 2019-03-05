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

@IBDesignable
open class DynamicLabel: UILabel {
    @IBInspectable
    public var textColorName: String = "textDarkest" {
        didSet {
            textColor = Brand.shared.color(textColorName) ?? .named(.textDarkest)
        }
    }

    @IBInspectable
    public var textStyle: String = "body" {
        didSet {
            font = UIFont.scaledNamedFont(UIFont.Name(rawValue: textStyle) ?? .body)
            adjustsFontForContentSizeCategory = true
        }
    }
}
