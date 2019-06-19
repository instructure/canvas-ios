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
@testable import Core
@testable import TestsFoundation

class StudentUITestCase: UITestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        if app.state != .runningForeground {
            app.launchEnvironment["IS_UI_TEST"] = "TRUE"
            app.launch()
        }
        reset()
    }

    func navBarColorHex() -> String? {
        let image = app.navigationBars.firstMatch.screenshot().image
        guard let pixelData = image.cgImage?.dataProvider?.data,
            let data = CFDataGetBytePtr(pixelData) else {
            return nil
        }
        let red = UInt(data[0]), green = UInt(data[1]), blue = UInt(data[2]), alpha = UInt(data[3])
        let num = (alpha << 24) + (red << 16) + (green << 8) + blue
        return "#\(String(num, radix: 16))".replacingOccurrences(of: "#ff", with: "#")
    }

    func capturePhoto() {
        allowAccessToCamera()
        app.buttons["PhotoCapture"].tap()
        let usePhoto = app.buttons["Use Photo"]

        // Sometimes takes a few seconds to focus
        _ = usePhoto.waitForExistence(timeout: 10)
        usePhoto.tap()
    }

    func allowAccessToCamera() {
        let alert = app.alerts["“Student” Would Like to Access the Camera"]
        if alert.exists {
            alert.buttons["OK"].tap()
        }
    }

    func allowAccessToMicrophone(block: () -> Void) {
        let alertHandler = addUIInterruptionMonitor(withDescription: "Permission Alert") { (alert) -> Bool in
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }
        block()
        app.swipeUp()
        removeUIInterruptionMonitor(alertHandler)
    }
}
