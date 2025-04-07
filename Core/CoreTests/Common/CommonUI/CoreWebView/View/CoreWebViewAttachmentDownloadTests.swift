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

import XCTest
import WebKit
@testable import Core

class CoreWebViewAttachmentDownloadTests: CoreTestCase {

    private enum TestConstants {
        static let attachmentResponse = HTTPURLResponse(
            url: URL(string: "http://")!,
            statusCode: 200,
            httpVersion: "3.0",
            headerFields: [
                "Content-Disposition": "attachment; filename=\"...\"",
                "Content-Type": "video/mp4"
            ]
        )!
    }

    private class LinkDelegate: CoreWebViewLinkDelegate {
        var routeLinksFrom = UIViewController()
        func handleLink(_ url: URL) -> Bool { false }

        var startedAttachment: CoreWebAttachment?
        func coreWebView(_ webView: CoreWebView, didStartDownloadAttachment attachment: CoreWebAttachment) {
            startedAttachment = attachment
        }

        var failedAttachment: CoreWebAttachment?
        var failure: Error?
        func coreWebView(_ webView: CoreWebView, didFailAttachmentDownload attachment: CoreWebAttachment, with error: any Error) {
            failedAttachment = attachment
            failure = error
        }

        var finishedAttachment: CoreWebAttachment!
        func coreWebView(_ webView: CoreWebView, didFinishAttachmentDownload attachment: CoreWebAttachment) {
            finishedAttachment = attachment
        }
    }

    private class MockNavigationResponse: WKNavigationResponse {
        let mockResponse: URLResponse
        override var response: URLResponse { mockResponse }

        init(response: URLResponse) {
            mockResponse = response
            super.init()
        }
    }

    private var download: WKDownload!
    private var webView: CoreWebView!
    private var linkDelegate: LinkDelegate!

    override func setUpWithError() throws {
        download = WKDownload()
        webView = CoreWebView()
        linkDelegate = LinkDelegate()

        webView.linkDelegate = linkDelegate
        window.rootViewController?.view.addSubview(webView)
    }

    override func tearDownWithError() throws {
        webView = nil
        linkDelegate = nil
    }

    @MainActor
    func test_attachment_download_policy() async {
        let response = MockNavigationResponse(response: TestConstants.attachmentResponse)
        let policy = await webView.webView(webView, decidePolicyFor: response)
        XCTAssertEqual(policy, .download)
    }

    @MainActor
    func test_download_started_and_finished() async throws {
        // Pre-check
        XCTAssertNil(linkDelegate.startedAttachment)

        let expectedURL = URL.Directories.temporary.appending(component: "example.mp4")
        download.progress.fileURL = expectedURL

        let destinationUrl = await webView
            .download(download,
                      decideDestinationUsing: TestConstants.attachmentResponse,
                      suggestedFilename: "example.mp4")

        XCTAssertEqual(destinationUrl, expectedURL)
        XCTAssertTrue(webView.isDownloadingAttachment)

        let attachment = try XCTUnwrap(webView.downloadingAttachment)
        XCTAssertEqual(linkDelegate.startedAttachment, attachment)
        XCTAssertEqual(attachment.url, expectedURL)
        XCTAssertEqual(attachment.contentType, "video/mp4")

        // Pre-check
        XCTAssertNil(linkDelegate.finishedAttachment)

        // Report Finish
        webView.downloadDidFinish(download)

        XCTAssertFalse(webView.isDownloadingAttachment)

        let finishedAttachment = try XCTUnwrap(linkDelegate.finishedAttachment)
        XCTAssertEqual(finishedAttachment.url, expectedURL)
        XCTAssertEqual(finishedAttachment.contentType, "video/mp4")
    }

    @MainActor
    func test_download_failure() async throws {
        // Pre-check
        XCTAssertNil(linkDelegate.failedAttachment)
        XCTAssertNil(linkDelegate.failure)

        // Start Download
        let expectedURL = URL.Directories.temporary.appending(component: "example.mp4")
        download.progress.fileURL = expectedURL

        let destinationUrl = await webView
            .download(download,
                      decideDestinationUsing: TestConstants.attachmentResponse,
                      suggestedFilename: "example.mp4")

        // Report Failure
        let error = MockError(code: 566)
        webView.download(download, didFailWithError: error, resumeData: nil)

        XCTAssertEqual(destinationUrl, expectedURL)
        XCTAssertFalse(webView.isDownloadingAttachment)

        let failedAttachment = try XCTUnwrap(linkDelegate.failedAttachment)
        let failure = try XCTUnwrap(linkDelegate.failure as? MockError)

        XCTAssertEqual(failedAttachment.url, expectedURL)
        XCTAssertEqual(failedAttachment.contentType, "video/mp4")
        XCTAssertEqual(failure, error)
    }
}

private struct MockError: Equatable, Error {
    let code: Int
}
