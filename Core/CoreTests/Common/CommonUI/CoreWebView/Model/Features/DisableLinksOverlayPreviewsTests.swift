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

class DisableLinksOverlayPreviewsTests: XCTestCase {

    func test_links_with_previews_tweaking() {
        let mockLinkDelegate = MockCoreWebViewLinkDelegate()
        let webView = CoreWebView(features: [.disableLinksOverlayPreviews])
        webView.linkDelegate = mockLinkDelegate
        webView.loadHTMLString(TestConstants.htmlString)
        wait(for: [mockLinkDelegate.navigationFinishedExpectation], timeout: 10)

        let jsEvaluated = expectation(description: "JS evaluated")
        let jsScript = """
        function listLinks() {
            const spans = Array.from(document.querySelectorAll('span.instructure_file_link_holder'));
            const objects = spans.map(elm => {
                const links = Array.from(elm.querySelectorAll("a"));
                return links.map(lin => {
                    let d_href = lin.getAttributeNode("href").value;
                    let d_class = lin.getAttributeNode("class").value;

                    return {href: d_href, a_class: d_class};
                });
            });

            return JSON.stringify(objects);
        }

        listLinks();
        """

        var jsonResult: String?
        webView.evaluateJavaScript(jsScript) { result, _ in
            jsonResult = result as? String
            jsEvaluated.fulfill()
        }

        waitForExpectations(timeout: 1)

        guard
            let jsonData = jsonResult?.data(using: .utf8),
            let spansList = try? JSONDecoder().decode([[HtmlLink]].self, from: jsonData) else {
            XCTFail("Failed to parse JSON result")
            return
        }

        XCTAssertEqual(spansList.count, 2)

        spansList.forEach { span in
            guard span.count == 2 else {
                XCTFail("Expecting 2 links per span")
                return
            }

            let link1 = span[0], link2 = span[1]

            XCTAssertFalse(link1.a_class.contains("preview_in_overlay"))
            XCTAssertTrue(link1.a_class.contains("no_preview"))

            XCTAssertEqual(link2.a_class, "file_download_btn")
            XCTAssertTrue(link1.href.contains("/download?"))
            XCTAssertEqual(link1.href, link2.href)
        }
    }
}

// MARK: - Helpers

private struct HtmlLink: Decodable {
    let href: String
    let a_class: String
}

// MARK: - Test Constants

// swiftlint:disable line_length

private extension DisableLinksOverlayPreviewsTests {

    enum TestConstants {
        static let htmlString =  """
            <div>
               <span class="instructure_file_holder link_holder instructure_file_link_holder">
                   <a class="inline_disabled preview_in_overlay"
                       title="example.pdf"
                       href="https://suhaibalabsi.instructure.com/courses/59827/files/571574?wrap=1&amp;instfs_id=48ffea&amp;access_token=eyJ0eXAi"
                       target="canvas" rel="noopener noreferrer"
                       data-old-link="/courses/59827/files/571574?wrap=1">example.pdf</a>

                       <a class="file_download_btn" role="button" download="" href="https://suhaibalabsi.instructure.com/courses/59827/files/571574/download?instfs_id=48ffea&amp;access_token=eyJ0eXAi&amp;download_frd=1">
                       <span role="presentation">
                           <svg viewBox="0 0 1920 1920" xmlns="http://www.w3.org/2000/svg">
                               <path d="" fill-rule="evenodd"></path>
                           </svg>
                       </span>
                       <span class="screenreader-only">Download example.pdf</span>
                       </a>
               </span>

               <span class="instructure_file_holder link_holder instructure_file_link_holder">
                   <a class="inline_disabled preview_in_overlay"
                       title="demo.docx"
                       href="https://suhaibalabsi.instructure.com/courses/59827/files/576703?wrap=1&amp;instfs_id=48ffea&amp;access_token=eyJ0eXAi"
                       target="canvas" rel="noopener noreferrer"
                       data-old-link="/courses/59827/files/576703?wrap=1">demo.docx</a>

                       <a class="file_download_btn" role="button" download="" href="https://suhaibalabsi.instructure.com/courses/59827/files/576703/download?instfs_id=48ffea&amp;access_token=eyJ0eXAi&amp;download_frd=1">
                       <span role="presentation">
                           <svg viewBox="0 0 1920 1920" xmlns="http://www.w3.org/2000/svg">
                               <path d="" fill-rule="evenodd"></path>
                           </svg>
                       </span>
                       <span class="screenreader-only">Download demo.docx</span>
                       </a>
               </span>
            </div>
        """
    }
}

// swiftlint:enable line_length
