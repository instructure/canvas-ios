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

public class SafariAppHelper: BaseHelper {
    public static let safariApp = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
    public static var tabBarItemTitle: XCUIElement { safariApp.find(id: "TabBarItemTitle") }
    public static var reloadButton: XCUIElement { safariApp.find(id: "ReloadButton") }
    public static var URL: XCUIElement { safariApp.find(id: "URL") }
    public static var shareButton: XCUIElement { safariApp.find(id: "ShareButton") }
    public static var clearTextButton: XCUIElement { safariApp.find(id: "ClearTextButton") }

    public static var browserURL: String {
        safariApp.activate()
        reloadButton.waitUntil(.visible)
        tabBarItemTitle.hit()
        let url = URL.waitUntil(.visible).value as? String ?? ""
        return url
    }

    public static func launchAppWithURL(_ url: String) {
        safariApp.launch()
        tabBarItemTitle.hit()
        if clearTextButton.waitUntil(.hittable, timeout: 5).isVisible {
            clearTextButton.hit()
        }
        URL.writeText(text: url, hitGo: true, customApp: safariApp)
    }

    public struct Share {
        public static var copyButton: XCUIElement { SafariAppHelper.safariApp.find(label: "Copy", type: .cell) }
        public static var saveToFiles: XCUIElement { SafariAppHelper.safariApp.findAll(type: .cell, minimumCount: 6)[6] }
        public static var onMyIphoneButton: XCUIElement { SafariAppHelper.safariApp.find(label: "On My iPhone", type: .button) }
        public static var onMyIphoneLabel: XCUIElement { SafariAppHelper.safariApp.find(label: "On My iPhone", type: .staticText) }
        public static var saveButton: XCUIElement { SafariAppHelper.safariApp.find(label: "Save", type: .button) }

        public static func titleLabel(title: String) -> XCUIElement {
            return SafariAppHelper.safariApp.find(label: title, type: .staticText)
        }
    }
}
