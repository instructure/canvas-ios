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

import Foundation
@testable import Core
import TestsFoundation
import XCTest

class LoginFindSchoolTests: StudentUITestCase {
    func testEnterDomain() {
        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.waitToExist()

        LoginFindSchool.searchField.typeText("test\n")
        LoginWeb.webView.waitToExist()
    }

    func testEmptyStates() {
        mockData(GetAccountsSearchRequest(searchTerm: "zxzx"), value: [])
        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.waitToExist()

        LoginFindAccountResult.emptyCell.waitToExist()
        XCTAssertEqual(LoginFindAccountResult.emptyCell.label(), "How do I find my school?")

        LoginFindSchool.searchField.typeText("zxzx")
        app.activityIndicators.firstElement.waitToVanish()

        XCTAssertEqual(LoginFindAccountResult.emptyCell.label(), "Can’t find your school? Try typing the full school URL. Tap here for help.")
    }

    func testFoundResults() {
        mockData(GetAccountsSearchRequest(searchTerm: "cgnu"), value: [
            APIAccountResult.make(name: "Crazy Go Nuts University", domain: "http://cgnuonline-eniversity.edu"),
        ])

        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.waitToExist()

        LoginFindSchool.searchField.typeText("cgnu")
        let item = LoginFindAccountResult.item(host: "http://cgnuonline-eniversity.edu")

        XCTAssertEqual(item.label(), "Crazy Go Nuts University")
        item.tap()
        LoginWeb.webView.waitToExist()
    }
}
