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

    func testInitLink() {
        XCTAssertNil(LTITools(link: nil))
        XCTAssertNil(LTITools(link: URL(string: "/")))
        XCTAssertNil(LTITools(link: URL(string: "https://else.where/external_tools/retrieve?url=/")))
        XCTAssertEqual(LTITools(link: URL(string: "/external_tools/retrieve?url=/", relativeTo: api.baseURL))?.url, URL(string: "/"))
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

        api.mock(request)
        var url: URL?
        let doneNil = expectation(description: "callback completed")
        tools.getSessionlessLaunchURL { result in
            url = result
            doneNil.fulfill()
        }
        wait(for: [doneNil], timeout: 1)
        XCTAssertNil(url)

        api.mock(request, error: APIRequestableError.invalidPath(""))
        let doneError = expectation(description: "callback completed")
        tools.getSessionlessLaunchURL { result in
            url = result
            doneError.fulfill()
        }
        wait(for: [doneError], timeout: 1)
        XCTAssertNil(url)

        api.mock(request, value: APIGetSessionlessLaunchResponse(url: actualURL))
        let doneValue = expectation(description: "callback completed")
        tools.getSessionlessLaunchURL { result in
            url = result
            doneValue.fulfill()
        }
        wait(for: [doneValue], timeout: 1)
        XCTAssertEqual(url, actualURL)
    }

    func testPresentToolInSFSafariViewController() {
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

        api.mock(request)
        var success = false
        let doneNil = expectation(description: "callback completed")
        tools.presentToolInSFSafariViewController(from: mockView, animated: false) { result in
            success = result
            doneNil.fulfill()
        }
        wait(for: [doneNil], timeout: 1)
        XCTAssertFalse(success)
        XCTAssertNil(mockView.presented)

        api.mock(request, error: APIRequestableError.invalidPath(""))
        let doneError = expectation(description: "callback completed")
        tools.presentToolInSFSafariViewController(from: mockView, animated: false) { result in
            success = result
            doneError.fulfill()
        }
        wait(for: [doneError], timeout: 1)
        XCTAssertFalse(success)
        XCTAssertNil(mockView.presented)

        api.mock(request, value: APIGetSessionlessLaunchResponse(url: actualURL))
        let doneValue = expectation(description: "callback completed")
        tools.presentToolInSFSafariViewController(from: mockView, animated: false) { result in
            success = result
            doneValue.fulfill()
        }
        wait(for: [doneValue], timeout: 1)
        XCTAssertTrue(success)
        XCTAssert(mockView.presented is SFSafariViewController)

    }
}
