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
import SwiftUI
import TestsFoundation
import XCTest

final class LearnerDashboardViewModelTests: StudentTestCase {

    private var testee: LearnerDashboardViewModel!
    private var interactor: LearnerDashboardInteractorMock!
    private var colorInteractor: LearnerDashboardColorInteractorLive!
    private var courseSyncInteractor: CourseSyncInteractorMock!
    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        scheduler = DispatchQueue.test
        interactor = LearnerDashboardInteractorMock()
        courseSyncInteractor = CourseSyncInteractorMock()
        colorInteractor = LearnerDashboardColorInteractorLive(defaults: userDefaults)
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        colorInteractor = nil
        courseSyncInteractor = nil
        scheduler = nil
        super.tearDown()
    }

    // MARK: - Load reason

    func test_init_withOnStartupLoadReason_shouldLoadWidgets() {
        testee = makeViewModel()

        XCTAssertEqual(interactor.loadEditableWidgetConfigsCallCount, 1)
        XCTAssertEqual(interactor.loadEditableWidgetConfigsInput, .onStartup)
    }

    func test_makeSettingsViewModel_whenConfigsChanged_shouldLoadWidgets() {
        testee = makeViewModel()
        let settingsVM = testee.makeSettingsViewModel()

        let config = settingsVM.widgetsSectionViewModel.visibleConfigs[0]
        settingsVM.widgetsSectionViewModel.toggleVisibility(of: config, to: false)
        scheduler.advance()

        XCTAssertEqual(interactor.loadEditableWidgetConfigsCallCount, 2)
        XCTAssertEqual(interactor.loadEditableWidgetConfigsInput, .onConfigChange)
    }

    // MARK: - Initialization

    func test_init_shouldLoadAllSystemWidgetsAndReturnedEditableWidgets() throws {
        let config1 = DashboardWidgetConfig.make(id: .coursesAndGroups)
        let config2 = DashboardWidgetConfig.make(id: .helloWidget)

        testee = makeViewModel()
        interactor.loadEditableWidgetConfigsPublisher.send([config1, config2])
        scheduler.advance()

        guard testee.widgets.count == 7 else { throw InvalidCountError() }

        XCTAssertEqual(testee.widgets[0].id, SystemWidgetIdentifier.offlineSyncProgress.rawValue)
        XCTAssertEqual(testee.widgets[1].id, SystemWidgetIdentifier.fileUploadProgress.rawValue)
        XCTAssertEqual(testee.widgets[2].id, SystemWidgetIdentifier.courseInvitations.rawValue)
        XCTAssertEqual(testee.widgets[3].id, SystemWidgetIdentifier.globalAnnouncements.rawValue)
        XCTAssertEqual(testee.widgets[4].id, SystemWidgetIdentifier.conferences.rawValue)
        XCTAssertEqual(testee.widgets[5].id, EditableWidgetIdentifier.coursesAndGroups.rawValue)
        XCTAssertEqual(testee.widgets[6].id, EditableWidgetIdentifier.helloWidget.rawValue)
    }

    func test_init_shouldRefreshLoadedWidgets() throws {
        let config1 = DashboardWidgetConfig.make(id: .coursesAndGroups)
        let config2 = DashboardWidgetConfig.make(id: .helloWidget)

        testee = makeViewModel()
        interactor.loadEditableWidgetConfigsPublisher.send([config1, config2])
        scheduler.advance()

        let mockWidgets = testee.widgets.compactMap { $0 as? WidgetViewModelMock }
        mockWidgets.forEach {
            XCTAssertEqual($0.refreshCallCount, 1)
            XCTAssertEqual($0.refreshInput, false)
        }
    }

    // MARK: - Screen config

    func test_screenConfig_shouldBeConfiguredCorrectly() {
        testee = makeViewModel()

        XCTAssertEqual(testee.screenConfig.refreshable, true)
        XCTAssertEqual(testee.screenConfig.showsScrollIndicators, false)
    }

    // MARK: - State management

    func test_init_withNoWidgets_shouldSetDataState() {
        testee = makeViewModel()
        interactor.loadEditableWidgetConfigsPublisher.send([])
        scheduler.advance()

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.showWidgetsTurnedOffPanda, true)
    }

    func test_init_withWidgets_shouldSetDataState() {
        testee = makeViewModel()
        interactor.loadEditableWidgetConfigsPublisher.send([.make(id: .helloWidget)])
        scheduler.advance()

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.showWidgetsTurnedOffPanda, false)
    }

    // MARK: - Refresh

    func test_refresh_shouldCallRefreshOnAllWidgets() {
        let config1 = DashboardWidgetConfig.make(id: .helloWidget)
        let config2 = DashboardWidgetConfig.make(id: .coursesAndGroups)

        testee = makeViewModel()
        interactor.loadEditableWidgetConfigsPublisher.send([config1, config2])
        scheduler.advance()

        testee.refresh(ignoreCache: true)
        scheduler.advance()

        let mockWidgets = testee.widgets.compactMap { $0 as? WidgetViewModelMock }
        mockWidgets.forEach {
            XCTAssertEqual($0.refreshCallCount, 2) // first was the initial refresh during init()
            XCTAssertEqual($0.refreshInput, true)
        }
    }

    func test_refresh_shouldCallCompletionWhenAllWidgetsFinish() {
        testee = makeViewModel()
        interactor.loadEditableWidgetConfigsPublisher.send([.make(id: .helloWidget)])
        scheduler.advance()

        var completionCallCount = 0
        testee.refresh(ignoreCache: false) {
            completionCallCount += 1
        }
        scheduler.advance()

        waitUntil {
            completionCallCount == 1
        }
        let mockWidgets = testee.widgets.compactMap { $0 as? WidgetViewModelMock }
        mockWidgets.forEach {
            XCTAssertEqual($0.refreshCallCount, 2) // first was the initial refresh during init()
        }
    }

    func test_refresh_shouldReuseExistingWidgets() throws {
        let systemWidgetCount = SystemWidgetIdentifier.allCases.count
        let helloId = EditableWidgetIdentifier.helloWidget.rawValue
        let courseId = EditableWidgetIdentifier.coursesAndGroups.rawValue
        let weeklyId = EditableWidgetIdentifier.weeklySummary.rawValue
        let todoId = EditableWidgetIdentifier.todo.rawValue

        // GIVEN - initial list of editable widget configs
        testee = makeViewModel()
        interactor.loadEditableWidgetConfigsPublisher.send([
            .make(id: .todo),
            .make(id: .helloWidget),
            .make(id: .coursesAndGroups)
        ])
        scheduler.advance()

        var mockWidgets = testee.widgets.compactMap { $0 as? WidgetViewModelMock }
        guard mockWidgets.count == systemWidgetCount + 3 else { throw InvalidCountError() }
        weak var todoWidget1 = mockWidgets[systemWidgetCount + 0]
        weak var helloWidget1 = mockWidgets[systemWidgetCount + 1]
        weak var courseWidget1 = mockWidgets[systemWidgetCount + 2]
        XCTAssertEqual(todoWidget1?.id, todoId)
        XCTAssertEqual(helloWidget1?.id, helloId)
        XCTAssertEqual(courseWidget1?.id, courseId)
        mockWidgets = [] // remove widget references from array

        // WHEN - refresh is called with new list of editable widgate configs
        testee.refresh(ignoreCache: false)
        interactor.loadEditableWidgetConfigsPublisher.send([
            .make(id: .coursesAndGroups),
            .make(id: .weeklySummary),
            .make(id: .helloWidget)
        ])
        scheduler.advance()

        // THEN - returned widgets match the new list of configs
        mockWidgets = testee.widgets.compactMap { $0 as? WidgetViewModelMock }
        guard mockWidgets.count == systemWidgetCount + 3 else { throw InvalidCountError() }
        weak var courseWidget2 = mockWidgets[systemWidgetCount + 0]
        weak var weeklyWidget2 = mockWidgets[systemWidgetCount + 1]
        weak var helloWidget2 = mockWidgets[systemWidgetCount + 2]
        XCTAssertEqual(courseWidget2?.id, courseId)
        XCTAssertEqual(weeklyWidget2?.id, weeklyId)
        XCTAssertEqual(helloWidget2?.id, helloId)

        // THEN - existing widgets are reused
        XCTAssertEqual(courseWidget2 === courseWidget1, true)
        XCTAssertEqual(helloWidget2 === helloWidget1, true)

        // THEN - not returned widgets are released
        XCTAssertNil(todoWidget1)
    }

    // MARK: - Refresh DashboardMutatorWidget

    func test_refresh_whenRequestDashboardRefreshFires_shouldTriggerRefreshUsingCache() {
        let mutatorConfig = DashboardWidgetConfig.make(id: .coursesAndGroups)
        let regularConfig = DashboardWidgetConfig.make(id: .helloWidget)

        testee = makeViewModel()
        interactor.loadEditableWidgetConfigsPublisher.send([mutatorConfig, regularConfig])
        scheduler.advance()

        let mutatorWidget = testee.widgets.compactMap { $0 as? MutatorWidgetViewModelMock }.first
        mutatorWidget?.requestDashboardRefresh.send()
        scheduler.advance()

        let mockWidgets = testee.widgets.compactMap { $0 as? WidgetViewModelMock }
        mockWidgets.forEach {
            XCTAssertEqual($0.refreshCallCount, 2) // first was the initial refresh during init()
            XCTAssertEqual($0.refreshInput, false)
        }
    }

    // MARK: - Offline Sync Handlers

    func test_offlineSyncTriggered_shouldStartDownload() {
        testee = makeViewModel()

        let entries = [CourseSyncEntry.make()]
        NotificationCenter.default.post(
            name: .OfflineSyncTriggered,
            object: entries
        )

        XCTAssertEqual(courseSyncInteractor.downloadContentCalled, true)
        XCTAssertEqual(courseSyncInteractor.downloadContentEntries?.count, 1)
    }

    func test_offlineSyncCleanTriggered_shouldCleanContent() {
        testee = makeViewModel()

        let ids = [CourseSyncID(value: "1")]
        NotificationCenter.default.post(
            name: .OfflineSyncCleanTriggered,
            object: ids
        )

        XCTAssertEqual(courseSyncInteractor.cleanContentCalled, true)
        XCTAssertEqual(courseSyncInteractor.cleanContentIds?.count, 1)
    }

    // MARK: - Private helpers

    private func makeViewModel() -> LearnerDashboardViewModel {
        .init(
            interactor: interactor,
            colorInteractor: colorInteractor,
            snackBarViewModel: SnackBarViewModel(scheduler: scheduler.eraseToAnyScheduler()),
            mainScheduler: scheduler.eraseToAnyScheduler(),
            courseSyncInteractor: courseSyncInteractor,
            systemWidgetFactory: makeSystemFactory(),
            editableWidgetFactory: makeEditableFactory(),
            environment: env
        )
    }

    private func makeSystemFactory() -> (SystemWidgetIdentifier) -> any DashboardWidgetViewModel {
        return { id in WidgetViewModelMock(id: id.rawValue) }
    }

    private func makeEditableFactory() -> (DashboardWidgetConfig) -> any DashboardWidgetViewModel {
        return { config in
            if config.id == .coursesAndGroups {
                MutatorWidgetViewModelMock(id: config.id.rawValue)
            } else {
                WidgetViewModelMock(id: config.id.rawValue)
            }
        }
    }
}

private class WidgetViewModelMock: DashboardWidgetViewModel {
    let id: String
    let isHiddenInEmptyState = false
    let state: ScreenState = .data

    var refreshCallCount = 0
    var refreshInput: Bool?

    init(id: String) {
        self.id = id
    }

    func makeView() -> AnyView {
        AnyView(EmptyView())
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        refreshInput = ignoreCache
        refreshCallCount += 1
        return Just(()).eraseToAnyPublisher()
    }
}

private final class MutatorWidgetViewModelMock: WidgetViewModelMock, DashboardMutatorWidget {
    var requestDashboardRefresh = PassthroughSubject<Void, Never>()
}

private final class CourseSyncInteractorMock: CourseSyncInteractor {
    var downloadContentCalled = false
    var downloadContentEntries: [CourseSyncEntry]?
    var cleanContentCalled = false
    var cleanContentIds: [CourseSyncID]?

    func downloadContent(for entries: [CourseSyncEntry]) -> AnyPublisher<[CourseSyncEntry], Never> {
        downloadContentCalled = true
        downloadContentEntries = entries
        return Just(entries).eraseToAnyPublisher()
    }

    func cleanContent(for ids: [CourseSyncID]) -> AnyPublisher<Void, Never> {
        cleanContentCalled = true
        cleanContentIds = ids
        return Just(()).eraseToAnyPublisher()
    }

    func cancel() {}
}
