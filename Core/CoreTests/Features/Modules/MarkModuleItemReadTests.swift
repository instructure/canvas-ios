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

import Combine
@testable import Core
import CoreData
import Foundation
@testable import TestsFoundation
import XCTest

class MarkModuleItemReadTests: CoreTestCase {
    func testRequest() {
        let markAsRead = MarkModuleItemRead(courseID: "1", moduleID: "2", moduleItemID: "3")
        XCTAssertEqual(markAsRead.request.courseID, "1")
        XCTAssertEqual(markAsRead.request.moduleID, "2")
        XCTAssertEqual(markAsRead.request.moduleItemID, "3")
        XCTAssertEqual(markAsRead.request.method, .post)
        XCTAssertEqual(markAsRead.request.path, "courses/1/modules/2/items/3/mark_read")
    }

    func testNotificationIsSentOnSuccess() {
        let expectation = XCTestExpectation(description: "notification sent")
        var subscriptions = Set<AnyCancellable>()

        let useCase = MarkModuleItemRead(courseID: "1", moduleID: "2", moduleItemID: "3")

        api.mock(useCase.request, value: APINoContent())

        NotificationCenter.default.publisher(for: .moduleItemRequirementCompleted)
            .sink { notification in
                guard let attributes = notification.object as? ModuleItemAttributes else {
                    XCTFail("Notification object should be ModuleItemAttributes")
                    return
                }

                XCTAssertEqual(attributes.courseID, "1")
                XCTAssertEqual(attributes.moduleID, "2")
                XCTAssertEqual(attributes.itemID, "3")

                expectation.fulfill()
            }
            .store(in: &subscriptions)

        useCase.makeRequest(environment: environment) { _, _, _ in }

        wait(for: [expectation], timeout: 1.0)
    }

    func testNotificationIsNotSentOnFailure() {
        let expectation = XCTestExpectation(description: "notification should not be sent")
        expectation.isInverted = true
        var subscriptions = Set<AnyCancellable>()

        let useCase = MarkModuleItemRead(courseID: "1", moduleID: "2", moduleItemID: "3")

        api.mock(useCase.request, error: NSError.instructureError("Test error"))

        NotificationCenter.default.publisher(for: .moduleItemRequirementCompleted)
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        useCase.makeRequest(environment: environment) { _, _, _ in }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWriteMethodDoesNothing() {
        let useCase = MarkModuleItemRead(courseID: "1", moduleID: "2", moduleItemID: "3")
        useCase.write(response: APINoContent(), urlResponse: nil, to: databaseClient)
    }
}
