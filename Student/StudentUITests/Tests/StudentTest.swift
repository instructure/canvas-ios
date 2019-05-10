//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
import SwiftUITest
@testable import Core
@testable import TestsFoundation

var xcuiApp: XCUIApplication?

// Always recompute app to avoid stale testCase references
private var getApp = { return DriverFactory.getEarlGreyDriver() }
var app: Driver { return getApp() }
var host: TestHost {
    return unsafeBitCast(
        GREYHostApplicationDistantObject.sharedInstance,
        to: TestHost.self)
}

class StudentTest: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        if xcuiApp == nil {
            xcuiApp = XCUIApplication()

            var env = xcuiApp!.launchEnvironment
            env["IS_UI_TEST"] = "TRUE"
            xcuiApp!.launchEnvironment = env

            xcuiApp!.launch()
        }
        host.reset()
        // This sleep helps ensure old views got cleaned up, so EG2 doesn't find them accidentally.
        sleep(1) // FIXME: Remove this and fix flakiness better.

        getApp = { return EarlGreyDriver(xcuiApp!, testCase: self) }
    }

    func show(_ route: String) {
        host.show(route)
    }

    func dismissKeyboard() {
        guard let app = xcuiApp else {
            XCTFail("app is not set")
            return
        }
        do {
            try app.dismissKeyboard()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func navBarColorHex() -> String? {
        guard let image = xcuiApp?.navigationBars.firstMatch.screenshot().image,
            let pixelData = image.cgImage?.dataProvider?.data,
            let data = CFDataGetBytePtr(pixelData) else {
            return nil
        }
        let red = UInt(data[0]), green = UInt(data[1]), blue = UInt(data[2]), alpha = UInt(data[3])
        let num = (alpha << 24) + (red << 16) + (green << 8) + blue
        return "#\(String(num, radix: 16))".replacingOccurrences(of: "#ff", with: "#")
    }

    func capturePhoto() {
        allowAccessToCamera()
        xcuiApp!.buttons["PhotoCapture"].tap()
        let usePhoto = xcuiApp!.buttons["Use Photo"]

        // Sometimes takes a few seconds to focus
        _ = usePhoto.waitForExistence(timeout: 10)
        usePhoto.tap()
    }

    func allowAccessToCamera() {
        let alert = xcuiApp!.alerts["“Student” Would Like to Access the Camera"]
        if alert.exists {
            alert.buttons["OK"].tap()
        }
    }

    func allowAccessToMicrophone(waitFor id: String, afterRunning activate: () -> Void) {
        let alertHandler = addUIInterruptionMonitor(withDescription: "Permission Alert") { (alert) -> Bool in
            if alert.buttons.matching(identifier: "OK").count > 0 {
                alert.buttons["OK"].tap()
                return true
            } else {
                return false
            }
        }
        activate()
        if !xcuiApp!.buttons[id].waitForExistence(timeout: 1) {
            // Cause the alert handler to be invoked if the alert is currently shown.
            XCUIApplication().swipeUp()
        }
        _ = xcuiApp!.buttons[id].waitForExistence(timeout: 1)
        removeUIInterruptionMonitor(alertHandler)
    }

    func mockData<R: APIRequestable>(
        _ requestable: R,
        value: R.Response? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try host.mockData(MockURLSession.mockData(
            requestable,
            value: value,
            response: response,
            error: error,
            noCallback: noCallback
        )), file: file, line: line)
    }

    func mockEncodedData<R: APIRequestable>(
        _ requestable: R,
        data: Data? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try host.mockData(MockURLSession.mockEncodedData(
            requestable,
            data: data,
            response: response,
            error: error,
            noCallback: noCallback
        )), file: file, line: line)
    }

    func mockDataRequest(
        _ request: URLRequest,
        data: Data? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try host.mockData(MockURLSession.mockData(
            request,
            data: data,
            response: response,
            error: error,
            noCallback: noCallback
        )), file: file, line: line)
    }

    func mockDownload(
        _ url: URL,
        data: URL? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoThrow(try host.mockDownload(MockURLSession.mockDownload(
            url,
            data: data,
            response: response,
            error: error
        )), file: file, line: line)
    }
}
