//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import XCTest

public class SafariAppHelper: BaseHelper {
    public static let safariApp = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
    public static var tabBarItemTitle: XCUIElement { safariApp.find(id: "TabBarItemTitle") }
    public static var reloadButton: XCUIElement { safariApp.find(id: "ReloadButton") }
    public static var URL: XCUIElement { safariApp.find(id: "URL") }
    public static var shareButton: XCUIElement { safariApp.find(id: "ShareButton") }
    public static var clearTextButton: XCUIElement { safariApp.find(id: "ClearTextButton") }
    public static var replaceButton: XCUIElement { safariApp.find(label: "Replace", type: .button) }
    public static var addressLabelIpad: XCUIElement { safariApp.find(id: "UnifiedTabBarItemView?isSelected=true") }

    public static var browserURL: String {
        safariApp.activate()
        reloadButton.waitUntil(.visible)
        var addressLabel = addressLabelIpad.waitUntil(.visible, timeout: 5)
        if addressLabel.isVisible {
            addressLabel.hit()
        } else {
            tabBarItemTitle.actionUntilElementCondition(action: .tap, element: URL, condition: .visible)
            addressLabel = URL.waitUntil(.visible)
        }
        let url = addressLabel.value as? String ?? ""
        return url
    }

    public struct Share {
        public static var copyButton: XCUIElement { SafariAppHelper.safariApp.find(label: "Copy", type: .cell) }
        public static var saveToFiles: XCUIElement { SafariAppHelper.safariApp.find(label: "Save to Files", type: .cell) }
        public static var onMyIphoneButton: XCUIElement { SafariAppHelper.safariApp.find(label: "On My iPhone", type: .button) }
        public static var onMyIpadCell: XCUIElement { SafariAppHelper.safariApp.find(id: "DOC.sidebar.item.On My iPad", type: .cell) }
        public static var onMyLabel: XCUIElement { SafariAppHelper.safariApp.find(labelContaining: "On My iP", type: .staticText) }
        public static var saveButton: XCUIElement { SafariAppHelper.safariApp.find(label: "Save", type: .button) }
        public static var moreButton: XCUIElement { SafariAppHelper.safariApp.find(label: "More", type: .cell) }

        public static func titleLabel(title: String) -> XCUIElement {
            return SafariAppHelper.safariApp.find(label: title)
        }
    }
}
