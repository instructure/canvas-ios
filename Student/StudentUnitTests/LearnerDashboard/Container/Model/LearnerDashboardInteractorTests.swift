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
import SwiftUI
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
            systemWidgetFactory: makeSystemFactory(),
            editableWidgetFactory: makeEditableFactory()
        )

        let expectation = expectation(description: "loadWidgets")
        var received: [any DashboardWidgetViewModel]?

        testee.loadWidgets()
            .sink { result in
                received = result
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 5)

        let systemWidgetIds = SystemWidgetIdentifier.allCases.map(\.rawValue)
        let editableWidgetIds = EditableWidgetIdentifier.allCases.map(\.rawValue)
        XCTAssertEqual(received?.map(\.id), systemWidgetIds + editableWidgetIds)
    }

    // MARK: - Load widgets with saved configs

    func test_loadWidgets_withSavedConfigs_shouldIncludeAllSystemAndFilterVisibleEditable() {
        userDefaults.learnerDashboardWidgetConfigs = [
            DashboardWidgetConfig(id: .helloWidget, order: 10, isVisible: true),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 5, isVisible: true)
        ]
        testee = LearnerDashboardInteractorLive(
            userDefaults: userDefaults,
            systemWidgetFactory: makeSystemFactory(),
            editableWidgetFactory: makeEditableFactory()
        )

        let expectation = expectation(description: "loadWidgets")
        var received: [any DashboardWidgetViewModel]?

        testee.loadWidgets()
            .sink { result in
                received = result
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(received?.count, 9)
        XCTAssertEqual(received?[0].id, SystemWidgetIdentifier.offlineSyncProgress.rawValue)
        XCTAssertEqual(received?[1].id, SystemWidgetIdentifier.fileUploadProgress.rawValue)
        XCTAssertEqual(received?[2].id, SystemWidgetIdentifier.courseInvitations.rawValue)
        XCTAssertEqual(received?[3].id, SystemWidgetIdentifier.globalAnnouncements.rawValue)
        XCTAssertEqual(received?[4].id, SystemWidgetIdentifier.conferences.rawValue)
        XCTAssertEqual(received?[5].id, EditableWidgetIdentifier.weeklySummary.rawValue)
        XCTAssertEqual(received?[6].id, EditableWidgetIdentifier.todo.rawValue)
        XCTAssertEqual(received?[7].id, EditableWidgetIdentifier.coursesAndGroups.rawValue)
        XCTAssertEqual(received?[8].id, EditableWidgetIdentifier.helloWidget.rawValue)
    }

    func test_loadWidgets_shouldReturnEditableWidgetsInOrder() {
        userDefaults.learnerDashboardWidgetConfigs = [
            DashboardWidgetConfig(id: .helloWidget, order: 20, isVisible: true),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 10, isVisible: true)
        ]
        testee = LearnerDashboardInteractorLive(
            userDefaults: userDefaults,
            systemWidgetFactory: makeSystemFactory(),
            editableWidgetFactory: makeEditableFactory()
        )

        let expectation = expectation(description: "loadWidgets")
        var received: [any DashboardWidgetViewModel]?

        testee.loadWidgets()
            .sink { result in
                received = result
                expectation.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(received?.count, 9)
        XCTAssertEqual(received?[4].id, SystemWidgetIdentifier.conferences.rawValue)
        XCTAssertEqual(received?[5].id, EditableWidgetIdentifier.weeklySummary.rawValue)
        XCTAssertEqual(received?[6].id, EditableWidgetIdentifier.todo.rawValue)
        XCTAssertEqual(received?[7].id, EditableWidgetIdentifier.coursesAndGroups.rawValue)
        XCTAssertEqual(received?[8].id, EditableWidgetIdentifier.helloWidget.rawValue)
    }

    // MARK: - Analytics tracking

    func test_loadWidgets_tracksWidgetVisibility() {
        let mockHandler = MockAnalyticsHandler()
        Analytics.shared.handler = mockHandler
        testee = LearnerDashboardInteractorLive(
            userDefaults: userDefaults,
            systemWidgetFactory: makeSystemFactory(),
            editableWidgetFactory: makeEditableFactory()
        )

        let expectation = expectation(description: "loadWidgets")
        testee.loadWidgets()
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)
        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(mockHandler.lastEvent, "dashboard_widget_visibility")
        XCTAssertEqual(mockHandler.lastEventParameter("welcome", ofType: String.self), "0")
        XCTAssertEqual(mockHandler.lastEventParameter("courses", ofType: String.self), "1")
        XCTAssertEqual(mockHandler.lastEventParameter("forecast", ofType: String.self), "2")
    }

    func test_loadWidgets_tracksEachLoad() {
        let mockHandler = MockAnalyticsHandler()
        Analytics.shared.handler = mockHandler
        testee = LearnerDashboardInteractorLive(
            userDefaults: userDefaults,
            systemWidgetFactory: makeSystemFactory(),
            editableWidgetFactory: makeEditableFactory()
        )

        let expectation1 = expectation(description: "loadWidgets1")
        testee.loadWidgets()
            .sink { _ in expectation1.fulfill() }
            .store(in: &subscriptions)
        wait(for: [expectation1], timeout: 5)

        let expectation2 = expectation(description: "loadWidgets2")
        testee.loadWidgets()
            .sink { _ in expectation2.fulfill() }
            .store(in: &subscriptions)
        wait(for: [expectation2], timeout: 5)

        XCTAssertEqual(mockHandler.totalEventCount, 2)
    }

    func test_loadWidgets_hiddenWidgetsTrackedAsMinusOne() {
        userDefaults.learnerDashboardWidgetConfigs = [
            DashboardWidgetConfig(id: .helloWidget, order: 0, isVisible: false),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 1, isVisible: true),
            DashboardWidgetConfig(id: .weeklySummary, order: 2, isVisible: true)
        ]
        let mockHandler = MockAnalyticsHandler()
        Analytics.shared.handler = mockHandler
        testee = LearnerDashboardInteractorLive(
            userDefaults: userDefaults,
            systemWidgetFactory: makeSystemFactory(),
            editableWidgetFactory: makeEditableFactory()
        )

        let expectation = expectation(description: "loadWidgets")
        testee.loadWidgets()
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)
        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(mockHandler.lastEventParameter("welcome", ofType: String.self), "-1")
        XCTAssertEqual(mockHandler.lastEventParameter("courses", ofType: String.self), "0")
        XCTAssertEqual(mockHandler.lastEventParameter("forecast", ofType: String.self), "1")
    }

    // MARK: - Private helpers

    private func makeSystemFactory() -> (SystemWidgetIdentifier) -> any DashboardWidgetViewModel {
        return { id in DashboardWidgetViewModelMock(id: id.rawValue) }
    }

    private func makeEditableFactory() -> (DashboardWidgetConfig) -> any DashboardWidgetViewModel {
        return { config in DashboardWidgetViewModelMock(id: config.id.rawValue) }
    }
}

private final class MockAnalyticsHandler: AnalyticsHandler {
    var lastEvent: String?
    var lastEventParameters: [String: Any]?
    var totalEventCount = 0

    func handleEvent(_ name: String, parameters: [String: Any]?) {
        lastEvent = name
        lastEventParameters = parameters
        totalEventCount += 1
    }

    func lastEventParameter<T: Equatable>(_ key: String, ofType type: T.Type = T.self) -> T? {
        lastEventParameters?[key] as? T
    }
}

private final class DashboardWidgetViewModelMock: DashboardWidgetViewModel {
    let id: String
    let isHiddenInEmptyState = false
    let state: InstUI.ScreenState = .data

    init(id: String) {
        self.id = id
    }

    func makeView() -> AnyView {
        AnyView(EmptyView())
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }
}
