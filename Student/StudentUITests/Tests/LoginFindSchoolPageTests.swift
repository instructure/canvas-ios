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

class LoginFindSchoolPageTests: StudentTest {
    let page = LoginFindSchoolPage.self

    func testEnterDomain() {
        show(Route.login.url.path)
        LoginStartPage.tap(.findSchoolButton)
        page.waitToExist(.searchField, timeout: 5)

        page.typeText("test\n", in: .searchField)
        LoginWebPage.waitToExist(.webView, timeout: 5)

        LoginWebPage.assertVisible(.webView)
    }

    func testEmptyStates() {
        show(Route.login.url.path)
        LoginStartPage.tap(.findSchoolButton)
        page.waitToExist(.searchField, timeout: 5)

        LoginFindAccountResult.waitToExist(.emptyCell, timeout: 5)
        LoginFindAccountResult.assertText(.emptyCell, equals: "How do I find my school?")

        page.typeText("zxzx", in: .searchField)
        LoginFindAccountResult.waitToExist(.emptyCell, timeout: 5)

        LoginFindAccountResult.assertText(.emptyCell, equals: "Can’t find your school? Try typing the full school URL. Tap here for help.")
    }

    func testFoundResults() {
        mockData(GetAccountsSearchRequest(searchTerm: "cgnu"), value: [
            APIAccountResults.make([ "name": "Crazy Go Nuts University", "domain": "http://cgnuonline-eniversity.edu" ]),
        ])

        show(Route.login.url.path)
        LoginStartPage.tap(.findSchoolButton)
        page.waitToExist(.searchField, timeout: 5)

        page.typeText("cgnu", in: .searchField)
        let item = LoginFindAccountResult.item(host: "http://cgnuonline-eniversity.edu")
        LoginFindAccountResult.waitToExist(item, timeout: 5)

        LoginFindAccountResult.assertText(item, equals: "Crazy Go Nuts University")
        LoginFindAccountResult.tap(item)
        LoginWebPage.waitToExist(.webView, timeout: 5)

        LoginWebPage.assertVisible(.webView)
    }
}
