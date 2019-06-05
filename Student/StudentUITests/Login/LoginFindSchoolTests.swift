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

import Foundation
@testable import Core
import TestsFoundation
import SwiftUITest

class LoginFindSchoolTests: StudentTest {
    func testEnterDomain() {
        show(Route.login.url.path)
        LoginStart.findSchoolButton.tap()
        XCTAssert(LoginFindSchool.searchField.waitToExist(Timeout()))

        LoginFindSchool.searchField.typeText("test\n")
        XCTAssert(LoginWeb.webView.waitToExist(Timeout()))
    }

    func testEmptyStates() {
        show(Route.login.url.path)
        LoginStart.findSchoolButton.tap()
        XCTAssert(LoginFindSchool.searchField.waitToExist(Timeout()))

        XCTAssert(LoginFindAccountResult.emptyCell.waitToExist(Timeout()))
        XCTAssertEqual(LoginFindAccountResult.emptyCell.label, "How do I find my school?")

        LoginFindSchool.searchField.typeText("zxzx")
        XCTAssert(LoginFindAccountResult.emptyCell.waitToExist(Timeout()))

        XCTAssertEqual(LoginFindAccountResult.emptyCell.label, "Can’t find your school? Try typing the full school URL. Tap here for help.")
    }

    func testFoundResults() {
        mockData(GetAccountsSearchRequest(searchTerm: "cgnu"), value: [
            APIAccountResult.make(name: "Crazy Go Nuts University", domain: "http://cgnuonline-eniversity.edu"),
        ])

        show(Route.login.url.path)
        LoginStart.findSchoolButton.tap()
        XCTAssert(LoginFindSchool.searchField.waitToExist(Timeout()))

        LoginFindSchool.searchField.typeText("cgnu")
        let item = LoginFindAccountResult.item(host: "http://cgnuonline-eniversity.edu")
        XCTAssert(item.waitToExist(Timeout()))

        XCTAssertEqual(item.label, "Crazy Go Nuts University")
        item.tap()
        XCTAssert(LoginWeb.webView.waitToExist(Timeout()))
    }
}
