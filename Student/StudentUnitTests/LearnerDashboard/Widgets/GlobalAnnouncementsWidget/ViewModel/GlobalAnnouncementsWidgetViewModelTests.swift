//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import TestsFoundation
import XCTest

final class GlobalAnnouncementsWidgetViewModelTests: StudentTestCase {

    private static let testData = (
        item1: GlobalAnnouncementsWidgetItem.make(
            id: "id1",
            title: "title1",
            startDate: Date.make(year: 2025, month: 9, day: 15),
            message: "message1"
        ),
        item2: GlobalAnnouncementsWidgetItem.make(
            id: "id2",
            title: "title2",
            startDate: Date.make(year: 2025, month: 9, day: 20),
            message: "message2"
        )
    )
    private lazy var testData = Self.testData

    private var testee: GlobalAnnouncementsWidgetViewModel!
    private var interactor: GlobalAnnouncementsWidgetInteractorMock!

    override func setUp() {
        super.setUp()
        interactor = .init()
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_shouldSetupCorrectly() {
        testee = makeViewModel(
            config: .init(id: .globalAnnouncements, order: 42, isVisible: true)
        )

        XCTAssertEqual(testee.config.id, .globalAnnouncements)
        XCTAssertEqual(testee.config.order, 42)
        XCTAssertEqual(testee.isFullWidth, true)
        XCTAssertEqual(testee.isEditable, false)

        XCTAssertEqual(testee.state, .loading)
        XCTAssertEqual(testee.announcements, [])
        XCTAssertEqual(testee.widgetTitle, "Announcements (0)")
        XCTAssertEqual(testee.widgetAccessibilityTitle, "Announcements, 0 items")
    }

    // MARK: - Layout identifier

    func test_layoutIdentifier_shouldChangeWithStateAndCount() {
        interactor.mockAnnouncements = []
        let emptyVM = makeViewModel()
        waitUntil { emptyVM.state == .empty }

        interactor.mockAnnouncements = [testData.item1]
        let count1VM = makeViewModel()
        waitUntil { count1VM.state == .data }

        interactor.mockAnnouncements = [testData.item1, testData.item2]
        let count2VM = makeViewModel()
        waitUntil { count2VM.state == .data }

        XCTAssertNotEqual(count2VM.layoutIdentifier, emptyVM.layoutIdentifier)
        XCTAssertNotEqual(count2VM.layoutIdentifier, count1VM.layoutIdentifier)
    }

    // MARK: - Refresh

    func test_refresh_shouldCallLoadAnnouncements() {
        testee = makeViewModel()
        XCTAssertEqual(interactor.loadAnnouncementsCallCount, 0)

        XCTAssertFinish(testee.refresh(ignoreCache: true))

        XCTAssertEqual(interactor.loadAnnouncementsCallCount, 1)
        XCTAssertEqual(interactor.loadAnnouncementsInput, true)
    }

    func test_refresh_onError_shouldSetErrorState() {
        testee = makeViewModel()

        interactor.loadAnnouncementsOutputError = MockError()
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        XCTAssertEqual(testee.state, .error)
    }

    // MARK: - observeAnnouncements

    func test_init_shouldStartObservingAnnouncements() {
        testee = makeViewModel()

        waitUntil(shouldFail: true) {
            interactor.observeAnnouncementsCallCount == 1
        }
    }

    func test_observeAnnouncements_shouldUpdateState() {
        testee = makeViewModel()

        // WHEN interactor sends 2 items
        interactor.observeAnnouncementsSubject.send([testData.item1, testData.item2])

        // THEN state is data
        waitUntil(shouldFail: true) {
            testee.state == .data
        }

        // WHEN interactor sends 0 items
        interactor.observeAnnouncementsSubject.send([])

        // THEN state is data
        waitUntil(shouldFail: true) {
            testee.state == .empty
        }

        // WHEN interactor sends failure
        interactor.observeAnnouncementsSubject.send(completion: .failure(MockError()))

        // THEN state is data
        waitUntil(shouldFail: true) {
            testee.state == .error
        }
    }

    func test_observeAnnouncements_shouldUpdateTitles() {
        testee = makeViewModel()

        interactor.observeAnnouncementsSubject.send([testData.item1, testData.item2])
        waitUntil { testee.state == .data }

        XCTAssertEqual(testee.widgetTitle, "Announcements (2)")
        XCTAssertEqual(testee.widgetAccessibilityTitle, "Announcements, 2 items")
    }

    func test_observeAnnouncements_shouldCreateCardViewModels() {
        testee = makeViewModel()

        interactor.observeAnnouncementsSubject.send([testData.item1, testData.item2])
        waitUntil { testee.state == .data }

        XCTAssertEqual(testee.announcements.count, 2)
        XCTAssertEqual(testee.announcements.first?.id, testData.item2)
        XCTAssertEqual(testee.announcements.last?.id, testData.item1)
    }

    // MARK: - Sorting

    func test_observeAnnouncements_shouldSortLatestDateFirst() {
        testee = makeViewModel()

        interactor.observeAnnouncementsSubject.send([
            .make(id: "1", title: "A", startDate: Date.make(year: 1984)),
            .make(id: "2", title: "B", startDate: Date.make(year: 2021))
        ])
        waitUntil { testee.state == .data }

        XCTAssertEqual(testee.announcements.first?.title, "B")
        XCTAssertEqual(testee.announcements.last?.title, "A")
    }

    func test_observeAnnouncements_shouldSortNilDateLast() {
        testee = makeViewModel()

        interactor.observeAnnouncementsSubject.send([
            .make(id: "1", title: "A", startDate: nil),
            .make(id: "2", title: "B", startDate: Date.make(year: 1984))
        ])
        waitUntil { testee.state == .data }

        XCTAssertEqual(testee.announcements.first?.title, "B")
        XCTAssertEqual(testee.announcements.last?.title, "A")
    }

    // MARK: - showDetails

    func test_showDetails_shouldCallRouter() {
        testee = makeViewModel()

        interactor.observeAnnouncementsSubject.send([testData.item1])
        waitUntil { testee.state == .data }

        let vc = UIViewController()
        testee.announcements.first?.didTapCard(from: .init(vc))

        waitUntil { router.viewControllerCalls.count == 1 }

        XCTAssertEqual(router.lastShownVC is CoreHostingController<GlobalAnnouncementDetailsScreen>, true)
        XCTAssertEqual(router.lastShownFromVC, vc)
        XCTAssertEqual(router.lastShownOptions?.isModal, true)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        config: DashboardWidgetConfig = .init(id: .globalAnnouncements, order: 0, isVisible: true)
    ) -> GlobalAnnouncementsWidgetViewModel {
        GlobalAnnouncementsWidgetViewModel(
            config: config,
            interactor: interactor,
            environment: env
        )
    }
}
