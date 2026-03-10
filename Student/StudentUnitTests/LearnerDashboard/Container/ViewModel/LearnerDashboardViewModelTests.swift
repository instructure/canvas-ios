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
import TestsFoundation
import XCTest

final class LearnerDashboardViewModelTests: StudentTestCase {

    private var testee: LearnerDashboardViewModel!
    private var interactor: LearnerDashboardInteractorMock!
    private var courseSyncInteractor: CourseSyncInteractorMock!
    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        scheduler = DispatchQueue.test
        interactor = LearnerDashboardInteractorMock()
        courseSyncInteractor = CourseSyncInteractorMock()
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        courseSyncInteractor = nil
        scheduler = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_shouldLoadWidgets() {
        let widget1 = WidgetViewModelMock(id: .courseInvitations)
        let widget2 = WidgetViewModelMock(id: .helloWidget)

        testee = makeViewModel()
        interactor.loadWidgetsPublisher.send([widget1, widget2])
        scheduler.advance()

        XCTAssertEqual(testee.widgets.count, 2)
        XCTAssertEqual(testee.widgets[0].id, .courseInvitations)
        XCTAssertEqual(testee.widgets[1].id, .helloWidget)
    }

    // MARK: - Screen config

    func test_screenConfig_shouldBeConfiguredCorrectly() {
        testee = makeViewModel()

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
        testee = makeViewModel()
        interactor.loadWidgetsPublisher.send([])
        scheduler.advance()

        XCTAssertEqual(testee.state, .loading)
    }

    func test_init_withWidgets_shouldSetDataState() {
        let widget = WidgetViewModelMock(id: .helloWidget)

        testee = makeViewModel()
        interactor.loadWidgetsPublisher.send([widget])
        scheduler.advance()

        XCTAssertEqual(testee.state, .data)
    }

    // MARK: - Refresh

    func test_refresh_shouldCallRefreshOnAllWidgets() {
        let widget1 = WidgetViewModelMock(id: .helloWidget)
        let widget2 = WidgetViewModelMock(id: .coursesAndGroups)
        let widget3 = WidgetViewModelMock(id: .courseInvitations)

        testee = makeViewModel()
        interactor.loadWidgetsPublisher.send([widget3, widget1, widget2])
        scheduler.advance()

        testee.refresh(ignoreCache: true)
        scheduler.advance()

        XCTAssertEqual(widget1.refreshCalled, true)
        XCTAssertEqual(widget1.refreshIgnoreCache, true)
        XCTAssertEqual(widget2.refreshCalled, true)
        XCTAssertEqual(widget2.refreshIgnoreCache, true)
        XCTAssertEqual(widget3.refreshCalled, true)
        XCTAssertEqual(widget3.refreshIgnoreCache, true)
    }

    func test_refresh_shouldCallCompletionWhenAllWidgetsFinish() {
        let widget = WidgetViewModelMock(id: .helloWidget)

        testee = makeViewModel()
        interactor.loadWidgetsPublisher.send([widget])
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

    // MARK: - Refresh DashboardMutatorWidget

    func test_refresh_whenRequestDashboardRefreshFires_shouldTriggerRefresh() {
        let mutatorWidget = MutatorWidgetViewModelMock(id: .courseInvitations)
        let regularWidget = WidgetViewModelMock(id: .helloWidget)

        testee = makeViewModel()
        interactor.loadWidgetsPublisher.send([mutatorWidget, regularWidget])
        scheduler.advance()
        regularWidget.refreshCalled = false
        mutatorWidget.refreshCalled = false

        mutatorWidget.requestDashboardRefresh.send()
        scheduler.advance()

        XCTAssertEqual(regularWidget.refreshCalled, true)
        XCTAssertEqual(regularWidget.refreshIgnoreCache, false)
        XCTAssertEqual(mutatorWidget.refreshCalled, true)
        XCTAssertEqual(mutatorWidget.refreshIgnoreCache, false)
    }

    // MARK: - Settings Button

    func test_settingsButtonTapped_shouldPresentSettingsViewController() {
        testee = makeViewModel()

        let presentingVC = UIViewController()
        let weakVC = WeakViewController(presentingVC)
        testee.settingsButtonTapped(from: weakVC)

        XCTAssertNotNil(router.lastShownVC)
        XCTAssertEqual(router.lastShownFromVC, presentingVC)
        XCTAssertEqual(router.lastShownOptions, .modal(.popover))
    }

    func test_settingsButtonTapped_shouldConfigurePopoverCorrectly() {
        testee = makeViewModel()

        let presentingVC = UIViewController()
        let weakVC = WeakViewController(presentingVC)
        testee.settingsButtonTapped(from: weakVC)

        let settingsVC = router.lastShownVC
        XCTAssertEqual(settingsVC?.preferredContentSize.width, 350)
        XCTAssertGreaterThan(settingsVC?.preferredContentSize.height ?? 0, 0)
        XCTAssertEqual(settingsVC?.modalPresentationStyle, .popover)
    }

    func test_settingsButtonTapped_shouldConfigurePopoverSourceView() {
        testee = makeViewModel()

        let presentingVC = UIViewController()
        let customView = UIView()
        let barButtonItem = UIBarButtonItem(customView: customView)
        presentingVC.navigationItem.rightBarButtonItem = barButtonItem
        let weakVC = WeakViewController(presentingVC)

        testee.settingsButtonTapped(from: weakVC)

        let settingsVC = router.lastShownVC
        XCTAssertEqual(settingsVC?.popoverPresentationController?.sourceView, customView)
        XCTAssertEqual(settingsVC?.popoverPresentationController?.sourceRect, CGRect(x: 26, y: 35, width: 0, height: 0))
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
            snackBarViewModel: SnackBarViewModel(scheduler: scheduler.eraseToAnyScheduler()),
            mainScheduler: scheduler.eraseToAnyScheduler(),
            courseSyncInteractor: courseSyncInteractor,
            environment: env
        )
    }
}

private class WidgetViewModelMock: DashboardWidgetViewModel {
    typealias ViewType = Never

    let config: DashboardWidgetConfig
    let isEditable = false
    let isHiddenInEmptyState = false
    let state: InstUI.ScreenState = .data

    var refreshCalled = false
    var refreshIgnoreCache: Bool?

    init(id: DashboardWidgetIdentifier) {
        self.config = .make(id: id, order: 7)
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
