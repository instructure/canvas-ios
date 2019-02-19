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

var app: XCUIApplication?

class StudentTest: XCTestCase {
    var host: TestHost {
        return unsafeBitCast(
            GREYHostApplicationDistantObject.sharedInstance,
            to: TestHost.self)
    }

    lazy var seedClient: SeedClient = {
        return SeedClient(host: host)
    }()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        if app == nil {
            app = XCUIApplication()

            var env = app!.launchEnvironment
            env["IS_UI_TEST"] = "TRUE"
            app!.launchEnvironment = env

            app!.launch()
        }
        host.reset()
    }

    func launch(_ route: String, as user: AuthUser) {
        host.logIn(domain: seedClient.baseURL.host!, token: user.token)
        show(route)
    }

    func show(_ route: String) {
        host.show(route)
    }

    func dismissKeyboard() {
        guard let app = app else {
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
        guard let image = app?.navigationBars.firstMatch.screenshot().image,
            let pixelData = image.cgImage?.dataProvider?.data,
            let data = CFDataGetBytePtr(pixelData) else {
            return nil
        }
        let red = UInt(data[0]), green = UInt(data[1]), blue = UInt(data[2]), alpha = UInt(data[3])
        let num = (alpha << 24) + (red << 16) + (green << 8) + blue
        return "#\(String(num, radix: 16))".replacingOccurrences(of: "#ff", with: "#")
    }

    func createUser() -> AuthUser {
        let user = seedClient.createUser()
        let token = getToken(user: user)
        return AuthUser(token: token, user: user)
    }

    func createTeacher(in course: APICourse) -> AuthUser {
        let user = seedClient.createTeacher(in: course)
        let token = getToken(user: user)
        return AuthUser(token: token, user: user)
    }

    func createStudent(in course: APICourse) -> AuthUser {
        let user = seedClient.createStudent(in: course)
        let token = getToken(user: user)
        return AuthUser(token: token, user: user)
    }

    func getToken(user: APIUser) -> String {
        let expectation = XCTestExpectation(description: "get token")
        var token: String!
        _ = seedClient.getToken(email: user.login_id!, password: "password") { tkn in
            token = tkn
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
        return token
    }

    func capturePhoto() {
        allowAccessToCamera()
        app!.buttons["PhotoCapture"].tap()
        let usePhoto = app!.buttons["Use Photo"]

        // Sometimes takes a few seconds to focus
        _ = usePhoto.waitForExistence(timeout: 10)
        usePhoto.tap()
    }

    func allowAccessToCamera() {
        let alert = app!.alerts["“Student” Would Like to Access the Camera"]
        if alert.exists {
            alert.buttons["OK"].tap()
        }
    }
}
