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

@testable import Core
import SafariServices
import XCTest

class EmbeddedExternalToolsTests: CoreTestCase {
    // swiftlint:disable:next line_length
    private let sharePointURL = URL(string: "https://instructure-my.sharepoint.com/personal/test_instructure_com/_layouts/15/embed.aspx?UniqueId=redacted&embed=%7B%22ust%22%3Atrue%2C%22hv%22%3A%22CopyEmbedCode%22%7D&referrer=StreamWebApp&referrerScenario=EmbedDialog.Create")!
    private let viewHost = UIViewController()

    override func tearDown() {
        UserDefaults.standard.setValue(nil, forKey: "open_lti_safari")
        super.tearDown()
    }

    func testHandlesSharePointURLInSafari() {
        UserDefaults.standard.setValue(true, forKey: "open_lti_safari")
        let result = EmbeddedExternalTools.handle(url: sharePointURL,
                                                  view: viewHost,
                                                  loginDelegate: login,
                                                  router: router)

        XCTAssertTrue(result)
        XCTAssertEqual(login.externalURL, sharePointURL)
        XCTAssertNil(router.viewControllerCalls.last)
    }

    func testHandlesSharePointURLInApp() {
        UserDefaults.standard.setValue(false, forKey: "open_lti_safari")
        let result = EmbeddedExternalTools.handle(url: sharePointURL,
                                                  view: viewHost,
                                                  loginDelegate: login,
                                                  router: router)

        XCTAssertTrue(result)
        XCTAssertNil(login.externalURL)
        XCTAssertTrue(router.viewControllerCalls.last?.0 is SFSafariViewController)
        XCTAssertEqual(router.viewControllerCalls.last?.1, viewHost)
        XCTAssertEqual(router.viewControllerCalls.last?.2, .modal(.overFullScreen))
    }

    func testNotHandlesCanvasLTIURLs() {
        let canvasLTIURL1 = URL(string: "https://canvas.instructure.com/courses/1/external_tools/sessionless_launch")!
        var result = EmbeddedExternalTools.handle(url: canvasLTIURL1,
                                                  view: viewHost,
                                                  loginDelegate: login,
                                                  router: router)
        XCTAssertFalse(result)

        let canvasLTIURL2 = URL(string: "https://canvas.instructure.com/courses/1/external_tools/retrieve?resource_link_lookup_uuid=123")!
        result = EmbeddedExternalTools.handle(url: canvasLTIURL2,
                                              view: viewHost,
                                              loginDelegate: login,
                                              router: router)

        XCTAssertFalse(result)
    }
}
