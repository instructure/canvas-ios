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
        var testee = ModulePublishInteractorLive(app: nil, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractorLive(app: .parent, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractorLive(app: .student, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractorLive(app: .teacher, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)

        ExperimentalFeature.teacherBulkPublish.isEnabled = true
        testee = ModulePublishInteractorLive(app: nil, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractorLive(app: .parent, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractorLive(app: .student, courseId: "")
        XCTAssertFalse(testee.isPublishActionAvailable)
        testee = ModulePublishInteractorLive(app: .teacher, courseId: "")
        XCTAssertTrue(testee.isPublishActionAvailable)
    }

    func testUpdatesItemPublishState() {
        let testee = ModulePublishInteractorLive(app: .teacher, courseId: "testCourseId")
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
        let testee = ModulePublishInteractorLive(app: .teacher, courseId: "testCourseId")
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

    func testChangeFilePublishState() {
        let testee = ModulePublishInteractorLive(app: .teacher, courseId: "testCourseId")
        let unlockAt = Date().addDays(1)
        let lockAt = unlockAt.addDays(2)
        let mockFileUpdateRequest = PutFileRequest(
            fileID: "testFileId",
            visibility: .courseMembers,
            availability: .scheduledAvailability,
            unlockAt: unlockAt,
            lockAt: lockAt
        )
        let mockModuleItemRefreshRequest = GetModuleItemRequest(
            courseID: "testCourseId",
            moduleID: "testModuleId",
            itemID: "testModuleItemId",
            include: [.content_details]
        )
        let fileUpdateMock = api.mock(mockFileUpdateRequest, value: .make())
        fileUpdateMock.suspend()
        api.mock(mockModuleItemRefreshRequest, value: .make())

        let expectation = expectation(description: "Publish finished")

        // WHEN
        let subscription = testee
            .changeFilePublishState(
                fileContext: .init(
                    fileId: "testFileId",
                    moduleId: "testModuleId",
                    moduleItemId: "testModuleItemId",
                    courseId: "testCourseId"
                ),
                filePermissions: .init(
                    unlockAt: unlockAt,
                    lockAt: lockAt,
                    availability: .scheduledAvailability,
                    visibility: .courseMembers
                )
            )
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    expectation.fulfill()
                }
            }, receiveValue: {})
        fileUpdateMock.resume()

        // THEN
        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

    func testGetFilePermission() {
        let testee = ModulePublishInteractorLive(app: .teacher, courseId: "testCourseId")
        let mockGetFileRequest = GetFileRequest(
            context: .course("testCourseId"),
            fileID: "testFileId",
            include: []
        )
        let unlockAt = Date().addDays(1)
        let lockAt = unlockAt.addDays(2)
        let getFileMock = api.mock(
            mockGetFileRequest,
            value: .make(
                id: "testFileId",
                unlock_at: unlockAt,
                locked: false,
                hidden: false,
                lock_at: lockAt,
                visibility_level: FileVisibility.institutionMembers.rawValue
            )
        )
        getFileMock.suspend()
        let finishExpectation = expectation(description: "Get operation finished")
        let valueExpectation = expectation(description: "Permission received")

        // WHEN
        let subscription = testee
            .getFilePermission(
                fileContext: .init(
                    fileId: "testFileId",
                    moduleId: "testModuleId",
                    moduleItemId: "testModuleItemId",
                    courseId: "testCourseId"
                )
            )
            .sink { completion in
                if case .finished = completion {
                    finishExpectation.fulfill()
                }
            } receiveValue: { permission in
                valueExpectation.fulfill()
                XCTAssertEqual(permission.availability, .scheduledAvailability)
                XCTAssertEqual(permission.visibility, .institutionMembers)
                XCTAssertEqual(permission.lockAt!.timeIntervalSince1970, lockAt.timeIntervalSince1970, accuracy: 1)
                XCTAssertEqual(permission.unlockAt!.timeIntervalSince1970, unlockAt.timeIntervalSince1970, accuracy: 1)
            }

        // THEN
        getFileMock.resume()
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
