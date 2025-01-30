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

@testable import Core
import WebKit
import XCTest

class DiscussionCreateWebViewModelTests: CoreTestCase {
    private let testNavigation = WKNavigation()
    private var discussionList = UIViewController()

    override func setUp() {
        super.setUp()
        discussionList = UIViewController()
    }

    func test_init_discussion() {
        let testee = DiscussionCreateWebViewModel(
            isAnnouncement: false,
            discussionListViewController: discussionList
        )

        XCTAssertEqual(testee.urlPathComponent, "/discussion_topics/new")
        XCTAssertEqual(testee.navigationBarTitle, String(localized: "New Discussion", bundle: .core))
        XCTAssertEqual(testee.queryItems, [])
        XCTAssertNil(testee.assetID)
    }

    func test_init_announcement() {
        let testee = DiscussionCreateWebViewModel(
            isAnnouncement: true,
            discussionListViewController: discussionList
        )

        XCTAssertEqual(testee.urlPathComponent, "/discussion_topics/new")
        XCTAssertEqual(testee.navigationBarTitle, String(localized: "New Announcement", bundle: .core))
        XCTAssertEqual(testee.queryItems, [URLQueryItem(name: "is_announcement", value: "true")])
        XCTAssertNil(testee.assetID)
    }

    func test_dismissesCreateScreen_andFetchesNewDiscussion_whenDiscussionIsCreated() {
        let mockWebView = MockWebView()
        mockWebView.mockedUrl = URL(string: "/courses/123/discussion_topics/456")!

        let webViewHost = UIViewController()
        webViewHost.view.addSubview(mockWebView)

        let mockDiscussionList = UIViewController()
        let testee = DiscussionCreateWebViewModel(
            isAnnouncement: true,
            router: router,
            discussionListViewController: mockDiscussionList
        )
        let discussionDownloadExpectation = expectation(description: "Discussion Downloaded")
        let request = GetDiscussionTopicRequest(context: .course("123"), topicID: "456", include: [.sections])
        api.mock(request) { _ in
            discussionDownloadExpectation.fulfill()
            return (nil, nil, nil)
        }

        // WHEN
        testee.webView(mockWebView, didStartProvisionalNavigation: testNavigation)

        // THEN
        wait(for: [discussionDownloadExpectation], timeout: 10)
        XCTAssertEqual(router.dismissed, webViewHost)
        XCTAssertTrue(router.lastRoutedTo("/courses/123/discussion_topics/456"))
    }

    private class MockWebView: WKWebView {
        var mockedUrl: URL?

        override var url: URL? {
            get {
                return mockedUrl
            }
            set {
                mockedUrl = newValue
            }
        }
    }
}
