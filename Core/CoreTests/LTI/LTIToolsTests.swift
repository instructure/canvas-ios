//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import SafariServices
import XCTest
@testable import Core

class LTIToolsTests: CoreTestCase {
    class MockView: UIViewController {
        var presented: UIViewController?
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            presented = viewControllerToPresent
            completion?()
        }
    }
    let mockView = MockView()

    var didOpenExternalURL: URL?

    override func tearDown() {
        UserDefaults.standard.set(nil, forKey: "open_lti_safari")
        super.tearDown()
    }

    func testInitLink() {
        XCTAssertNil(LTITools(link: nil))
        XCTAssertNil(LTITools(link: URL(string: "/")))
        XCTAssertNil(LTITools(link: URL(string: "https://else.where/external_tools/retrieve?url=/")))
        XCTAssertEqual(LTITools(link: URL(string: "/external_tools/retrieve?url=/", relativeTo: environment.api.baseURL))?.url, URL(string: "/"))
    }

    func testInitLinkContext() {
        let defaultContext = LTITools(link: URL(string: "/external_tools/retrieve?url=/", relativeTo: environment.api.baseURL))
        XCTAssertEqual(defaultContext?.context.contextType, .account)
        XCTAssertEqual(defaultContext?.context.id, "self")

        let course = LTITools(link: URL(string: "/courses/1/external_tools/retrieve?url=/", relativeTo: environment.api.baseURL))
        XCTAssertEqual(course?.context.contextType, .course)
        XCTAssertEqual(course?.context.id, "1")

        let account = LTITools(link: URL(string: "/accounts/2/external_tools/retrieve?url=/", relativeTo: environment.api.baseURL))
        XCTAssertEqual(account?.context.contextType, .account)
        XCTAssertEqual(account?.context.id, "2")
    }

    func testGetSessionlessLaunchURL() {
        let tools = LTITools(
            env: environment,
            context: ContextModel(.course, id: "1"),
            id: nil,
            url: nil,
            launchType: nil,
            assignmentID: nil,
            moduleItemID: nil
        )
        let request = GetSessionlessLaunchURLRequest(context: ContextModel(.course, id: "1"), id: nil, url: nil, assignmentID: nil, moduleItemID: nil, launchType: nil)
        let actualURL = URL(string: "/someplace")!

        api.mock(request, value: nil)
        var url: URL?
        let doneNil = expectation(description: "callback completed")
        tools.getSessionlessLaunchURL { result in
            url = result
            doneNil.fulfill()
        }
        wait(for: [doneNil], timeout: 1)
        XCTAssertNil(url)

        api.mock(request, value: nil, error: APIRequestableError.invalidPath(""))
        let doneError = expectation(description: "callback completed")
        tools.getSessionlessLaunchURL { result in
            url = result
            doneError.fulfill()
        }
        wait(for: [doneError], timeout: 1)
        XCTAssertNil(url)

        api.mock(request, value: .make(url: actualURL))
        let doneValue = expectation(description: "callback completed")
        tools.getSessionlessLaunchURL { result in
            url = result
            doneValue.fulfill()
        }
        wait(for: [doneValue], timeout: 1)
        XCTAssertEqual(url, actualURL)
    }

    func testPresentTool() {
        let tools = LTITools(
            env: environment,
            context: ContextModel(.course, id: "1"),
            id: nil,
            url: nil,
            launchType: nil,
            assignmentID: nil,
            moduleItemID: nil
        )
        let request = GetSessionlessLaunchURLRequest(context: ContextModel(.course, id: "1"), id: nil, url: nil, assignmentID: nil, moduleItemID: nil, launchType: nil)
        let actualURL = URL(string: "https://canvas.instructure.com")!

        api.mock(request, value: nil)
        var success = false
        let doneNil = expectation(description: "callback completed")
        tools.presentTool(from: mockView, animated: false) { result in
            success = result
            doneNil.fulfill()
        }
        wait(for: [doneNil], timeout: 1)
        XCTAssertFalse(success)
        XCTAssertNil(mockView.presented)

        api.mock(request, value: nil, error: APIRequestableError.invalidPath(""))
        let doneError = expectation(description: "callback completed")
        tools.presentTool(from: mockView, animated: false) { result in
            success = result
            doneError.fulfill()
        }
        wait(for: [doneError], timeout: 1)
        XCTAssertFalse(success)
        XCTAssertNil(mockView.presented)

        api.mock(request, value: .make(url: actualURL))
        let doneValue = expectation(description: "callback completed")
        tools.presentTool(from: mockView, animated: false) { result in
            success = result
            doneValue.fulfill()
        }
        wait(for: [doneValue], timeout: 1)
        XCTAssertTrue(success)
        XCTAssert(router.presented is SFSafariViewController)
        XCTAssertEqual(router.presented?.modalPresentationStyle, .overFullScreen)

        UserDefaults.standard.set(true, forKey: "open_lti_safari")
        tools.presentTool(from: mockView, animated: true)
    }

    func testPresentToolInSafariProper() {
        let tools = LTITools()
        let request = GetSessionlessLaunchURLRequest(context: tools.context, id: nil, url: nil, assignmentID: nil, moduleItemID: nil, launchType: nil)
        let url = URL(string: "https://canvas.instructure.com")!
        api.mock(request, value: .make(url: url))
        UserDefaults.standard.set(true, forKey: "open_lti_safari")
        tools.presentTool(from: mockView, animated: true)
        XCTAssertEqual(login.externalURL, url)
        XCTAssertNil(router.presented)
    }

    func testPresentGoogleApp() throws {
        let tools = LTITools()
        let request = GetSessionlessLaunchURLRequest(context: tools.context, id: nil, url: nil, assignmentID: nil, moduleItemID: nil, launchType: nil)
        let url = URL(string: "https://canvas.instructure.com")!
        api.mock(request, value: .make(name: "Google Apps", url: url))
        tools.presentTool(from: mockView, animated: true)
        let controller = try XCTUnwrap(router.presented as? GoogleCloudAssignmentViewController)
        XCTAssertEqual(controller.url, url)
    }
}
