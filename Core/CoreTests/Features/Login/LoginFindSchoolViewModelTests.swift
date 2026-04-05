//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import TestsFoundation

final class LoginFindSchoolViewModelTests: CoreTestCase {

    private static let testData = (
        name1: "name 1",
        name2: "name 2",
        name3: "name 3",
        name4: "name 4",
        domain1: "domain1.edu",
        domain2: "domain2.edu",
        domain3: "domain3.edu",
        domain4: "domain4.edu",
        nextPageURL: "https://sso.canvaslms.com/api/v1/accounts/search?page=2"
    )
    private lazy var testData = Self.testData

    private var testee: LoginFindSchoolViewModel!
    private var loginDelegate: TestLoginDelegate!

    override func setUp() {
        super.setUp()
        loginDelegate = TestLoginDelegate()
        testee = LoginFindSchoolViewModel()
        testee.loginDelegate = loginDelegate
    }

    override func tearDown() {
        testee = nil
        loginDelegate = nil
        super.tearDown()
    }

    // MARK: - accountDomain(from:)

    func test_accountDomain_withNilInput() {
        XCTAssertEqual(testee.accountDomain(from: nil), nil)
    }

    func test_accountDomain_withEmptyInput() {
        XCTAssertEqual(testee.accountDomain(from: ""), nil)
    }

    func test_accountDomain_withNormalLogin() {
        // WHEN has no dot
        XCTAssertEqual(testee.accountDomain(from: "school"), "school.instructure.com")

        // WHEN has dot
        XCTAssertEqual(testee.accountDomain(from: "school.edu"), "school.edu")
    }

    func test_accountDomain_withManualOAuthLogin_shouldNotModifyDomain() {
        testee.method = .manualOAuthLogin
        XCTAssertEqual(testee.accountDomain(from: "localhost"), "localhost")
    }

    // MARK: - rowsCount

    func test_rowsCount_whenAccountsEmpty() {
        XCTAssertEqual(testee.rowsCount, 1)
    }

    func test_rowsCount_withAccounts() {
        api.mock(GetAccountsSearchRequest(searchTerm: "a"), value: [.make(name: testData.name1, domain: testData.domain1)])
        testee.search(query: "a")

        // WHEN loaded
        XCTAssertEqual(testee.rowsCount, 1)

        // WHEN loadingNextPage
        testee.state.send(.loadingNextPage)
        XCTAssertEqual(testee.rowsCount, 2)

        // WHEN nextPageFailed
        testee.state.send(.nextPageFailed)
        XCTAssertEqual(testee.rowsCount, 2)
    }

    // MARK: - search

    func test_search_withEmptyQuery_shouldClearAccountsAndSetIdleState() {
        api.mock(GetAccountsSearchRequest(searchTerm: "a"), value: [.make()])
        testee.search(query: "a")

        testee.search(query: "")

        XCTAssertEqual(testee.state.value, .idle)
        XCTAssertEqual(testee.accounts.count, 0)
    }

    func test_search_withQuery_shouldPopulateAccountsAndSetLoadedState() {
        api.mock(GetAccountsSearchRequest(searchTerm: "school"), value: [
            .make(name: testData.name1, domain: testData.domain1),
            .make(name: testData.name2, domain: testData.domain2)
        ])

        testee.search(query: "school")

        XCTAssertEqual(testee.state.value, .loaded)
        XCTAssertEqual(testee.accounts.count, 2)
    }

    func test_search_withNextPageLinkHeader_shouldSetHasNextPage() {
        api.mock(GetAccountsSearchRequest(searchTerm: "school"), value: [.make()], response: makeNextPageResponse())

        testee.search(query: "school")

        XCTAssertEqual(testee.hasNextPage, true)
    }

    func test_search_withoutNextPageLinkHeader_shouldNotHaveNextPage() {
        api.mock(GetAccountsSearchRequest(searchTerm: "school"), value: [.make()])

        testee.search(query: "school")

        XCTAssertEqual(testee.hasNextPage, false)
    }

    // MARK: - loadNextPage

    func test_loadNextPage_whenNoNextPage_shouldNotChangeState() {
        api.mock(GetAccountsSearchRequest(searchTerm: "a"), value: [.make()])
        testee.search(query: "a")

        testee.loadNextPage()

        XCTAssertEqual(testee.state.value, .loaded)
        XCTAssertEqual(testee.hasNextPage, false)
    }

    func test_loadNextPage_whenAlreadyLoadingNextPage_shouldDoNothing() {
        testee.state.send(.loadingNextPage)

        testee.loadNextPage()

        XCTAssertEqual(testee.state.value, .loadingNextPage)
    }

    func test_loadNextPage_success_shouldAppendAccountsAndSetLoadedState() {
        api.mock(
            GetAccountsSearchRequest(searchTerm: "a"),
            value: [
                .make(name: testData.name1, domain: testData.domain1),
                .make(name: testData.name2, domain: testData.domain2)
            ],
            response: makeNextPageResponse()
        )
        testee.search(query: "a")
        mockNextPage(with: [
            .make(name: testData.name3, domain: testData.domain3),
            .make(name: testData.name4, domain: testData.domain4)
        ])

        testee.loadNextPage()

        XCTAssertEqual(testee.state.value, .loaded)
        XCTAssertEqual(testee.accounts.count, 4)
        XCTAssertEqual(testee.accounts[2].domain, testData.domain3)
        XCTAssertEqual(testee.accounts[3].domain, testData.domain4)
    }

    func test_loadNextPage_withError_shouldSetNextPageFailedState() {
        api.mock(
            GetAccountsSearchRequest(searchTerm: "a"),
            value: [.make(name: testData.name1, domain: testData.domain1)],
            response: makeNextPageResponse()
        )
        testee.search(query: "a")
        api.mock(
            GetNextRequest<[APIAccountResult]>(path: testData.nextPageURL),
            data: nil,
            error: NSError(domain: "test", code: -1)
        )

        testee.loadNextPage()

        XCTAssertEqual(testee.state.value, .nextPageFailed)
        XCTAssertEqual(testee.accounts.count, 1)
    }

    func test_loadNextPage_afterFailure_shouldRetryAndSucceed() {
        api.mock(
            GetAccountsSearchRequest(searchTerm: "a"),
            value: [
                .make(name: testData.name1, domain: testData.domain1),
                .make(name: testData.name2, domain: testData.domain2)
            ],
            response: makeNextPageResponse()
        )
        testee.search(query: "a")
        api.mock(
            GetNextRequest<[APIAccountResult]>(path: testData.nextPageURL),
            data: nil,
            error: NSError(domain: "test", code: -1)
        )
        testee.loadNextPage()
        XCTAssertEqual(testee.state.value, .nextPageFailed)

        mockNextPage(with: [
            .make(name: testData.name3, domain: testData.domain3),
            .make(name: testData.name4, domain: testData.domain4)
        ])
        testee.loadNextPage()

        XCTAssertEqual(testee.state.value, .loaded)
        XCTAssertEqual(testee.accounts.count, 4)
    }

    // MARK: - rowWillDisplay

    func test_rowWillDisplay_whenAccountsEmpty_shouldNotLoadNextPage() {
        testee.rowWillDisplay(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(testee.state.value, .idle)
    }

    func test_rowWillDisplay_whenStateIsNotLoaded_shouldNotLoadNextPage() {
        api.mock(GetAccountsSearchRequest(searchTerm: "a"), value: [.make()], response: makeNextPageResponse())
        testee.search(query: "a")
        testee.state.send(.nextPageFailed)

        testee.rowWillDisplay(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(testee.hasNextPage, true)
    }

    func test_rowWillDisplay_whenNoNextPage_shouldNotLoadNextPage() {
        api.mock(GetAccountsSearchRequest(searchTerm: "a"), value: [
            .make(name: testData.name1, domain: testData.domain1)
        ])
        testee.search(query: "a")

        testee.rowWillDisplay(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(testee.state.value, .loaded)
        XCTAssertEqual(testee.accounts.count, 1)
    }

    func test_rowWillDisplay_whenNotLastRow_shouldNotLoadNextPage() {
        api.mock(GetAccountsSearchRequest(searchTerm: "a"), value: [
            .make(name: testData.name1, domain: testData.domain1),
            .make(name: testData.name2, domain: testData.domain2)
        ], response: makeNextPageResponse())
        testee.search(query: "a")

        testee.rowWillDisplay(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(testee.hasNextPage, true)
    }

    func test_rowWillDisplay_whenLastRow_withNextPage_shouldLoadNextPage() {
        api.mock(
            GetAccountsSearchRequest(searchTerm: "a"),
            value: [
                .make(name: testData.name1, domain: testData.domain1),
                .make(name: testData.name2, domain: testData.domain2)
            ],
            response: makeNextPageResponse()
        )
        testee.search(query: "a")
        mockNextPage(with: [
            .make(name: testData.name3, domain: testData.domain3),
            .make(name: testData.name4, domain: testData.domain4)
        ])

        testee.rowWillDisplay(at: IndexPath(row: 1, section: 0))

        XCTAssertEqual(testee.state.value, .loaded)
        XCTAssertEqual(testee.accounts.count, 4)
    }

    // MARK: - rowSelected

    func test_rowSelected_whenAccountsEmpty_shouldOpenHelpPage() {
        testee.rowSelected(at: IndexPath(row: 0, section: 0), in: UIViewController())

        XCTAssertEqual(loginDelegate.externalURL, loginDelegate.helpURL)
    }

    func test_rowSelected_withAccountRow_shouldNavigateToLogin() {
        api.mock(GetAccountsSearchRequest(searchTerm: "a"), value: [
            .make(name: testData.name1, domain: testData.domain1)
        ])
        testee.search(query: "a")

        testee.rowSelected(at: IndexPath(row: 0, section: 0), in: UIViewController())

        let shown = router.viewControllerCalls.first?.0 as? LoginWebViewController
        XCTAssertEqual(shown?.host, testData.domain1)
    }

    func test_rowSelected_onRetryRow_shouldTriggerLoadNextPage() {
        api.mock(
            GetAccountsSearchRequest(searchTerm: "a"),
            value: [
                .make(name: testData.name1, domain: testData.domain1),
                .make(name: testData.name2, domain: testData.domain2)
            ],
            response: makeNextPageResponse()
        )
        testee.search(query: "a")
        testee.state.send(.nextPageFailed)
        mockNextPage(with: [
            .make(name: testData.name3, domain: testData.domain3),
            .make(name: testData.name4, domain: testData.domain4)
        ])

        testee.rowSelected(at: IndexPath(row: testee.accounts.count, section: 0), in: UIViewController())

        XCTAssertEqual(testee.state.value, .loaded)
        XCTAssertEqual(testee.accounts.count, 4)
    }

    // MARK: - Private helpers

    private func makeNextPageResponse() -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://sso.canvaslms.com")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Link": "<\(testData.nextPageURL)>; rel=\"next\""]
        )!
    }

    private func mockNextPage(with accounts: [APIAccountResult]) {
        // swiftlint:disable:next force_try
        let data = try! GetAccountsSearchRequest(searchTerm: "a").encode(response: accounts)
        api.mock(GetNextRequest<[APIAccountResult]>(path: testData.nextPageURL), data: data)
    }
}
