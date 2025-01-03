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

class CoreWebViewFileURLLoadTests: CoreTestCase {
    /// Static so the internal mock class can access it.
    private static let mockFileLoadNavigation =  WKNavigation()
    /// Declaring these navigation objects inside a method causes a crash.
    private let unknownNavigation = WKNavigation()
    private let testee = MockWebView()

    func testCallbackOnProvisionalNavigationFail() {
        let completionExpectation = expectation(description: "callback executed")
        testee.loadFileURL(
            workingDirectory,
            allowingReadAccessTo: workingDirectory
        ) {
            completionExpectation.fulfill()
            XCTAssertTrue(Thread.isMainThread)
        }

        // WHEN
        testee.webView(
            testee,
            didFailProvisionalNavigation: Self.mockFileLoadNavigation,
            withError: NSError.internalError()
        )

        // THEN
        waitForExpectations(timeout: 1)
    }

    func testCallbackOnNavigationFail() {
        let completionExpectation = expectation(description: "callback executed")
        testee.loadFileURL(
            workingDirectory,
            allowingReadAccessTo: workingDirectory
        ) {
            completionExpectation.fulfill()
            XCTAssertTrue(Thread.isMainThread)
        }

        // WHEN
        testee.webView(
            testee,
            didFail: Self.mockFileLoadNavigation,
            withError: NSError.internalError()
        )

        // THEN
        waitForExpectations(timeout: 1)
    }

    func testCallbackOnNavigationFinish() {
        let completionExpectation = expectation(description: "callback executed")
        testee.loadFileURL(
            workingDirectory,
            allowingReadAccessTo: workingDirectory
        ) {
            completionExpectation.fulfill()
            XCTAssertTrue(Thread.isMainThread)
        }

        // WHEN
        testee.webView(
            testee,
            didFinish: Self.mockFileLoadNavigation
        )

        // THEN
        waitForExpectations(timeout: 1)
    }

    func testNoCallbackOnUnknownNavigation() {
        let noCallbackExpectation = expectation(description: "callback not executed")
        noCallbackExpectation.isInverted = true
        testee.loadFileURL(
            workingDirectory,
            allowingReadAccessTo: workingDirectory
        ) {
            noCallbackExpectation.fulfill()
        }

        // WHEN
        testee.webView(
            testee,
            didFinish: unknownNavigation
        )
        testee.webView(
            testee,
            didFail: unknownNavigation,
            withError: NSError.internalError()
        )
        testee.webView(
            testee,
            didFailProvisionalNavigation: unknownNavigation,
            withError: NSError.internalError()
        )

        // THEN
        waitForExpectations(timeout: 1)
    }

    func testNoMultipleCallbacks() {
        let completionExpectation = expectation(description: "callback executed")
        testee.loadFileURL(
            workingDirectory,
            allowingReadAccessTo: workingDirectory
        ) {
            completionExpectation.fulfill()
            XCTAssertTrue(Thread.isMainThread)
        }

        // WHEN
        testee.webView(
            testee,
            didFailProvisionalNavigation: Self.mockFileLoadNavigation,
            withError: NSError.internalError()
        )
        testee.webView(
            testee,
            didFail: Self.mockFileLoadNavigation,
            withError: NSError.internalError()
        )
        testee.webView(
            testee,
            didFinish: Self.mockFileLoadNavigation
        )

        // THEN
        waitForExpectations(timeout: 1)
    }
}

extension CoreWebViewFileURLLoadTests {

    private class MockWebView: CoreWebView {

        /// We override this for two reasons:
        /// - To prevent the actual load happening that interferes with the test
        /// - To control the returned navigation object
        override func loadFileURL(
            _ url: URL,
            allowingReadAccessTo directory: URL
        ) -> WKNavigation {
            mockFileLoadNavigation
        }
    }
}
