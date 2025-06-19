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

class UIFontExtensionsTests: XCTestCase {

    override func tearDown() {
        super.tearDown()

        AppEnvironment.shared.k5.userDidLogout()
    }

    func testApplicationFontName() {
        var fontName: String = ""

        [UIFont.Weight.black, .heavy].forEach { weight in
            fontName = UIFont.applicationFontName(weight: weight)
            XCTAssertEqual(fontName, "Lato-Black")

            fontName = UIFont.applicationFontName(weight: weight, isItalic: true)
            XCTAssertEqual(fontName, "Lato-Black")
        }

        [UIFont.Weight.bold, .medium].forEach { weight in
            fontName = UIFont.applicationFontName(weight: weight)
            XCTAssertEqual(fontName, "Lato-Bold")

            fontName = UIFont.applicationFontName(weight: weight, isItalic: true)
            XCTAssertEqual(fontName, "Lato-BoldItalic")
        }

        fontName = UIFont.applicationFontName(weight: .semibold)
        XCTAssertEqual(fontName, "Lato-SemiBold")

        fontName = UIFont.applicationFontName(weight: .semibold, isItalic: true)
        XCTAssertEqual(fontName, "Lato-SemiBoldItalic")

        [UIFont.Weight.regular, .light, .thin, .ultraLight].forEach { weight in
            fontName = UIFont.applicationFontName(weight: weight)
            XCTAssertEqual(fontName, "Lato-Regular")

            fontName = UIFont.applicationFontName(weight: weight, isItalic: true)
            XCTAssertEqual(fontName, "Lato-Italic")
        }

        mockK5Mode()

        [UIFont.Weight.black, .heavy].forEach { weight in
            fontName = UIFont.applicationFontName(weight: weight)
            XCTAssertEqual(fontName, "BalsamiqSans-Bold")
        }

        [UIFont.Weight.bold, .medium, .semibold, .regular, .light, .thin, .ultraLight].forEach { weight in
            fontName = UIFont.applicationFontName(weight: weight)
            XCTAssertEqual(fontName, "BalsamiqSans-Regular")
        }
    }

    func testScaledNamedFont() {
        for name in UIFont.Name.allCases {
            XCTAssertNotNil(UIFont.scaledNamedFont(name))
        }
    }

    func testScaledK5Font() {
        mockK5Mode()

        for name in UIFont.Name.allCases {
            XCTAssertNotNil(UIFont.scaledNamedFont(name))
        }
    }

    func testFontNameAttributes() {
        XCTAssertEqual(UIFont.Name.bold10.weight, .bold)
        XCTAssertEqual(UIFont.Name.bold16.weight, .bold)
        XCTAssertEqual(UIFont.Name.medium10.weight, .medium)
        XCTAssertEqual(UIFont.Name.medium14.weight, .medium)
        XCTAssertEqual(UIFont.Name.semibold13.weight, .semibold)
        XCTAssertEqual(UIFont.Name.semibold18.weight, .semibold)
        XCTAssertEqual(UIFont.Name.regular10.weight, .regular)
        XCTAssertEqual(UIFont.Name.regular13.weight, .regular)
        XCTAssertEqual(UIFont.Name.heavy24.weight, .heavy)

        XCTAssertFalse(UIFont.Name.regular15.isItalic)
        XCTAssertTrue(UIFont.Name.regular14Italic.isItalic)
        XCTAssertTrue(UIFont.Name.semibold16Italic.isItalic)

        XCTAssertEqual(UIFont.Name.regular15.fontSize, 15)
        XCTAssertEqual(UIFont.Name.semibold13.fontSize, 13)
        XCTAssertEqual(UIFont.Name.medium14.fontSize, 14)
        XCTAssertEqual(UIFont.Name.heavy24.fontSize, 24)
        XCTAssertEqual(UIFont.Name.bold16.fontSize, 16)

        XCTAssertTrue(UIFont.Name.regular11Monodigit.isMonospaced)
        XCTAssertTrue(UIFont.Name.regular20Monodigit.isMonospaced)
        XCTAssertFalse(UIFont.Name.regular10.isMonospaced)

        XCTAssertEqual(UIFont.Name.regular10.style, .body)
        XCTAssertEqual(UIFont.Name.semibold12.style, .body)

        XCTAssertEqual(UIFont.Name.semibold16.style, .callout)
        XCTAssertEqual(UIFont.Name.regular20.style, .callout)

        XCTAssertEqual(UIFont.Name.medium20.style, .title)
        XCTAssertEqual(UIFont.Name.heavy24.style, .title)

        XCTAssertEqual(UIFont.Name.medium16.style, .title2)
        XCTAssertEqual(UIFont.Name.bold15.style, .title2)

        XCTAssertEqual(UIFont.Name.bold22.style, .title3)
        XCTAssertEqual(UIFont.Name.medium10.style, .title3)

        XCTAssertEqual(UIFont.Name.bold34.style, .largeTitle)
    }

    // MARK: Utils

    private func mockK5Mode() {
        ExperimentalFeature.K5Dashboard.isEnabled = true
        let environment = AppEnvironment.shared
        environment.userDefaults = .fallback
        environment.userDefaults?.isElementaryViewEnabled = true
        environment.k5.userDidLogin(isK5Account: true)
    }
}
