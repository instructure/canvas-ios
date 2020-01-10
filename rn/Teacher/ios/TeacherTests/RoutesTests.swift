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
@testable import Teacher

class RoutesTests: XCTestCase {
    func testRouteSendsNotification() {
        let route = URLComponents(string: "https://canvas.instructure.com/api/v1/courses/1")!
        let expectation = self.expectation(description: "route notification")
        let name = NSNotification.Name("route")
        var userInfo: [AnyHashable: Any]?
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { note in
            userInfo = note.userInfo
            expectation.fulfill()
        }
        router.route(to: route, from: UIViewController(), options: .noOptions)
        wait(for: [expectation], timeout: 0.5)
        XCTAssertNotNil(userInfo)
        XCTAssertEqual(userInfo?["url"] as? String, route.url!.absoluteString)
        XCTAssertEqual(userInfo?["modal"] as? Bool, false)
        XCTAssertEqual(userInfo?["detail"] as? Bool, false)
        NotificationCenter.default.removeObserver(observer)
    }

    func testOptions() {
        let route = URLComponents(string: "https://canvas.instructure.com/api/v1/courses/1")!
        let expectation = self.expectation(description: "route notification")
        let name = NSNotification.Name("route")
        var userInfo: [AnyHashable: Any]?
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { note in
            userInfo = note.userInfo
            expectation.fulfill()
        }
        router.route(to: route, from: UIViewController(), options: .modal(detail: true))
        wait(for: [expectation], timeout: 0.5)
        XCTAssertNotNil(userInfo)
        XCTAssertEqual(userInfo?["url"] as? String, route.url!.absoluteString)
        XCTAssertEqual(userInfo?["modal"] as? Bool, true)
        XCTAssertEqual(userInfo?["detail"] as? Bool, true)
        NotificationCenter.default.removeObserver(observer)
    }
}
