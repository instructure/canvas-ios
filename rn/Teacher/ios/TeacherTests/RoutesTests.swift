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
        router.route(to: route, from: UIViewController(), options: nil)
        wait(for: [expectation], timeout: 0.5)
        XCTAssertNotNil(userInfo)
        XCTAssertEqual(userInfo?["url"] as? String, route.url!.absoluteString)
        NotificationCenter.default.removeObserver(observer)
    }
}
