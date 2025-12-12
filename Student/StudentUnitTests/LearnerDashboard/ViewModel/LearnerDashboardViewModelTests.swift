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

import Combine
import CombineSchedulers
@testable import Core
@testable import Student
import XCTest

final class LearnerDashboardViewModelTests: StudentTestCase {
    private var interactor: LearnerDashboardInteractorMock!
    private var scheduler: TestSchedulerOf<DispatchQueue>!
    private var testee: LearnerDashboardViewModel!

    override func setUp() {
        super.setUp()
        interactor = LearnerDashboardInteractorMock()
        scheduler = DispatchQueue.test
        testee = LearnerDashboardViewModel(
            interactor: interactor,
            mainScheduler: scheduler.eraseToAnyScheduler()
        )
    }

    func test_initialState_shouldBeLoading() {
        XCTAssertEqual(testee.state, .loading)
    }

    func test_screenConfig() {
        let expectedTitle = String(localized: "Welcome to Canvas!", bundle: .student)

        XCTAssertTrue(testee.screenConfig.refreshable)
        XCTAssertTrue(testee.screenConfig.emptyPandaConfig.scene is SpacePanda)
        XCTAssertEqual(testee.screenConfig.emptyPandaConfig.title, expectedTitle)
    }

    func test_refresh_shouldSetStateToEmpty() {
        let expectation = expectation(description: "Refresh should complete")

        // WHEN
        testee.refresh(ignoreCache: true) {
            expectation.fulfill()
        }

        interactor.refreshPublisher.send(())
        interactor.refreshPublisher.send(completion: .finished)
        scheduler.advance()

        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(testee.state, .empty)
    }

    func test_refresh_whenIgnoreCacheIsTrue_shouldCallInteractorWithCorrectParameter() {
        let expectedIgnoreCache = true

        // WHEN
        testee.refresh(ignoreCache: expectedIgnoreCache)

        interactor.refreshPublisher.send(())
        interactor.refreshPublisher.send(completion: .finished)
        scheduler.advance()

        // THEN
        XCTAssertEqual(interactor.refreshIgnoreCacheValue, expectedIgnoreCache)
    }

    func test_refresh_whenIgnoreCacheIsFalse_shouldCallInteractorWithCorrectParameter() {
        let expectedIgnoreCache = false

        interactor.refreshPublisher.send(())
        interactor.refreshPublisher.send(completion: .finished)
        scheduler.advance()

        // WHEN
        testee.refresh(ignoreCache: expectedIgnoreCache)

        interactor.refreshPublisher.send(())
        interactor.refreshPublisher.send(completion: .finished)
        scheduler.advance()

        // THEN
        XCTAssertEqual(interactor.refreshIgnoreCacheValue, expectedIgnoreCache)
    }
}
