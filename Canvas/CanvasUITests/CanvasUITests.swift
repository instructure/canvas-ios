//
// Copyright (C) 2019-present Instructure, Inc.
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

import XCTest
import SwiftUITest

// Always recompute app to avoid stale testCase references
private var getApp: (() -> Driver)!
private var getTestCase: (() -> XCTestCase)!
var app: Driver { return getApp() }
var testCase: XCTestCase { return getTestCase() }

class CanvasUITests: XCTestCase {
    var application: XCUIApplication!

    override func setUp() {
        super.setUp()
        application = XCUIApplication()
        application.launchArguments.append("--ui-test")
        application.launch()

        getApp = {
            return DriverFactory.getXCUITestDriver(XCUIApplication(), testCase: self)
        }
        getTestCase = {
            return self
        }
    }
}
