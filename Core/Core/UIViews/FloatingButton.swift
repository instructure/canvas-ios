//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
open class FloatingButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        layer.cornerRadius = ceil( bounds.size.width / 2 )
        layer.shadowOffset = CGSize(width: 0, height: 4.0)
        layer.shadowColor = UIColor.backgroundDarkest.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 12
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    @IBInspectable
    public var backgroundColorName: String = "backgroundInfo" {
        didSet {
            backgroundColor = Brand.shared.color(backgroundColorName) ?? .backgroundInfo
        }
    }

    @IBInspectable
    public var iconColorName: String = "white" {
        didSet {
            tintColor = Brand.shared.color(iconColorName) ?? .white
        }
    }

    @IBInspectable
    public var iconName: String = "" {
        didSet {
            setImage(UIImage(named: iconName, in: .core, compatibleWith: nil), for: .normal)
        }
    }
}
