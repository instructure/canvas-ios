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

import XCTest
@testable import Core

class LocalizationManagerTests: XCTestCase {
    let appleLanguages = UserDefaults.standard.object(forKey: "AppleLanguages")
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "InstUserLocale")
        UserDefaults.standard.set(appleLanguages, forKey: "AppleLanguages")
    }

    func testCurrentLocale() {
        UserDefaults.standard.set("en", forKey: "InstUserLocale")
        XCTAssertEqual(LocalizationManager.currentLocale, "en")
        UserDefaults.standard.removeObject(forKey: "InstUserLocale")
        XCTAssertEqual(LocalizationManager.currentLocale, Bundle.main.preferredLocalizations.first)
    }

    func testNeedsRestart() {
        XCTAssertFalse(LocalizationManager.needsRestart)
        LocalizationManager.setCurrentLocale("da-x-k12")
        XCTAssertTrue(LocalizationManager.needsRestart)
    }

    func testSetCurrentLocale() {
        LocalizationManager.setCurrentLocale("pt-BR")
        XCTAssertEqual(LocalizationManager.currentLocale, "pt-BR")
        XCTAssertEqual(UserDefaults.standard.object(forKey: "AppleLanguages") as? [String], [ "pt-BR" ])

        LocalizationManager.setCurrentLocale("en-AU-x-unimelb")
        XCTAssertEqual(LocalizationManager.currentLocale, "en-AU-unimelb")
        XCTAssertEqual(UserDefaults.standard.object(forKey: "AppleLanguages") as? [String], [ "en-AU-unimelb" ])

        LocalizationManager.setCurrentLocale("da-x-k12")
        XCTAssertEqual(LocalizationManager.currentLocale, "da-instk12")
        XCTAssertEqual(UserDefaults.standard.object(forKey: "AppleLanguages") as? [String], [ "da-instk12" ])

        LocalizationManager.setCurrentLocale("tlh") // unsupported
        XCTAssertEqual(LocalizationManager.currentLocale, "da-instk12")
        XCTAssertEqual(UserDefaults.standard.object(forKey: "AppleLanguages") as? [String], [ "da-instk12" ])

        LocalizationManager.setCurrentLocale(nil)
        XCTAssertEqual(LocalizationManager.currentLocale, "da-instk12")
        XCTAssertEqual(UserDefaults.standard.object(forKey: "AppleLanguages") as? [String], [ "da-instk12" ])
    }

    func testLocalizeApp() {
        var called = false
        LocalizationManager.localizeForApp(.shared, locale: nil) { called = true }
        XCTAssertTrue(called)
        called = false
        LocalizationManager.localizeForApp(.shared, locale: "zh") { called = true }
        XCTAssert(UIApplication.shared.delegate?.window??.rootViewController?.presentedViewController is UIAlertController)
        UIApplication.shared.delegate?.window??.rootViewController?.presentedViewController?.dismiss(animated: false)
        XCTAssertFalse(called)
    }
}
