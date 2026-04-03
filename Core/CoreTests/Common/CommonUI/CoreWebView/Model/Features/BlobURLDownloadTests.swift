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
import TestsFoundation
import XCTest

final class BlobURLDownloadTests: CoreTestCase {

    private var webView: CoreWebView!
    private var linkDelegate: MockCoreWebViewLinkDelegate!

    override func setUp() {
        super.setUp()
        linkDelegate = MockCoreWebViewLinkDelegate()
        webView = CoreWebView(features: [.blobURLDownload])
        webView.linkDelegate = linkDelegate
        window.rootViewController?.view.addSubview(webView)
    }

    override func tearDown() {
        webView = nil
        linkDelegate = nil
        super.tearDown()
    }

    // MARK: - messageHandlerName

    func test_messageHandlerName() {
        XCTAssertEqual(BlobURLDownload.messageHandlerName, "blobDownload")
    }

    // MARK: - Script injection

    func test_apply_shouldInjectScriptForAllFrames() {
        let scripts = webView.configuration.userContentController.userScripts
        XCTAssertEqual(scripts.contains { !$0.isForMainFrameOnly }, true)
    }

    // MARK: - Click listener

    func test_clickListener_whenBlobLinkIsClicked_shouldTriggerDownloadWithCorrectData() {
        webView.loadHTMLString("""
            <html><body><script>
                var blob = new Blob(['content'], {type: 'text/plain'});
                var a = document.createElement('a');
                a.id = 'link';
                a.href = URL.createObjectURL(blob);
                a.download = 'report.txt';
                a.textContent = 'Download';
                document.body.appendChild(a);
            </script></body></html>
        """)

        waitForPageLoad()

        clickAtElement("link")

        waitUntil(shouldFail: true) { self.linkDelegate.startedAttachment != nil }
        XCTAssertEqual(linkDelegate.startedAttachment?.url.lastPathComponent, "report.txt")
        XCTAssertEqual(linkDelegate.startedAttachment?.contentType, "text/plain")
        XCTAssertEqual(linkDelegate.startedAttachment?.originIsBlob, true)
    }

    func test_clickListener_whenBlobHasNoMimeType_shouldDefaultToOctetStream() {
        webView.loadHTMLString("""
            <html><body><script>
                var blob = new Blob(['content']);
                var a = document.createElement('a');
                a.id = 'link';
                a.href = URL.createObjectURL(blob);
                a.download = 'file';
                a.textContent = 'Download';
                document.body.appendChild(a);
            </script></body></html>
        """)

        waitForPageLoad()

        clickAtElement("link")

        waitUntil(shouldFail: true) { self.linkDelegate.startedAttachment != nil }
        XCTAssertEqual(linkDelegate.startedAttachment?.url.lastPathComponent, "file")
        XCTAssertEqual(linkDelegate.startedAttachment?.contentType, "application/octet-stream")
    }

    func test_clickListener_whenBlobLinkHasNoDownloadAttribute_shouldUseDefaultFileName() {
        webView.loadHTMLString("""
                <html><body><script>
                    var blob = new Blob(['content'], {type: 'text/plain'});
                    var a = document.createElement('a');
                    a.id = 'link';
                    a.href = URL.createObjectURL(blob);
                    a.textContent = 'Download';
                    document.body.appendChild(a);
                </script></body></html>
            """)

        waitForPageLoad()

        clickAtElement("link")

        waitUntil(shouldFail: true) { self.linkDelegate.startedAttachment != nil }
        XCTAssertEqual(linkDelegate.startedAttachment?.url.lastPathComponent, "download.txt")
    }

    func test_clickListener_whenNonBlobLinkIsClicked_shouldNotTriggerDownload() {
        webView.loadHTMLString("""
            <html><body><a id="link" href="#anchor">link</a></body></html>
        """)

        waitForPageLoad()

        clickAtElement("link")

        RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        XCTAssertEqual(linkDelegate.startedAttachment, nil)
    }

    // MARK: - Failure alerts

    func test_clickListener_whenBlobSizeExceedsLimit_shouldShowSizeAlert() {
        webView.loadHTMLString("""
            <html>
            <body>
            <script>
                var blob = new Blob(['x'], {type: 'text/plain'});
                var a = document.createElement('a');
                a.id = 'link';
                a.href = URL.createObjectURL(blob);
                a.textContent = 'Download';
                document.body.appendChild(a);
            </script>
            </body>
            </html>
        """)

        waitForPageLoad()

        evaluateJavaScript("""
            window.fetch = function(url) {
                return Promise.resolve({
                    blob: function() {
                        return Promise.resolve({ size: 200 * 1024 * 1024 });
                    }
                });
            }
        """)

        clickAtElement("link")

        waitUntil(shouldFail: true) { (self.router.presented as? UIAlertController) != nil }
        XCTAssertEqual(
            (router.presented as? UIAlertController)?.message,
            "Attachment file size is too large!"
        )
        XCTAssertEqual(linkDelegate.startedAttachment, nil)
    }

    func test_clickListener_whenFetchFails_shouldShowFetchErrorAlert() {
        webView.loadHTMLString("""
            <html>
            <body>
            <script>
                var blob = new Blob(['x'], {type: 'text/plain'});
                var a = document.createElement('a');
                a.id = 'link';
                a.href = URL.createObjectURL(blob);
                a.textContent = 'Download';
                document.body.appendChild(a);
            </script>
            </body>
            </html>
        """)

        waitForPageLoad()

        evaluateJavaScript("""
            window.fetch = function() {
                return Promise.reject(new Error('Network error'));
            }
        """)

        clickAtElement("link")

        waitUntil(shouldFail: true) { (self.router.presented as? UIAlertController) != nil }
        XCTAssertEqual(
            (router.presented as? UIAlertController)?.message,
            "Attachment fetch error: Error: Network error"
        )
        XCTAssertEqual(linkDelegate.startedAttachment, nil)
    }

    // MARK: - Private helpers

    private func waitForPageLoad() {
        wait(for: [linkDelegate.navigationFinishedExpectation], timeout: 10)
    }

    private func evaluateJavaScript(_ script: String, description: String? = nil) {
        let jsEvaluated = expectation(description: description ?? "JS evaluated")
        webView.evaluateJavaScript(script) { _, _ in
            jsEvaluated.fulfill()
        }
        wait(for: [jsEvaluated], timeout: 10)
    }

    private func clickAtElement(_ elementId: String) {
        webView.evaluateJavaScript(
            "document.getElementById('\(elementId)').click()",
            completionHandler: nil
        )
    }
}
