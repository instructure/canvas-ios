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
    public var textColorName: String = "textInfo" {
        didSet {
            tintColor = Brand.shared.color(textColorName) ?? .textInfo
            setTitleColor(tintColor, for: .normal)
        }
    }

    @IBInspectable
    public var textStyle: String = "semibold16" {
        didSet {
            titleLabel?.font = UIFont.scaledNamedFont(UIFont.Name(rawValue: textStyle) ?? .semibold16)
            titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    @IBInspectable
    public var highlightColorName: String = "" {
        didSet {
            if let color = Brand.shared.color(highlightColorName) {
                setTitleColor(color, for: .highlighted)
            }
        }
    }

    @IBInspectable
    public var borderColorName: String = "" {
        didSet {
            guard let color = Brand.shared.color(borderColorName) else {
                layer.borderWidth = 0
                return
            }
            layer.borderWidth = 0.5
            layer.borderColor = color.cgColor
        }
    }

    open override var isHighlighted: Bool {
        didSet {
            tintColor = titleColor(for: state)
        }
    }

    /// Border is set by using `cgColor` which doesn't change when
    /// the light/dark theme changes so we have to manually force an update.
    override open func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)

        /// Setting an invalid color will spam "CUICatalog: Invalid asset name supplied: ''" error to the console
        if borderColorName != "" {
            let borderColorName = borderColorName
            self.borderColorName = borderColorName
        }
    }
}
