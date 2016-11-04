
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit

private func rgb(r: Int, g: Int, b: Int) -> UIColor {
    return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
}

private func rgbPreTint(r: Int, g: Int, b: Int) -> UIColor {
    func adjust(n: Int) -> CGFloat {
        let x: CGFloat = max(CGFloat(n) - 40.0, 0)
        let y: CGFloat = 1.0 - 40.0/255.0
        let z: CGFloat = 255.0
        return x/y/z
    }
    
    return UIColor(red: adjust(r), green: adjust(g), blue: adjust(b), alpha: 1.0)
}

private func prettyImage(named: String) -> UIImage {
    return UIImage(named: named, inBundle: NSBundle(forClass: PandaTableView.classForCoder()), compatibleWithTraitCollection: nil)!
}

public class Brand: NSObject {
    public let tintColor: UIColor
    public let secondaryTintColor: UIColor

    public let navBarTintColor: UIColor
    public let navForegroundColor: UIColor
    
    public let tabBarTintColor: UIColor
    public let tabsForegroundColor: UIColor
    
    public let logo: UIImage
    
    public init(tintColor: UIColor, secondaryTintColor: UIColor, navBarTintColor: UIColor, navForegroundColor: UIColor, tabBarTintColor: UIColor, tabsForegroundColor: UIColor, logo: UIImage) {
        self.tintColor = tintColor
        self.secondaryTintColor = secondaryTintColor
        self.navBarTintColor = navBarTintColor
        self.navForegroundColor = navForegroundColor
        self.tabBarTintColor = tabBarTintColor
        self.tabsForegroundColor = tabsForegroundColor
        
        self.logo = logo
    }


    public func apply(window: UIWindow) {
        window.tintColor = tintColor
        
        let navAppearance = UINavigationBar.appearance()
        navAppearance.barTintColor = navBarTintColor
        navAppearance.tintColor = navForegroundColor
        navAppearance.titleTextAttributes = [
            NSForegroundColorAttributeName: navForegroundColor
        ]

        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = tabsForegroundColor
        tabBarAppearance.barTintColor = tabBarTintColor
    }
}

extension Brand {
    private static let Canvas = Brand(
        tintColor: rgb(227, g: 60, b: 41),
        secondaryTintColor: rgb(0, g: 118, b: 163),
        navBarTintColor: rgb(14, g: 20, b: 34), // This is 52, 57, 69 plugged into this calculator to get it to show right: http://htmlpreview.github.io/?https://github.com/tparry/Miscellaneous/blob/master/UINavigationBar_UIColor_calculator.html
        navForegroundColor: UIColor.whiteColor(),
        tabBarTintColor: UIColor.whiteColor(),
        tabsForegroundColor: rgb(52, g: 57, b: 69),
        logo: prettyImage("canvas_logo"))
    
    private static var currentBrand = Canvas
    
    public class func current() -> Brand {
        return currentBrand
    }
    
    public class func setCurrentBrand(brand: Brand, applyInWindow window: UIWindow? = nil) {
        currentBrand = brand
        if let window = window {
            currentBrand.apply(window)
        }
    }
}
