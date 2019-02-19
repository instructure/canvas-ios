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
open class DynamicButton: UIButton {
    @IBInspectable
    public var backgroundColorName: String = "" {
        didSet {
            if let color = Brand.shared.color(backgroundColorName) {
                backgroundColor = color
            }
        }
    }

    @IBInspectable
    public var iconName: String = "" {
        didSet {
            if let icon = UIImage(named: iconName, in: .core, compatibleWith: nil) {
                setImage(icon, for: .normal)
            }
        }
    }

    @IBInspectable
    public var textColorName: String = "electric" {
        didSet {
            tintColor = Brand.shared.color(textColorName) ?? .named(.electric)
        }
    }

    @IBInspectable
    public var textStyle: String = "button" {
        didSet {
            titleLabel?.font = UIFont.scaledNamedFont(UIFont.Name(rawValue: textStyle) ?? .button)
            titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }
}
