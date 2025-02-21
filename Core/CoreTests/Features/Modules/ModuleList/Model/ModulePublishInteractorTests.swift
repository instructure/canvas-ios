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
        var testee = ModulePublishInteractorLive(app: nil, courseId: "")
        XCTAssertEqual(testee.isPublishActionAvailable, false)
        testee = ModulePublishInteractorLive(app: .parent, courseId: "")
        XCTAssertEqual(testee.isPublishActionAvailable, false)
        testee = ModulePublishInteractorLive(app: .student, courseId: "")
        XCTAssertEqual(testee.isPublishActionAvailable, false)
        testee = ModulePublishInteractorLive(app: .teacher, courseId: "")
        XCTAssertEqual(testee.isPublishActionAvailable, true)
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
        waitForExpectations(timeout: 1)
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
        waitForExpectations(timeout: 1)
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
        waitForExpectations(timeout: 1)
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
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testBulkPublishUpdatesModulesBeingUpdatedList() {
        let testee = ModulePublishInteractorLive(app: .teacher, courseId: "testCourseId")
        let updatesReceived = expectation(description: "Module IDs being updated published")
        let subscription = testee
            .modulesUpdating
            .collect(3)
            .sink { updates in
                XCTAssertEqual(updates, [Set(), Set(["1", "2"]), Set()])
                updatesReceived.fulfill()
            }

        let testOperation = testee.bulkPublish(moduleIds: ["1", "2"], action: .publish(.onlyModules)).sink()
        waitForExpectations(timeout: 1)
        subscription.cancel()
        testOperation.cancel()
    }

    func testBulkPublishCancel() {
        let bulkPublishRequest = PutBulkPublishModulesRequest(
            courseId: "testCourseId",
            moduleIds: ["moduleId1", "moduleId2"],
            action: .publish(.modulesAndItems)
        )
        api.mock(
            bulkPublishRequest,
            value: .init(progress: .init(.init(progress: .init(id: "progressId"))))
        )
        let pollRequest = GetBulkPublishProgressRequest(modulePublishProgressId: "progressId")
        let pollRequestMock = api.mock(
            pollRequest,
            value: .init(completion: 0.0, workflow_state: "running")
        )
        // Simulate long progress by blocking the progress poll response
        pollRequestMock.suspend()
        let testee = ModulePublishInteractorLive(app: .teacher, courseId: "testCourseId")
        _ = testee.bulkPublish(moduleIds: ["moduleId1", "moduleId2"], action: .publish(.onlyModules))
        XCTAssertEqual(testee.modulesUpdating.value, Set(["moduleId1", "moduleId2"]))
        let cancelRequest = PostCancelBulkPublishRequest(progressId: "progressId")
        let cancelCalled = expectation(description: "Cancel called")
        api.mock(withData: cancelRequest) { _ in
            cancelCalled.fulfill()
            return (nil, nil, nil)
        }
        let modulesRefreshed = expectation(description: "Modules list refreshed")
        let moduleRefreshRequest = GetModulesRequest(courseID: "testCourseId")
        api.mock(moduleRefreshRequest) { _ in
            modulesRefreshed.fulfill()
            return (nil, nil, nil)
        }

        // WHEN
        testee.cancelBulkPublish(moduleIds: ["moduleId1", "moduleId2"], action: .publish(.onlyModules))

        // THEN
        drainMainQueue()
        XCTAssertTrue(testee.modulesUpdating.value.isEmpty)
        wait(for: [cancelCalled, modulesRefreshed], timeout: 1)
    }
}

class TestStatusUpdateTests: XCTestCase {

    func testModuleItemUpdates() {
        var testee: Subscribers.Completion<Error> = .finished
        XCTAssertEqual(testee.publishStatusUpdateText(for: .publish, isAllModules: false), "Item Published")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .unpublish, isAllModules: false), "Item Unpublished")
        testee = .failure(NSError.internalError())
        XCTAssertEqual(testee.publishStatusUpdateText(for: .publish, isAllModules: false), "Failed To Publish Item")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .unpublish, isAllModules: false), "Failed To Unpublish Item")

        testee = .finished
        XCTAssertEqual(testee.publishStatusUpdateText(for: .publish(.onlyModules), isAllModules: false), "Only Module published")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .unpublish(.onlyModules), isAllModules: false), "Only Module unpublished")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .publish(.onlyModules), isAllModules: true), "Only Modules published")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .unpublish(.onlyModules), isAllModules: true), "Only Modules unpublished")
        testee = .failure(NSError.internalError())
        XCTAssertEqual(testee.publishStatusUpdateText(for: .publish(.onlyModules), isAllModules: false), "Failed to publish only Module")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .unpublish(.onlyModules), isAllModules: false), "Failed to unpublish only Module")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .publish(.onlyModules), isAllModules: true), "Failed to publish only Modules")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .unpublish(.onlyModules), isAllModules: true), "Failed to unpublish only Modules")

        testee = .finished
        XCTAssertEqual(testee.publishStatusUpdateText(for: .publish(.modulesAndItems), isAllModules: false), "Module and all Items published")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .unpublish(.modulesAndItems), isAllModules: false), "Module and all Items unpublished")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .publish(.modulesAndItems), isAllModules: true), "All Modules and all Items published")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .unpublish(.modulesAndItems), isAllModules: true), "All Modules and all Items unpublished")
        testee = .failure(NSError.internalError())
        XCTAssertEqual(testee.publishStatusUpdateText(for: .publish(.modulesAndItems), isAllModules: false), "Failed to publish Module and all Items")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .unpublish(.modulesAndItems), isAllModules: false), "Failed to unpublish Module and all Items")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .publish(.modulesAndItems), isAllModules: true), "Failed to publish all Modules and all Items")
        XCTAssertEqual(testee.publishStatusUpdateText(for: .unpublish(.modulesAndItems), isAllModules: true), "Failed to unpublish all Modules and all Items")
    }
}
