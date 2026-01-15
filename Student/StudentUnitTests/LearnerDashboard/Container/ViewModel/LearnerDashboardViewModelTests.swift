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

final class LearnerDashboardViewModelTests: XCTestCase {

    private var testee: LearnerDashboardViewModel!
    private var interactor: LearnerDashboardInteractorMock!
    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        scheduler = DispatchQueue.test
        interactor = LearnerDashboardInteractorMock()
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        scheduler = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_shouldLoadWidgets() {
        let fullWidthWidget = MockWidgetViewModel(
            id: .fullWidthWidget,
            isFullWidth: true
        )
        let gridWidget = MockWidgetViewModel(
            id: .widget1,
            isFullWidth: false
        )

        testee = LearnerDashboardViewModel(
            interactor: interactor,
            mainScheduler: scheduler.eraseToAnyScheduler()
        )
        interactor.loadWidgetsPublisher.send((
            fullWidth: [fullWidthWidget],
            grid: [gridWidget]
        ))
        scheduler.advance()

        XCTAssertEqual(testee.fullWidthWidgets.count, 1)
        XCTAssertEqual(testee.fullWidthWidgets.first?.id, .fullWidthWidget)
        XCTAssertEqual(testee.gridWidgets.count, 1)
        XCTAssertEqual(testee.gridWidgets.first?.id, .widget1)
    }

    // MARK: - Screen config

    func test_screenConfig_shouldBeConfiguredCorrectly() {
        testee = LearnerDashboardViewModel(
            interactor: interactor,
            mainScheduler: scheduler.eraseToAnyScheduler()
        )

        XCTAssertEqual(testee.screenConfig.refreshable, true)
        XCTAssertEqual(testee.screenConfig.showsScrollIndicators, false)
        XCTAssertEqual(testee.screenConfig.emptyPandaConfig.scene is SpacePanda, true)
        XCTAssertEqual(
            testee.screenConfig.emptyPandaConfig.title,
            String(localized: "Welcome to Canvas!", bundle: .student)
        )
    }

    // MARK: - State management

    func test_init_withNoWidgets_shouldKeepLoadingState() {
        testee = LearnerDashboardViewModel(
            interactor: interactor,
            mainScheduler: scheduler.eraseToAnyScheduler()
        )
        interactor.loadWidgetsPublisher.send((fullWidth: [], grid: []))
        scheduler.advance()

        XCTAssertEqual(testee.state, .loading)
    }

    func test_init_withWidgets_shouldSetDataState() {
        let widget = MockWidgetViewModel(id: .widget1, isFullWidth: false)

        testee = LearnerDashboardViewModel(
            interactor: interactor,
            mainScheduler: scheduler.eraseToAnyScheduler()
        )
        interactor.loadWidgetsPublisher.send((fullWidth: [], grid: [widget]))
        scheduler.advance()

        XCTAssertEqual(testee.state, .data)
    }

    // MARK: - Refresh

    func test_refresh_shouldCallRefreshOnAllWidgets() {
        let widget1 = MockWidgetViewModel(id: .widget1, isFullWidth: false)
        let widget2 = MockWidgetViewModel(id: .widget2, isFullWidth: false)
        let fullWidthWidget = MockWidgetViewModel(id: .fullWidthWidget, isFullWidth: true)

        testee = LearnerDashboardViewModel(
            interactor: interactor,
            mainScheduler: scheduler.eraseToAnyScheduler()
        )
        interactor.loadWidgetsPublisher.send((
            fullWidth: [fullWidthWidget],
            grid: [widget1, widget2]
        ))
        scheduler.advance()

        testee.refresh(ignoreCache: true)
        scheduler.advance()

        XCTAssertEqual(widget1.refreshCalled, true)
        XCTAssertEqual(widget1.refreshIgnoreCache, true)
        XCTAssertEqual(widget2.refreshCalled, true)
        XCTAssertEqual(widget2.refreshIgnoreCache, true)
        XCTAssertEqual(fullWidthWidget.refreshCalled, true)
        XCTAssertEqual(fullWidthWidget.refreshIgnoreCache, true)
    }

    func test_refresh_shouldCallCompletionWhenAllWidgetsFinish() {
        let widget = MockWidgetViewModel(id: .widget1, isFullWidth: false)

        testee = LearnerDashboardViewModel(
            interactor: interactor,
            mainScheduler: scheduler.eraseToAnyScheduler()
        )
        interactor.loadWidgetsPublisher.send((fullWidth: [], grid: [widget]))
        scheduler.advance()

        let expectation = expectation(description: "refresh completion")
        testee.refresh(ignoreCache: false) {
            expectation.fulfill()
        }
        scheduler.advance()

        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(widget.refreshCalled, true)
        XCTAssertEqual(widget.refreshIgnoreCache, false)
    }
}

private final class MockWidgetViewModel: LearnerWidgetViewModel {
    typealias ViewType = Never

    let id: LearnerDashboardWidgetIdentifier
    let config: WidgetConfig
    let isFullWidth: Bool
    let isEditable = false
    let state: InstUI.ScreenState = .data

    var refreshCalled = false
    var refreshIgnoreCache: Bool?

    init(id: LearnerDashboardWidgetIdentifier, isFullWidth: Bool) {
        self.id = id
        self.isFullWidth = isFullWidth
        self.config = WidgetConfig(id: id, order: 7, isVisible: true)
    }

    func makeView() -> Never {
        fatalError("Not implemented")
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        refreshCalled = true
        refreshIgnoreCache = ignoreCache
        return Just(()).eraseToAnyPublisher()
    }
}
