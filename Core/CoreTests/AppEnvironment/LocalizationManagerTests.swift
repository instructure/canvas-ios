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

class LocalizationManagerTests: CoreTestCase {
    class Present: UIViewController {
        var presented: UIViewController?
        override var presentedViewController: UIViewController? {
            return presented
        }
    }

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

    func testConvertCustomLocale() {
        var inputLocale: String?

        inputLocale = "pt-BR"
        XCTAssertEqual(LocalizationManager.convertCustomLocale(inputLocale), "pt-BR")

        inputLocale = "en-AU-x-unimelb"
        XCTAssertEqual(LocalizationManager.convertCustomLocale(inputLocale), "en-AU-unimelb")

        inputLocale = "da-x-k12"
        XCTAssertEqual(LocalizationManager.convertCustomLocale(inputLocale), "da-instk12")

        inputLocale = "en-AU-x-123456789012345"
        XCTAssertEqual(LocalizationManager.convertCustomLocale(inputLocale), "en-AU-12345678")

        inputLocale = nil
        XCTAssertEqual(LocalizationManager.convertCustomLocale(inputLocale), "")
    }

    // This test is disabled, because Language & Region are fixed (en & US) for tests, and it would always fail.
    // Main logic is extracted and tested above.
    // To enable it: set TestPlan (or Scheme) Language & Region to System, comment out XCTSkip() below.
    func testSetCurrentLocale() throws {
        try XCTSkipIf(true, "This test is disabled, because Language & Region are fixed (en & US) for tests, and it would always fail.")

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
        let present = Present()
        present.presented = UIAlertController(title: "test", message: nil, preferredStyle: .alert)
        environment.window?.rootViewController = present
        LocalizationManager.localizeForApp(.shared, locale: "zh") { called = true }
        XCTAssertEqual(router.dismissed, present.presentedViewController)
        XCTAssert(router.presented is UIAlertController)
        XCTAssertFalse(called)

        called = false
        present.presented = nil
        router.dismissed = nil
        LocalizationManager.localizeForApp(.shared, locale: "zh") { called = true }
        XCTAssert(router.presented is UIAlertController)
        XCTAssertNil(router.dismissed)
        XCTAssertFalse(called)

        LocalizationManager.suspend = #selector(UIApplication.accessibilityActivate)
        let action = ((router.presented as? UIAlertController)?.actions.first as? AlertAction)!
        XCTAssertEqual(action.title, "Close App")
        action.handler?(action)
        XCTAssertFalse(called)
    }
}
