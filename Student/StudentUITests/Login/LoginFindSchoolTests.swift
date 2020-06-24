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

class LoginFindSchoolTests: CoreUITestCase {
    func mockSearchAndPrefixes(searchTerm: String, results: [APIAccountResult]) {
        for index in searchTerm.indices {
            mockData(GetAccountsSearchRequest(searchTerm: String(searchTerm.prefix(through: index))), value: results)
        }
    }

    func testEnterDomain() {
        mockSearchAndPrefixes(searchTerm: "test", results: [])
        mockData(GetMobileVerifyRequest(domain: "test.instructure.com"), value: APIVerifyClient(authorized: true, base_url: nil, client_id: nil, client_secret: "secret"))

        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.waitToExist()

        LoginFindSchool.searchField.typeText("test\n")
        LoginWeb.webView.waitToExist()
    }

    func testEmptyStates() {
        mockSearchAndPrefixes(searchTerm: "zxzx", results: [])
        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.waitToExist()

        LoginFindAccountResult.emptyCell.waitToExist()
        XCTAssertEqual(LoginFindAccountResult.emptyCell.label(), "How do I find my school?")

        LoginFindSchool.searchField.typeText("zxzx")
        app.activityIndicators.firstElement.waitToVanish()

        XCTAssertEqual(LoginFindAccountResult.emptyCell.label(), "Can’t find your school? Try typing the full school URL. Tap here for help.")
    }

    func testFoundResults() {
        let name = "Crazy Go Nuts University"
        let domain = "http://cgnuonline-eniversity.edu"
        mockSearchAndPrefixes(searchTerm: "cgnu", results: [APIAccountResult.make(name: name, domain: domain)])
        mockData(GetMobileVerifyRequest(domain: domain), value: APIVerifyClient(authorized: true, base_url: nil, client_id: nil, client_secret: "secret"))

        LoginStart.findSchoolButton.tap()
        LoginFindSchool.searchField.waitToExist()

        LoginFindSchool.searchField.typeText("cgnu")
        let item = LoginFindAccountResult.item(host: domain)

        XCTAssertEqual(item.label(), name)
        item.tap()
        LoginWeb.webView.waitToExist()
    }
}
