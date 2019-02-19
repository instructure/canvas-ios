//
// Copyright (C) 2018-present Instructure, Inc.
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

    func testGetLocales() {
        XCTAssertEqual(LocalizationManager.getLocales().map { "\($0.id): \($0.name)" }, [
            "ar: Arabic",
            "zh: Chinese",
            "zh-HK: Chinese (Hong Kong [China])",
            "da: Danish",
            "da-instk12: Danish (INSTK12)",
            "nl: Dutch",
            "en: English",
            "en-AU: English (Australia)",
            "en-CY: English (Cyprus)",
            "en-GB: English (United Kingdom)",
            "en-GB-instukhe: English (United Kingdom, INSTUKHE)",
            "fr: French",
            "fr-CA: French (Canada)",
            "de: German",
            "ht: Haitian Creole",
            "ja: Japanese",
            "mi: Maori",
            "nb: Norwegian Bokmål",
            "nb-instk12: Norwegian Bokmål (INSTK12)",
            "pl: Polish",
            "pt: Portuguese",
            "pt-BR: Portuguese (Brazil)",
            "ru: Russian",
            "sl-SI: Slovenian (Slovenia)",
            "es: Spanish",
            "sv: Swedish",
            "sv-instk12: Swedish (INSTK12)",
            "cy: Welsh",
        ])
    }

    func testSetCurrentLocale() {
        LocalizationManager.setCurrentLocale("pt-BR")
        XCTAssertEqual(LocalizationManager.currentLocale, "pt-BR")
        XCTAssertEqual(UserDefaults.standard.object(forKey: "AppleLanguages") as? [String], [ "pt-BR" ])

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

    func testNeedsRestart() {
        XCTAssertFalse(LocalizationManager.needsRestart)
        LocalizationManager.setCurrentLocale("da-x-k12")
        XCTAssertTrue(LocalizationManager.needsRestart)
    }
}
