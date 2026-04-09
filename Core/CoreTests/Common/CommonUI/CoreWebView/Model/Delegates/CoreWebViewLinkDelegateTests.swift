//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import XCTest

class CoreWebViewLinkDelegateTests: CoreTestCase {

    func testUIViewControllerDefaultRouteSource() {
        let testee = TestViewController()

        XCTAssertEqual(testee.routeLinksFrom, testee)
    }

    func testUIViewControllerDefaultLinkHandler() {
        let testee = TestViewController()
        let url = URL(string: "/test")!

        // WHEN
        let didHandleLink = testee.handleLink(url)

        // THEN
        XCTAssertTrue(didHandleLink)
        XCTAssertTrue(router.lastRoutedTo("/test"))
    }

    // MARK: - didFinishAttachmentDownload

    func test_didFinishAttachmentDownload_whenOriginIsBlob_shouldShowShareSheet() {
        let testee = TestViewController()
        let attachment = CoreWebAttachment.make(originIsBlob: true)

        testee.coreWebView(CoreWebView(), didFinishAttachmentDownload: attachment)

        XCTAssertTrue(router.presented is UIActivityViewController)
    }

    func test_didFinishAttachmentDownload_whenOriginIsNotBlob_shouldNotShowShareSheet() {
        let testee = TestViewController()
        let attachment = CoreWebAttachment.make(originIsBlob: false)

        testee.coreWebView(CoreWebView(), didFinishAttachmentDownload: attachment)

        XCTAssertEqual(router.presented, nil)
    }

    // MARK: - showShareSheet

    func test_showShareSheet_shouldPresentActivityViewControllerWithPageSheetModal() {
        let testee = TestViewController()
        let attachmentUrl = URL(string: "https://instructure.com/file.pdf")!
        let attachment = CoreWebAttachment.make(url: attachmentUrl)

        testee.showShareSheet(for: attachment)

        XCTAssertTrue(router.presented is UIActivityViewController)
        XCTAssertEqual(router.lastShownOptions, .modal(.pageSheet, isDismissable: true))
    }
}

private class TestViewController: UIViewController, CoreWebViewLinkDelegate {
}
