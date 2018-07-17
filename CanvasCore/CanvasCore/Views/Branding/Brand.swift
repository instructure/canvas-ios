//
// Copyright (C) 2017-present Instructure, Inc.
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

open class Brand: NSObject {
    public var navBgColor = rgb(14, g: 20, b: 34)
    public var navButtonColor = UIColor.white
    public var navTextColor = UIColor.white
    public var primaryButtonColor = rgb(227, g: 60, b: 41)
    public var primaryButtonTextColor = UIColor.white
    public var primaryBrandColor = rgb(227, g: 60, b: 41)
    public var fontColorDark = UIColor.black
    public var headerImageURL: String = ""
    
    public let secondaryTintColor = #colorLiteral(red: 0.2117647059, green: 0.5450980392, blue: 0.8470588235, alpha: 1)
    public var tintColor: UIColor { return primaryButtonColor }
    
    public init(webPayload: [String: Any]?) {
        if let payload = webPayload {
            if let hex = payload["ic-brand-global-nav-bgd"] as? String, let color = UIColor.colorFromHexString(hex) {
                navBgColor = color
            }
            
            if let hex = payload["ic-brand-global-nav-menu-item__text-color"] as? String, let color = UIColor.colorFromHexString(hex) {
                navTextColor = color
            }
            
            if let hex = payload["ic-brand-global-nav-ic-icon-svg-fill"] as? String, let color = UIColor.colorFromHexString(hex) {
                navButtonColor = color
            }
            if let hex = payload["ic-brand-button--primary-bgd"] as? String, let color = UIColor.colorFromHexString(hex) {
                primaryButtonColor = color
            }
            
            if let hex = payload["ic-brand-button--primary-text"] as? String, let color = UIColor.colorFromHexString(hex) {
                primaryButtonTextColor = color
            }
            
            if let hex = payload["ic-brand-primary"] as? String, let color = UIColor.colorFromHexString(hex) {
                primaryBrandColor = color
            }
            
            if let hex = payload["ic-brand-font-color-dark"] as? String, let color = UIColor.colorFromHexString(hex) {
                fontColorDark = color
            }
            
            if let imagePath = payload["ic-brand-header-image"] as? String {
                headerImageURL = imagePath
            }
        }
    }
    
    open func apply(_ window: UIWindow) {
        window.tintColor = primaryButtonColor
        let tabsAppearance = UITabBar.appearance()
        tabsAppearance.tintColor = primaryBrandColor
        tabsAppearance.barTintColor = UIColor.white
        tabsAppearance.unselectedItemTintColor = UIColor(red: 115/255.0, green: 129/255.0, blue: 140/255.0, alpha: 1)

        let navBarAppearance = UINavigationBar.appearance()
        let customBackButton = UIImage(named: "back_arrow", in: .core, compatibleWith: nil)
        navBarAppearance.backIndicatorImage = customBackButton
        navBarAppearance.backIndicatorTransitionMaskImage = customBackButton
    }
    
    open func navBarTitleView() -> UIView? {
        guard headerImageURL.count > 0 else { return nil }
        return HelmManager.narBarTitleViewFromImagePath(headerImageURL)
    }
    
    fileprivate override init() {
        super.init()
    }
}

private func rgb(_ r: Int, g: Int, b: Int) -> UIColor {
    return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
}

extension Brand {
    private (set) public static var current = Brand()
    
    public static func setCurrent(_ brand: Brand, applyInWindow window: UIWindow? = nil) {
        current = brand
        if let window = window {
            current.apply(window)
        }
    }
}
