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

class MarkModuleItemDoneTests: CoreTestCase {
    func testRequest() {
        let markAsDone = MarkModuleItemDone(courseID: "1", moduleID: "2", moduleItemID: "3", done: true)
        XCTAssertEqual(markAsDone.request.courseID, "1")
        XCTAssertEqual(markAsDone.request.moduleID, "2")
        XCTAssertEqual(markAsDone.request.moduleItemID, "3")
        XCTAssertEqual(markAsDone.request.done, true)
        XCTAssertEqual(markAsDone.request.method, .put)
        XCTAssertEqual(markAsDone.request.path, "courses/1/modules/2/items/3/done")

        let markAsNotDone = MarkModuleItemDone(courseID: "1", moduleID: "2", moduleItemID: "3", done: false)
        XCTAssertEqual(markAsNotDone.request.method, .delete)
        XCTAssertEqual(markAsNotDone.request.path, "courses/1/modules/2/items/3/done")
    }

    func testNotificationIsSentOnSuccess() {
        let expectation = XCTestExpectation(description: "notification sent")
        var subscriptions = Set<AnyCancellable>()

        let useCase = MarkModuleItemDone(courseID: "1", moduleID: "2", moduleItemID: "3", done: true)

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

        let useCase = MarkModuleItemDone(courseID: "1", moduleID: "2", moduleItemID: "3", done: true)

        api.mock(useCase.request, error: NSError.instructureError("Test error"))

        NotificationCenter.default.publisher(for: .moduleItemRequirementCompleted)
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        useCase.makeRequest(environment: environment) { _, _, _ in }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWriteMethodDoesNothing() {
        let useCase = MarkModuleItemDone(courseID: "1", moduleID: "2", moduleItemID: "3", done: true)
        useCase.write(response: APINoContent(), urlResponse: nil, to: databaseClient)
    }
}
