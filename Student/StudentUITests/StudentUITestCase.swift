//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
        mockDownload(URL(string: ".")!) // Use only mock data
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
