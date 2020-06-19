//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import Core
@testable import Teacher
@testable import CanvasCore

class RoutesTests: XCTestCase {
    let route = URLComponents(string: "https://canvas.instructure.com/api/v1/courses/1")!

    func userInfoFromRoute(options: RouteOptions) -> [AnyHashable: Any]? {
        let expectation = self.expectation(description: "route notification")
        let name = NSNotification.Name("route")
        var userInfo: [AnyHashable: Any]?
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { note in
            userInfo = note.userInfo
            expectation.fulfill()
        }
        router.route(to: route, from: UIViewController(), options: options)
        wait(for: [expectation], timeout: 0.5)
        NotificationCenter.default.removeObserver(observer)
        XCTAssertNotNil(userInfo)
        return userInfo
    }

    func testRouteSendsNotification() {
        let userInfo = userInfoFromRoute(options: .noOptions)
        XCTAssertEqual(userInfo?["url"] as? String, route.url!.absoluteString)
        XCTAssertEqual(userInfo?["modal"] as? Bool, false)
        XCTAssertEqual(userInfo?["detail"] as? Bool, false)
    }

    func testModalOption() {
        let userInfo = userInfoFromRoute(options: .modal())
        XCTAssertEqual(userInfo?["url"] as? String, route.url!.absoluteString)
        XCTAssertEqual(userInfo?["modal"] as? Bool, true)
        XCTAssertEqual(userInfo?["detail"] as? Bool, false)
    }

    func testDetailOption() {
        let userInfo = userInfoFromRoute(options: .detail)
        XCTAssertEqual(userInfo?["url"] as? String, route.url!.absoluteString)
        XCTAssertEqual(userInfo?["modal"] as? Bool, false)
        XCTAssertEqual(userInfo?["detail"] as? Bool, true)
    }

    func testMatch() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.registerNativeRoutes()
        HelmManager.shared.registerRoute("/courses/:courseID/pages/:url")
        HelmManager.shared.registerRoute("/courses/:courseID/assignments/:assignmentID")
        XCTAssert(router.match("/courses/1/pages/page-1") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/assignments/2") is HelmViewController)
    }
}
