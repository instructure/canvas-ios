//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import WebKit
@testable import Core
@testable import Student
import TestsFoundation

class QuizWebViewControllerTests: StudentTestCase {
    lazy var controller = QuizWebViewController.create(courseID: "1", quizID: "1")

    let to = URL(string: "https://canvas.instructure.com/courses/1/quizzes/1?force_user=1&persist_headless=1&platform=ios")!
    let session_url = URL(string: "data:text/plain,")!

    override func setUp() {
        super.setUp()
        api.mock(GetWebSessionRequest(to: to), value: .init(session_url: session_url, requires_terms_acceptance: false))
    }

    func testLayout() {
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.title, "Take Quiz")
        XCTAssertEqual(controller.webView.url, session_url)

        var confirm: Bool = true
        controller.webView.uiDelegate?.webView?(controller.webView, runJavaScriptConfirmPanelWithMessage: "Boo", initiatedByFrame: WKFrameInfo()) {
            confirm = $0
        }
        var alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.message, "Boo")
        XCTAssertEqual(alert?.actions.count, 2)
        var action = (alert?.actions[0] as? AlertAction)!
        XCTAssertEqual(action.title, "Cancel")
        action.handler?(action)
        XCTAssertEqual(confirm, false)
        action = (alert?.actions[1] as? AlertAction)!
        XCTAssertEqual(action.title, "OK")
        action.handler?(action)
        XCTAssertEqual(confirm, true)

        let take = URL(string: "https://canvas.instructure.com/courses/1/quizzes/1/take?page=2")!
        XCTAssertEqual(controller.webView.linkDelegate?.handleLink(take), false)
        XCTAssertEqual(controller.webView.linkDelegate?.handleLink(session_url), true)
        XCTAssert(router.lastRoutedTo(session_url))

        let exitButton = controller.navigationItem.rightBarButtonItem!
        XCTAssertEqual(exitButton.title, "Exit")
        _ = exitButton.target?.perform(exitButton.action)
        XCTAssertEqual(router.dismissed, controller)

        router.dismissed = nil
        controller.webView.loadHTMLString("", baseURL: take)
        _ = exitButton.target?.perform(exitButton.action)
        alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.message, "Are you sure you want to leave this quiz?")
        XCTAssertEqual(alert?.actions.count, 2)
        action = (alert?.actions[0] as? AlertAction)!
        XCTAssertEqual(action.title, "Stay")
        action.handler?(action)
        XCTAssertEqual(router.dismissed, nil)
        action = (alert?.actions[1] as? AlertAction)!
        XCTAssertEqual(action.title, "Leave")
        action.handler?(action)
        XCTAssertEqual(router.dismissed, controller)
    }
}
