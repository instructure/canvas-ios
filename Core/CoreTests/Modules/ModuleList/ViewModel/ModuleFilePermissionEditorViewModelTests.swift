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

class ModuleFilePermissionEditorViewModelTests: CoreTestCase {
    private let fileContext = ModulePublishInteractorLive.FileContext(
        fileId: "testFileId",
        moduleId: "testModuleId",
        moduleItemId: "testModuleItemId",
        courseId: "testCourseId"
    )

    func testLoadInitialStateFailure() {
        let mockInteractor = MockModulePublishInteractor()
        mockInteractor.mockedGetFilePermissionResult = .failure(NSError.internalError())
        mockInteractor.expectedFileContextForGetFilePermission = fileContext

        let testee = ModuleFilePermissionEditorViewModel(
            fileContext: fileContext,
            interactor: mockInteractor,
            router: router,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.state, .error)
    }

    func testLoadInitialStateSucceeds() {
        let unlockAt = Date()
        let lockAt = Date()
        let mockInteractor = MockModulePublishInteractor()
        mockInteractor.mockedGetFilePermissionResult = .success(
            .init(
                unlockAt: unlockAt,
                lockAt: lockAt,
                availability: .scheduledAvailability,
                visibility: .institutionMembers
            )
        )
        mockInteractor.expectedFileContextForGetFilePermission = fileContext

        let testee = ModuleFilePermissionEditorViewModel(
            fileContext: fileContext,
            interactor: mockInteractor,
            router: router,
            scheduler: .immediate
        )

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.availableFrom, unlockAt)
        XCTAssertEqual(testee.availableUntil, lockAt)
        XCTAssertEqual(testee.visibility, .institutionMembers)
        XCTAssertEqual(testee.availability, .scheduledAvailability)
        XCTAssertTrue(testee.isDoneButtonActive)
        XCTAssertTrue(testee.isScheduleDateSectionVisible)
        XCTAssertEqual(testee.defaultFromDate, unlockAt.addDays(-1))
        XCTAssertEqual(testee.defaultUntilDate, unlockAt.addDays(1))
        XCTAssertFalse(testee.isUploading)
    }
}

private class MockModulePublishInteractor: ModulePublishInteractor {
    var isPublishActionAvailable = false
    let moduleItemsUpdating = CurrentValueSubject<Set<String>, Never>(Set())
    let statusUpdates = PassthroughSubject<String, Never>()

    func changeItemPublishedState(
        moduleId: String,
        moduleItemId: String,
        action: PutModuleItemPublishRequest.Action
    ) {}

    var expectedFileContextForChangeFilePublishState: ModulePublishInteractorLive.FileContext?
    var expectedFilePermissionsForChangeFilePublishState: ModulePublishInteractorLive.FilePermission?
    var mockedChangeFilePublishStateResult: Result<Void, Error>?

    func changeFilePublishState(
        fileContext: ModulePublishInteractorLive.FileContext,
        filePermissions: ModulePublishInteractorLive.FilePermission
    ) -> AnyPublisher<Void, Error> {
        XCTAssertEqual(expectedFileContextForChangeFilePublishState, fileContext)
        XCTAssertEqual(expectedFilePermissionsForChangeFilePublishState, filePermissions)
        return mockedChangeFilePublishStateResult!
            .publisher
            .eraseToAnyPublisher()
    }

    var expectedFileContextForGetFilePermission: ModulePublishInteractorLive.FileContext?
    var mockedGetFilePermissionResult: Result<ModulePublishInteractorLive.FilePermission, Error>?

    func getFilePermission(
        fileContext: ModulePublishInteractorLive.FileContext
    ) -> AnyPublisher<ModulePublishInteractorLive.FilePermission, Error> {
        XCTAssertEqual(expectedFileContextForGetFilePermission, fileContext)

        return mockedGetFilePermissionResult!
            .publisher
            .eraseToAnyPublisher()
    }
}
