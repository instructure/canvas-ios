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
@testable import Core
@testable import Student
import XCTest

final class LearnerDashboardInteractorLiveTests: StudentTestCase {

    private var testee: LearnerDashboardInteractorLive!
    private var userDefaults: SessionDefaults!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        userDefaults = SessionDefaults(sessionID: "test-session")
        subscriptions = []
    }

    override func tearDown() {
        userDefaults.reset()
        userDefaults = nil
        testee = nil
        subscriptions = nil
        super.tearDown()
    }

    // MARK: - Load widgets with no saved configs

    func test_loadWidgets_withNoSavedConfigs_shouldUseDefaultConfigs() {
        testee = LearnerDashboardInteractorLive(
            userDefaults: userDefaults,
            widgetViewModelFactory: makeViewModelFactory()
        )

        let expectation = expectation(description: "loadWidgets")
        var receivedFullWidth: [any LearnerWidgetViewModel]?
        var receivedGrid: [any LearnerWidgetViewModel]?

        testee.loadWidgets()
            .sink { result in
                receivedFullWidth = result.fullWidth
                receivedGrid = result.grid
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(receivedFullWidth?.count, 1)
        XCTAssertEqual(receivedFullWidth?.first?.id, .fullWidthWidget)
        XCTAssertEqual(receivedGrid?.count, 3)
        XCTAssertEqual(receivedGrid?[0].id, .widget1)
        XCTAssertEqual(receivedGrid?[1].id, .widget3)
        XCTAssertEqual(receivedGrid?[2].id, .widget2)
    }

    // MARK: - Load widgets with saved configs

    func test_loadWidgets_withSavedConfigs_shouldFilterVisibleAndSort() {
        userDefaults.learnerDashboardWidgetConfigs = [
            WidgetConfig(id: .widget3, order: 5, isVisible: true),
            WidgetConfig(id: .widget1, order: 20, isVisible: false),
            WidgetConfig(id: .widget2, order: 10, isVisible: true)
        ]
        testee = LearnerDashboardInteractorLive(
            userDefaults: userDefaults,
            widgetViewModelFactory: makeViewModelFactory()
        )

        let expectation = expectation(description: "loadWidgets")
        var receivedFullWidth: [any LearnerWidgetViewModel]?
        var receivedGrid: [any LearnerWidgetViewModel]?

        testee.loadWidgets()
            .sink { result in
                receivedFullWidth = result.fullWidth
                receivedGrid = result.grid
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(receivedFullWidth?.count, 0)
        XCTAssertEqual(receivedGrid?.count, 2)
        XCTAssertEqual(receivedGrid?[0].id, .widget3)
        XCTAssertEqual(receivedGrid?[1].id, .widget2)
    }

    func test_loadWidgets_shouldSeparateFullWidthFromGridWidgets() {
        userDefaults.learnerDashboardWidgetConfigs = [
            WidgetConfig(id: .widget1, order: 20, isVisible: true),
            WidgetConfig(id: .fullWidthWidget, order: 5, isVisible: true),
            WidgetConfig(id: .widget2, order: 10, isVisible: true)
        ]
        testee = LearnerDashboardInteractorLive(
            userDefaults: userDefaults,
            widgetViewModelFactory: makeViewModelFactory()
        )

        let expectation = expectation(description: "loadWidgets")
        var receivedFullWidth: [any LearnerWidgetViewModel]?
        var receivedGrid: [any LearnerWidgetViewModel]?

        testee.loadWidgets()
            .sink { result in
                receivedFullWidth = result.fullWidth
                receivedGrid = result.grid
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(receivedFullWidth?.count, 1)
        XCTAssertEqual(receivedFullWidth?.first?.id, .fullWidthWidget)
        XCTAssertEqual(receivedGrid?.count, 2)
        XCTAssertEqual(receivedGrid?[0].id, .widget2)
        XCTAssertEqual(receivedGrid?[1].id, .widget1)
    }

    // MARK: - Private helpers

    private func makeViewModelFactory() -> (WidgetConfig) -> any LearnerWidgetViewModel {
        return { config in
            MockWidgetViewModel(config: config)
        }
    }
}

private final class MockWidgetViewModel: LearnerWidgetViewModel {
    typealias ViewType = Never

    let id: LearnerDashboardWidgetIdentifier
    let config: WidgetConfig
    let isFullWidth: Bool
    let isEditable = false
    let state: InstUI.ScreenState = .data

    init(config: WidgetConfig) {
        self.config = config
        self.id = config.id
        self.isFullWidth = config.id == .fullWidthWidget
    }

    func makeView() -> Never {
        fatalError("Not implemented")
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }
}
