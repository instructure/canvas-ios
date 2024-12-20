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

import XCTest
import Foundation
@testable import Core

class NotificationExtensionTests: XCTestCase {
    func testPostModuleItemCompletedRequirement() {
        let expectation = XCTestExpectation(description: "notification")
        let token = NotificationCenter.default.addObserver(forName: .CompletedModuleItemRequirement, object: nil, queue: nil) { notification in
            XCTAssertEqual(notification.userInfo?["requirement"] as? ModuleItemCompletionRequirement, .submit)
            XCTAssertEqual(notification.userInfo?["moduleItem"] as? ModuleItemType, .assignment("2"))
            XCTAssertEqual(notification.userInfo?["courseID"] as? String, "1")
            expectation.fulfill()
        }
        NotificationCenter.default.post(moduleItem: .assignment("2"), completedRequirement: .submit, courseID: "1")
        wait(for: [expectation], timeout: 0.5)
        NotificationCenter.default.removeObserver(token)
    }
}
