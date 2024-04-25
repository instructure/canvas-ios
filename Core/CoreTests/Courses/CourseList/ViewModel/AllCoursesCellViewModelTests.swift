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
import TestsFoundation

class AllCoursesCellViewModelTests: CoreTestCase {
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
        let testee = AllCoursesCellViewModel(item: .course(.make(courseId: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router)

        // THEN
        XCTAssertFalse(testee.isOfflineIndicatorVisible)
    }

    func testOfflineIndicatorVisibileWhenCourseIsSelectedForOfflineMode() {
        // GIVEN
        sessionDefaults.offlineSyncSelections = ["courses/1"]

        // WHEN
        let testee = AllCoursesCellViewModel(item: .course(.make(courseId: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router)
        // THEN
        XCTAssertTrue(testee.isOfflineIndicatorVisible)
    }

    func testOfflineIndicatorHiddenForGroups() {
        // WHEN
        let testee = AllCoursesCellViewModel(item: .group(.make(id: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router)
        // THEN
        XCTAssertFalse(testee.isOfflineIndicatorVisible)
    }

    func testCourseFavoriteStarVisibility() {
        // GIVEN
        let testee = AllCoursesCellViewModel(item: .course(.make(courseId: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(false)

        // THEN
        XCTAssertFalse(testee.isFavoriteStarDisabled)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(true)

        // THEN
        XCTAssertTrue(testee.isFavoriteStarDisabled)
    }

    func testGroupFavoriteStarVisibility() {
        // GIVEN
        let testee = AllCoursesCellViewModel(item: .group(.make(id: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router)

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
        let testee = AllCoursesCellViewModel(item: .course(.make(courseId: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router,
                                             scheduler: .immediate)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(false)

        // THEN
        XCTAssertFalse(testee.isCellDisabled)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(true)

        // THEN
        XCTAssertFalse(testee.isCellDisabled)
    }

    func testGroupEnabledStatesWhenOffline() {
        // GIVEN
        let testee = AllCoursesCellViewModel(item: .group(.make(id: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router,
                                             scheduler: .immediate)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(false)

        // THEN
        XCTAssertFalse(testee.isCellDisabled)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(true)

        // THEN
        XCTAssertTrue(testee.isCellDisabled)
    }

    func testCourseEnabledStatesWhenCourseNotAvailableInOffline() {
        // GIVEN
        sessionDefaults.offlineSyncSelections = []
        let testee = AllCoursesCellViewModel(item: .course(.make(courseId: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router,
                                             scheduler: .immediate)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(false)

        // THEN
        XCTAssertFalse(testee.isCellDisabled)

        // WHEN
        mockOfflineModeInteractor.mockIsInOfflineMode.accept(true)

        // THEN
        XCTAssertTrue(testee.isCellDisabled)
    }

    func testOfflineAvailableCellAccessbilityLabelText() {
        // GIVEN
        sessionDefaults.offlineSyncSelections = ["courses/1"]
        let testee = AllCoursesCellViewModel(item: .course(.make(courseId: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router,
                                             scheduler: .immediate)

        XCTAssertEqual(testee.cellAccessibilityLabelText, "course-1, , Available offline")
    }

    func testOfflineUnavailableCellAccessbilityLabelText() {
        // GIVEN
        sessionDefaults.offlineSyncSelections = []
        let testee = AllCoursesCellViewModel(item: .course(.make(courseId: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router,
                                             scheduler: .immediate)

        XCTAssertEqual(testee.cellAccessibilityLabelText, "course-1, ")
    }

    func testFavoritButtonAccessilibtyText() {
        let testee = AllCoursesCellViewModel(item: .course(.make(courseId: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router,
                                             scheduler: .immediate)

        XCTAssertEqual(testee.favoriteButtonAccessibilityText, String(localized: "Favorite", bundle: .core))
    }

    func testDetailsRoute() {
        let testee = AllCoursesCellViewModel(item: .course(.make(courseId: "1")),
                                             offlineModeInteractor: mockOfflineModeInteractor,
                                             sessionDefaults: sessionDefaults,
                                             app: environment.app,
                                             router: environment.router,
                                             scheduler: .immediate)

        testee.cellDidTap.accept((WeakViewController()))

        let testRouter = environment.router as! TestRouter
        XCTAssertEqual(testRouter.calls.count, 1)
    }
}
