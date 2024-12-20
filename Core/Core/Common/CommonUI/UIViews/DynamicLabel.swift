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

@IBDesignable
open class DynamicLabel: UILabel {
    @IBInspectable
    public var textColorName: String = "textDarkest" {
        didSet {
            textColor = Brand.shared.color(textColorName) ?? .textDarkest
        }
    }

    @IBInspectable
    public var textStyle: String = "regular16" {
        didSet {
            font = UIFont.scaledNamedFont(UIFont.Name(rawValue: textStyle) ?? .regular16)
            adjustsFontForContentSizeCategory = true
        }
    }
}
