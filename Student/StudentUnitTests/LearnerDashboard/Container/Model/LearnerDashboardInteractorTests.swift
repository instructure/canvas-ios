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
    private var analytics: AnalyticsHandlerMock!
    private var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        analytics = .init()
        Analytics.shared.handler = analytics
        subscriptions = []
    }

    override func tearDown() {
        analytics = nil
        testee = nil
        subscriptions = nil
        super.tearDown()
    }

    // MARK: - loadEditableWidgetConfigs with no saved configs

    func test_loadEditableWidgetConfigs_withNoSavedConfigs_shouldUseDefaultConfigs() {
        testee = makeInteractor()

        XCTAssertSingleOutputEquals(
            testee.loadEditableWidgetConfigs(loadReason: .onStartup),
            EditableWidgetIdentifier.makeDefaultConfigs()
        )
    }

    // MARK: - loadEditableWidgetConfigs with saved configs

    func test_loadEditableWidgetConfigs_withSavedConfigs() {
        userDefaults.learnerDashboardWidgetConfigs = [
            DashboardWidgetConfig(id: .helloWidget, order: 10, isVisible: true),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 5, isVisible: false)
        ]
        testee = makeInteractor()

        XCTAssertSingleOutput(testee.loadEditableWidgetConfigs(loadReason: .onStartup)) {
            let identifiers = $0.map(\.id)
            // - includes not-saved default widgets
            // - includes saved widgets which are visible
            // - sorts them combining orders of saved and default widgets
            XCTAssertEqual(identifiers, [.weeklySummary, .todo, .helloWidget])
        }
    }

    // MARK: - Analytics tracking

    func test_loadEditableWidgetConfigs_whenLoadReasonIsOnStartup_shouldLogWidgetVisibilityEvent() {
        testee = makeInteractor()

        XCTAssertFinish(testee.loadEditableWidgetConfigs(loadReason: .onStartup))

        XCTAssertEqual(analytics.handleEventInput?.name, "dashboard_widget_visibility")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["welcome"] as? String, "0")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["courses"] as? String, "1")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["forecast"] as? String, "2")
    }

    func test_loadEditableWidgetConfigs_whenLoadReasonIsOnConfigChange_shouldLogWidgetCustomizationEvent() {
        testee = makeInteractor()

        XCTAssertFinish(testee.loadEditableWidgetConfigs(loadReason: .onConfigChange))

        XCTAssertEqual(analytics.handleEventInput?.name, "dashboard_widget_customization")
        XCTAssertNil(analytics.handleEventInput?.parameters)
    }

    func test_loadEditableWidgetConfigs_whenMultipleChangesHappen_shouldLogOneEventPerChange() {
        testee = makeInteractor()

        XCTAssertFinish(testee.loadEditableWidgetConfigs(loadReason: .onConfigChange))
        XCTAssertFinish(testee.loadEditableWidgetConfigs(loadReason: .onConfigChange))

        XCTAssertEqual(analytics.handleEventCallCount, 2)
    }

    func test_loadEditableWidgetConfigs_hiddenWidgetsTrackedAsMinusOne() {
        userDefaults.learnerDashboardWidgetConfigs = [
            DashboardWidgetConfig(id: .helloWidget, order: 0, isVisible: false),
            DashboardWidgetConfig(id: .coursesAndGroups, order: 1, isVisible: true),
            DashboardWidgetConfig(id: .weeklySummary, order: 2, isVisible: true)
        ]
        testee = makeInteractor()

        XCTAssertFinish(testee.loadEditableWidgetConfigs(loadReason: .onStartup))

        XCTAssertEqual(analytics.handleEventInput?.parameters?["welcome"] as? String, "-1")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["courses"] as? String, "0")
        XCTAssertEqual(analytics.handleEventInput?.parameters?["forecast"] as? String, "1")
    }

    // MARK: - Private helpers

    private func makeInteractor() -> LearnerDashboardInteractorLive {
        LearnerDashboardInteractorLive(userDefaults: userDefaults)
    }
}

private final class AnalyticsHandlerMock: AnalyticsHandler {
    var handleEventInput: (name: String, parameters: [String: Any]?)?
    var handleEventCallCount = 0

    func handleEvent(_ name: String, parameters: [String: Any]?) {
        handleEventInput = (name, parameters)
        handleEventCallCount += 1
    }
}
