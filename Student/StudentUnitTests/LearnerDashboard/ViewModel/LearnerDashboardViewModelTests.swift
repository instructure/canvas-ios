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

        XCTAssertEqual(testee.screenConfig.refreshable, true)
        XCTAssertEqual(testee.screenConfig.emptyPandaConfig.scene is SpacePanda, true)
        XCTAssertEqual(testee.screenConfig.emptyPandaConfig.title, expectedTitle)
    }

    func test_loadWidgets_whenNoWidgets_shouldSetStateToEmpty() {
        // WHEN
        interactor.loadWidgetsPublisher.send((fullWidth: [], grid: []))
        scheduler.advance()

        // THEN
        XCTAssertEqual(testee.state, .loading)
    }

    func test_loadWidgets_whenWidgetsExist_shouldSetStateToData() {
        let widget = FullWidthWidgetViewModel(config: WidgetConfig(id: .fullWidthWidget, order: 0, isVisible: true, settings: nil))

        // WHEN
        interactor.loadWidgetsPublisher.send((fullWidth: [widget], grid: []))
        scheduler.advance()

        // THEN
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.fullWidthWidgets.count, 1)
        XCTAssertEqual(testee.gridWidgets.count, 0)
    }

    func test_refresh_shouldComplete() {
        let widget = FullWidthWidgetViewModel(config: WidgetConfig(id: .fullWidthWidget, order: 0, isVisible: true, settings: nil))
        let expectation = expectation(description: "Refresh should complete")

        interactor.loadWidgetsPublisher.send((fullWidth: [widget], grid: []))
        scheduler.advance()

        // WHEN
        testee.refresh(ignoreCache: true) {
            expectation.fulfill()
        }
        scheduler.advance(by: 2.1)

        // THEN
        wait(for: [expectation], timeout: 3)
    }
}
