//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import Core

open class Brand: NSObject {
    private var core: Core.Brand

    @objc public var navBgColor: UIColor { return core.navBackground }
    @objc public var navButtonColor: UIColor { return core.navIconFill }
    @objc public var navTextColor: UIColor { return core.navTextColor }
    @objc public var linkColor: UIColor { return core.linkColor }
    @objc public var primaryButtonColor: UIColor { return core.buttonPrimaryBackground }
    @objc public var primaryButtonTextColor: UIColor { return core.buttonPrimaryText }
    @objc public var primaryBrandColor: UIColor { return core.primary }
    @objc public var fontColorDark: UIColor { return core.fontColorDark }
    @objc public var headerImageURL: String { return core.headerImageUrl?.absoluteString ?? "" }
    
    @objc public let secondaryTintColor = #colorLiteral(red: 0.2117647059, green: 0.5450980392, blue: 0.8470588235, alpha: 1)
    @objc public var tintColor: UIColor { return primaryButtonColor }
    
    public init(core: Core.Brand) {
        self.core = core
    }
    
    @objc open func apply(_ window: UIWindow) {
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.tintColor = linkColor
    }
}

extension Brand {
    @objc private (set) public static var current = Brand(core: Core.Brand.shared)
    
    @objc public static func setCurrent(_ brand: Brand, applyInWindow window: UIWindow? = nil) {
        current = brand
        if let window = window {
            current.apply(window)
        }
    }
}
