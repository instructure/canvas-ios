//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import XCTest

class CourseListCellOfflineStateViewModelTests: XCTestCase {
    private var sessionDefaults = SessionDefaults.fallback
    private let mockOfflineModeInteractor = OfflineModeInteractorMock()

    override func setUp() {
        super.setUp()
        sessionDefaults.reset()
    }

    override func tearDown() {
        sessionDefaults.reset()
        super.tearDown()
    }

    func testOfflineIndicatorHiddenWhenCourseNotSelectedForOfflineMode() {
        // GIVEN
        sessionDefaults.offlineSyncSelections = []

        // WHEN
        let testee = CourseListCellOfflineStateViewModel(courseId: "1",
                                                         offlineModeInteractor: mockOfflineModeInteractor,
                                                         sessionDefaults: sessionDefaults)

        // THEN
        XCTAssertFalse(testee.isOfflineIndicatorVisible)
    }

    func testOfflineIndicatorVisibileWhenCourseIsSelectedForOfflineMode() {
        // GIVEN
        sessionDefaults.offlineSyncSelections = ["courses/1"]

        // WHEN
        let testee = CourseListCellOfflineStateViewModel(courseId: "1",
                                                     offlineModeInteractor: mockOfflineModeInteractor,
                                                     sessionDefaults: sessionDefaults)
        // THEN
        XCTAssertTrue(testee.isOfflineIndicatorVisible)
    }

    func testFavoriteStarVisibility() {
        // GIVEN
        let testee = CourseListCellOfflineStateViewModel(courseId: "1",
                                                     offlineModeInteractor: mockOfflineModeInteractor,
                                                     sessionDefaults: sessionDefaults)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(false)

        // THEN
        XCTAssertFalse(testee.isFavoriteStarDisabled)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(true)

        // THEN
        XCTAssertTrue(testee.isFavoriteStarDisabled)
    }

    func testCourseEnabledStatesWhenCourseIsAvailableInOffline() {
        // GIVEN
        sessionDefaults.offlineSyncSelections = ["courses/1"]
        let testee = CourseListCellOfflineStateViewModel(courseId: "1",
                                                     offlineModeInteractor: mockOfflineModeInteractor,
                                                     sessionDefaults: sessionDefaults)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(false)

        // THEN
        XCTAssertTrue(testee.isCourseEnabled)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(true)

        // THEN
        XCTAssertTrue(testee.isCourseEnabled)
    }

    func testCourseEnabledStatesWhenCourseNotAvailableInOffline() {
        // GIVEN
        sessionDefaults.offlineSyncSelections = []
        let testee = CourseListCellOfflineStateViewModel(courseId: "1",
                                                     offlineModeInteractor: mockOfflineModeInteractor,
                                                     sessionDefaults: sessionDefaults)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(false)

        // THEN
        XCTAssertTrue(testee.isCourseEnabled)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(true)

        // THEN
        XCTAssertFalse(testee.isCourseEnabled)
    }
}
