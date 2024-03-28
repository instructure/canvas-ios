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
import CombineSchedulers
import XCTest

class ModuleFilePermissionEditorViewModelTests: CoreTestCase {
    private let fileContext = ModulePublishInteractorLive.FileContext(
        fileId: "testFileId",
        moduleId: "testModuleId",
        moduleItemId: "testModuleItemId",
        courseId: "testCourseId"
    )

    func testLoadInitialStateFailure() {
        let mockInteractor = MockModulePublishInteractor()
        mockInteractor.getFilePermissionResult = .failure(NSError.internalError())

        let testee = ModuleFilePermissionEditorViewModel(
            fileContext: fileContext,
            interactor: mockInteractor,
            router: router,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.state, .error)
        XCTAssertEqual(mockInteractor.receivedFileContextForGetFilePermission, fileContext)
    }

    func testLoadInitialStateSucceeds() {
        let unlockAt = Date()
        let lockAt = Date()
        let mockInteractor = MockModulePublishInteractor()
        mockInteractor.getFilePermissionResult = .success(
            .init(
                unlockAt: unlockAt,
                lockAt: lockAt,
                availability: .scheduledAvailability,
                visibility: .institutionMembers
            )
        )

        let testee = ModuleFilePermissionEditorViewModel(
            fileContext: fileContext,
            interactor: mockInteractor,
            router: router,
            scheduler: .immediate
        )

        XCTAssertEqual(mockInteractor.receivedFileContextForGetFilePermission, fileContext)
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.availableFrom, unlockAt)
        XCTAssertEqual(testee.availableUntil, lockAt)
        XCTAssertEqual(testee.visibility, .institutionMembers)
        XCTAssertEqual(testee.availability, .scheduledAvailability)
        XCTAssertTrue(testee.isDoneButtonActive)
        XCTAssertTrue(testee.isScheduleDateSectionVisible)
        XCTAssertEqual(
            testee.defaultFromDate.timeIntervalSince1970,
            unlockAt.addDays(-1).timeIntervalSince1970,
            accuracy: 0.1
        )
        XCTAssertEqual(
            testee.defaultUntilDate.timeIntervalSince1970,
            unlockAt.addDays(1).timeIntervalSince1970,
            accuracy: 0.1
        )
        XCTAssertFalse(testee.isUploading)
    }

    func testSuccessfulFilePermissionChange() {
        let mockInteractor = MockModulePublishInteractor()
        mockInteractor.getFilePermissionResult = .success(
            .init(
                unlockAt: nil,
                lockAt: nil,
                availability: .hidden,
                visibility: .institutionMembers
            )
        )
        let testScheduler = DispatchQueue.test
        let testee = ModuleFilePermissionEditorViewModel(
            fileContext: fileContext,
            interactor: mockInteractor,
            router: router,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
        let unlockAt = Date()
        let lockAt = Date()
        mockInteractor.changeFilePublishStateResult = .success(())
        let viewHost = UIViewController()

        // WHEN
        testee.availableFromDidSelect.send(unlockAt)
        testee.availableUntilDidSelect.send(lockAt)
        testee.availabilityDidSelect.send(.scheduledAvailability)
        testee.visibilityDidSelect.send(.inheritCourse)
        testee.doneDidPress.send(viewHost)

        // THEN
        XCTAssertEqual(mockInteractor.receivedFileContextForChangeFilePublishState, fileContext)
        XCTAssertEqual(mockInteractor.receivedFilePermissionsForChangeFilePublishState,
                       .init(
                           unlockAt: unlockAt,
                           lockAt: lockAt,
                           availability: .scheduledAvailability,
                           visibility: .inheritCourse
                       )
        )
        XCTAssertTrue(testee.isUploading)
        XCTAssertFalse(testee.isDoneButtonActive)
        testScheduler.advance()
        XCTAssertEqual(router.dismissed, viewHost)
    }

    func testFailedFilePermissionChange() {
        let mockInteractor = MockModulePublishInteractor()
        mockInteractor.getFilePermissionResult = .success(
            .init(
                unlockAt: nil,
                lockAt: nil,
                availability: .hidden,
                visibility: .institutionMembers
            )
        )
        let testScheduler = DispatchQueue.test
        let testee = ModuleFilePermissionEditorViewModel(
            fileContext: fileContext,
            interactor: mockInteractor,
            router: router,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
        let unlockAt = Date()
        let lockAt = Date()
        mockInteractor.changeFilePublishStateResult = .failure(NSError.internalError())
        let viewHost = UIViewController()

        // WHEN
        testee.availableFromDidSelect.send(unlockAt)
        testee.availableUntilDidSelect.send(lockAt)
        testee.availabilityDidSelect.send(.scheduledAvailability)
        testee.visibilityDidSelect.send(.inheritCourse)
        testee.doneDidPress.send(viewHost)

        // THEN
        XCTAssertEqual(mockInteractor.receivedFileContextForChangeFilePublishState, fileContext)
        XCTAssertEqual(mockInteractor.receivedFilePermissionsForChangeFilePublishState,
                       .init(
                           unlockAt: unlockAt,
                           lockAt: lockAt,
                           availability: .scheduledAvailability,
                           visibility: .inheritCourse
                       )
        )
        XCTAssertTrue(testee.isUploading)
        XCTAssertFalse(testee.isDoneButtonActive)
        testScheduler.advance()
        XCTAssertFalse(testee.isUploading)
        XCTAssertTrue(testee.isDoneButtonActive)
        XCTAssertTrue(testee.showError)
    }
}

class MockModulePublishInteractor: ModulePublishInteractor {
    var isPublishActionAvailable = false
    let moduleItemsUpdating = CurrentValueSubject<Set<String>, Never>(Set())
    let modulesUpdating = CurrentValueSubject<Set<String>, Never>(Set())
    let statusUpdates = PassthroughSubject<String, Never>()

    func changeItemPublishedState(
        moduleId: String,
        moduleItemId: String,
        action: ModulePublishAction
    ) {}

    private(set) var receivedFileContextForChangeFilePublishState: ModulePublishInteractorLive.FileContext?
    private(set) var receivedFilePermissionsForChangeFilePublishState: ModulePublishInteractorLive.FilePermission?
    var changeFilePublishStateResult: Result<Void, Error>?

    func changeFilePublishState(
        fileContext: ModulePublishInteractorLive.FileContext,
        filePermissions: ModulePublishInteractorLive.FilePermission
    ) -> AnyPublisher<Void, Error> {
        receivedFileContextForChangeFilePublishState = fileContext
        receivedFilePermissionsForChangeFilePublishState = filePermissions
        return changeFilePublishStateResult!
            .publisher
            .eraseToAnyPublisher()
    }

    private(set) var receivedFileContextForGetFilePermission: ModulePublishInteractorLive.FileContext?
    var getFilePermissionResult: Result<ModulePublishInteractorLive.FilePermission, Error>?

    func getFilePermission(
        fileContext: ModulePublishInteractorLive.FileContext
    ) -> AnyPublisher<ModulePublishInteractorLive.FilePermission, Error> {
        receivedFileContextForGetFilePermission = fileContext
        return getFilePermissionResult!
            .publisher
            .eraseToAnyPublisher()
    }

    var bulkPublishResult: AnyPublisher<BulkPublishInteractor.PublishProgress, Error>?
    func bulkPublish(
        moduleIds: [String],
        action: ModulePublishAction
    ) -> AnyPublisher<BulkPublishInteractor.PublishProgress, Error> {
        bulkPublishResult!
    }

    var cancelledBulkPublish: (moduleIds: [String], action: ModulePublishAction)?
    func cancelBulkPublish(moduleIds: [String], action: ModulePublishAction) {
        cancelledBulkPublish = (moduleIds: moduleIds, action: action)
    }
}
