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
open class IconView: UIImageView {
    @IBInspectable
    public var iconColorName: String = "textInfo" {
        didSet {
            tintColor = Brand.shared.color(iconColorName) ?? .textInfo
        }
    }

    @IBInspectable
    public var iconName: String = "" {
        didSet {
            if let icon = UIImage(named: iconName, in: .core, compatibleWith: nil) {
                image = icon
            }
        }
    }

    @IBInspectable
    public var mirrorX: Bool = false {
        didSet {
            transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
}
