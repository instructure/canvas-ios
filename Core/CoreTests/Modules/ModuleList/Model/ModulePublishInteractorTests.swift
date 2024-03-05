//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import Combine
import XCTest

class ModulePublishInteractorTests: CoreTestCase {

    func testPublishAvailability() {
        ExperimentalFeature.teacherBulkPublish.isEnabled = false
        var testee = ModulePublishInteractor(app: nil, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractor(app: .parent, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractor(app: .student, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractor(app: .teacher, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)

        ExperimentalFeature.teacherBulkPublish.isEnabled = true
        testee = ModulePublishInteractor(app: nil, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractor(app: .parent, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractor(app: .student, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractor(app: .teacher, courseId: "")
        XCTAssertTrue(testee.isPublishActionAvailable)
    }

    func testUpdatesItemPublishState() {
        let testee = ModulePublishInteractor(app: .teacher, courseId: "testCourseId")
        let itemUpdateExpectation = expectation(description: "Item updates received")
        let subscription = testee
            .moduleItemsUpdating
            .print()
            .dropFirst()
            .prefix(2)
            .collect()
            .sink { updates in
                itemUpdateExpectation.fulfill()
                XCTAssertEqual(updates, [Set(["testModuleItemId"]), Set()])
            }

        // WHEN
        testee.changeItemPublishedState(moduleId: "testModuleId",
                                        moduleItemId: "testModuleItemId",
                                        action: .publish)

        // THEN
        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

    func testSendsStatusUpdateMessagesOnItemPublishing() {
        let testee = ModulePublishInteractor(app: .teacher, courseId: "testCourseId")
        let expectation = expectation(description: "Published update received")
        let subscription = testee
            .statusUpdates
            .sink { update in
                expectation.fulfill()
                XCTAssertEqual(update, "Item Published")
            }

        // WHEN
        testee.changeItemPublishedState(
            moduleId: "1",
            moduleItemId: "2",
            action: .publish
        )

        // THEN
        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }
}

class TestStatusUpdateTests: XCTestCase {

    func testModuleItemUpdates() {
        var testee: Subscribers.Completion<Error> = .finished
        XCTAssertEqual(testee.moduleItemStatusUpdateText(for: .publish), "Item Published")

        testee = .finished
        XCTAssertEqual(testee.moduleItemStatusUpdateText(for: .unpublish), "Item Unpublished")

        testee = .failure(NSError.internalError())
        XCTAssertEqual(testee.moduleItemStatusUpdateText(for: .publish), "Failed To Publish Item")

        testee = .failure(NSError.internalError())
        XCTAssertEqual(testee.moduleItemStatusUpdateText(for: .unpublish), "Failed To Unpublish Item")
    }
}
