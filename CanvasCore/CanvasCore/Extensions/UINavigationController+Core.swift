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

import Foundation

public extension UINavigationController {
    
    @objc public func applyDefaultBranding() {
        self.navigationBar.barStyle = .black
        self.navigationBar.barTintColor = Brand.current.navBgColor
        self.navigationBar.tintColor = Brand.current.navTextColor
        self.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([
            NSAttributedString.Key.foregroundColor.rawValue: Brand.current.navTextColor
        ])
        self.navigationBar.isTranslucent = false
    }
    
    // Sets the barTintColor on self as well as a detail in a split view controller situation
    @objc public func syncBarTintColor(_ color: UIColor?) {
        self.navigationBar.barTintColor = color
        syncStyles()
    }
    
    // Same as above but for tintColor
    @objc public func syncTintColor(_ color: UIColor?) {
        self.navigationBar.tintColor = color
        syncStyles()
    }
    
    // Looks at what is in the master, if in split view, and applies what master has to detail
    @objc public func syncStyles() {
        guard let svc = self.splitViewController else { return }
        guard let master = svc.masterNavigationController else { return }
        guard let detail = svc.detailNavigationController else { return }
        detail.navigationBar.barTintColor = master.navigationBar.barTintColor
        detail.navigationBar.tintColor = master.navigationBar.tintColor
        detail.navigationBar.titleTextAttributes = master.navigationBar.titleTextAttributes
        detail.navigationBar.shadowImage = master.navigationBar.shadowImage
        detail.navigationBar.isTranslucent = master.navigationBar.isTranslucent
        detail.navigationBar.barStyle = master.navigationBar.barStyle
        
        if let titleView = detail.topViewController?.navigationItem.titleView as? HelmTitleView {
            var color: UIColor = (convertFromOptionalNSAttributedStringKeyDictionary(master.navigationBar.titleTextAttributes)?[convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)] as? UIColor) ?? .black
            if (master.navigationBar.barStyle != .default) {
                color = .white
            }
            titleView.titleLabel.textColor = color
            titleView.subtitleLabel.textColor = color
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]?) -> [String: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
