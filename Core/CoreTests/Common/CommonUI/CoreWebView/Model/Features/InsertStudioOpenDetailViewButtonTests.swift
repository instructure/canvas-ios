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

import Core
import XCTest

class InsertStudioOpenDetailViewButtonTests: XCTestCase {

    func testInsertion() {
        let mockLinkDelegate = MockCoreWebViewLinkDelegate()
        let webView = CoreWebView(features: [
            .insertStudioOpenInDetailButtons
        ])

        webView.linkDelegate = mockLinkDelegate
        webView.loadHTMLString("""
        <div>
            <p>
                <iframe
                    title="Example Video Title"
                    src="https://suhaibalabsi.instructure.com/media_attachments_iframe/613046"
                    data-media-id="usyier8y9328923"
                >
                </iframe>
            </p>
            <p>
                <iframe
                    title="Video player for Some_File_Name.mp4"
                    src="https://suhaibalabsi.instructure.com/media_attachments_iframe/546734"
                    data-media-id="jshf893y92biuhiuire"
                >
                </iframe>
            </p>
        </div>
        """)

        wait(for: [mockLinkDelegate.navigationFinishedExpectation], timeout: 10)

        let checkInsertionsScript = """
        (function() {
            const elements = document.querySelectorAll('.open_details_button');
            var result = [];
            elements.forEach(elm => {
                result.push(elm.getAttribute("href"));
            });
            return result;
        })()
        """

        let exp = expectation(description: "js evaluated")
        webView.evaluateJavaScript(checkInsertionsScript) { result, _ in
            defer { exp.fulfill() }

            let list = result as? [String]
            let urls = list?.compactMap({ URL(string: $0) }) ?? []

            guard urls.count == 2 else { return }

            XCTAssertEqual(
                urls[0].removingQueryAndFragment().absoluteString,
                "https://suhaibalabsi.instructure.com/media_attachments/613046/immersive_view"
            )

            XCTAssertEqual(
                urls[1].removingQueryAndFragment().absoluteString,
                "https://suhaibalabsi.instructure.com/media_attachments/546734/immersive_view"
            )

            XCTAssertEqual(urls[0].queryValue(for: "title"), "Example Video Title")
            XCTAssertEqual(urls[1].queryValue(for: "title"), "Some_File_Name")
        }

        wait(for: [exp])
    }
}
