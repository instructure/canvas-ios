//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Combine
import Core
@testable import Parent
import TestsFoundation
import WebKit
import XCTest

class ParentSubmissionViewModelTests: ParentTestCase {
    private var mockInteractor: MockParentSubmissionInteractor!
    private let host = UIViewController()
    private var mockWebView = MockWebView()

    override func setUp() {
        super.setUp()
        mockInteractor = MockParentSubmissionInteractor(
            assignmentHtmlURL: URL(string: "/")!,
            observedUserID: "",
            loginSession: nil,
            api: api
        )
    }

    func testShowsAlertOnFailureAfterViewLoad() {
        mockInteractor.feedbackViewLoadShouldFail = true

        let testee = ParentSubmissionViewModel(
            interactor: mockInteractor,
            router: router
        )

        // WHEN
        testee.viewDidLoad(viewController: host, webView: mockWebView)

        // THEN
        XCTAssertEqual(mockInteractor.receivedWebView, mockWebView)
        waitUntil(1, shouldFail: true) {
            router.viewControllerCalls.isEmpty == false
        }
        XCTAssertEqual(router.viewControllerCalls.last?.1, host)
        XCTAssertEqual(router.viewControllerCalls.last?.2, .modal())

        guard let alert = router.viewControllerCalls.last?.0 as? UIAlertController else {
            return XCTFail()
        }

        XCTAssertEqual(alert.title, String(localized: "Something went wrong", bundle: .core))
        XCTAssertEqual(alert.message, String(localized: "There was an error while communicating with the server", bundle: .core))
        XCTAssertEqual(alert.preferredStyle, .alert)
    }

    func testHidesLoadingIndicatorAfterViewLoad() {
        mockInteractor.feedbackViewLoadShouldFail = false

        let testee = ParentSubmissionViewModel(
            interactor: mockInteractor,
            router: router
        )
        let didHideLoadingIndicator = expectation(description: "didHideLoadingIndicator")
        let subscription = testee.hideLoadingIndicator
            .sink { _ in
                didHideLoadingIndicator.fulfill()
            }

        // WHEN
        testee.viewDidLoad(viewController: host, webView: mockWebView)

        // THEN
        wait(for: [didHideLoadingIndicator], timeout: 1)
        subscription.cancel()
    }
}

private class MockParentSubmissionInteractor: ParentSubmissionInteractor {
    var feedbackViewLoadShouldFail = false
    private(set) var receivedWebView: WKWebView?

    required init(
        assignmentHtmlURL: URL,
        observedUserID: String,
        loginSession: Core.LoginSession?,
        api: API
    ) {}

    func loadParentFeedbackView(webView: WKWebView) -> AnyPublisher<Void, any Error> {
        receivedWebView = webView

        if feedbackViewLoadShouldFail {
            return Fail(error: NSError.internalError()).eraseToAnyPublisher()
        } else {
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
}

private class MockWebView: WKWebView {
    init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        super.init(frame: .zero, configuration: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func load(_ request: URLRequest) -> WKNavigation? {
        // noop to avoid unnecessary site load
        nil
    }
}
