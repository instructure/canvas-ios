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

final class ConferencesWidgetViewModelTests: StudentTestCase {

    private static let testData = (
        conferenceId1: "conf1",
        conferenceTitle1: "some conferenceTitle1",
        courseName: "some courseName",
        conferenceId2: "conf2",
        conferenceTitle2: "some conferenceTitle2",
        groupName: "some groupName"
    )
    private lazy var testData = Self.testData

    private var testee: ConferencesWidgetViewModel!
    private var interactor: ConferencesWidgetInteractorMock!
    private var snackBarViewModel: SnackBarViewModel!

    override func setUp() {
        super.setUp()
        interactor = ConferencesWidgetInteractorMock()
        snackBarViewModel = SnackBarViewModel()
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        snackBarViewModel = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_shouldSetupCorrectly() {
        let config = DashboardWidgetConfig(id: .conferences, order: 42, isVisible: true)
        testee = makeViewModel(config: config)

        XCTAssertEqual(testee.config.id, .conferences)
        XCTAssertEqual(testee.config.order, 42)
        XCTAssertEqual(testee.isFullWidth, true)
        XCTAssertEqual(testee.isEditable, false)
        XCTAssertEqual(testee.state, .loading)
        XCTAssertEqual(testee.conferences.isEmpty, true)
    }

    // MARK: - Refresh

    func test_refresh_withNoConferences_shouldSetEmptyState() {
        interactor.getConferencesOutputValue = []
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)

        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.conferences.isEmpty, true)
    }

    func test_refresh_withConferences_shouldSetDataState() {
        setupTwoConferences()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.conferences.count, 2)
    }

    func test_refresh_shouldCreateConferenceCardViewModels() {
        setupTwoConferences()
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)

        XCTAssertEqual(testee.conferences.first?.id, testData.conferenceId1)
        XCTAssertEqual(testee.conferences.first?.title, testData.conferenceTitle1)
        XCTAssertEqual(testee.conferences.first?.contextName, testData.courseName)
        XCTAssertEqual(testee.conferences.last?.id, testData.conferenceId2)
        XCTAssertEqual(testee.conferences.last?.title, testData.conferenceTitle2)
        XCTAssertEqual(testee.conferences.last?.contextName, testData.groupName)
    }

    func test_refresh_shouldSortConferencesByIdAscending() {
        interactor.getConferencesOutputValue = [
            .make(id: "conf-z"),
            .make(id: "conf-a")
        ]
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)

        XCTAssertEqual(testee.conferences.first?.id, "conf-a")
        XCTAssertEqual(testee.conferences.last?.id, "conf-z")
    }

    func test_refresh_onError_shouldSetErrorState() {
        interactor.getConferencesOutputError = NSError.instructureError("some error")
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)

        XCTAssertEqual(testee.state, .error)
    }

    // MARK: - Widget title

    func test_widgetTitle() {
        // WHEN no conferences
        interactor.getConferencesOutputValue = []
        testee = makeViewModel()
        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        // THEN
        XCTAssertEqual(testee.widgetTitle, "Live Conferences (0)")
        XCTAssertEqual(testee.widgetAccessibilityTitle, "Live Conferences, 0 items")

        // WHEN 2 conferences
        setupTwoConferences()
        testee = makeViewModel()
        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        // THEN
        XCTAssertEqual(testee.widgetTitle, "Live Conferences (2)")
        XCTAssertEqual(testee.widgetAccessibilityTitle, "Live Conferences, 2 items")
    }

    // MARK: - Layout identifier

    func test_layoutIdentifier_shouldChangeWithStateAndCount() {
        setupTwoConferences()
        testee = makeViewModel()
        let initialId = testee.layoutIdentifier

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)

        XCTAssertNotEqual(testee.layoutIdentifier, initialId)
    }

    // MARK: - Dismiss

    func test_dismissConference_shouldRemoveFromList() {
        setupTwoConferences()
        testee = makeViewModel()
        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.conferences.count, 2)

        testee.conferences.first?.didTapDismiss()

        waitUntil(shouldFail: false) {
            self.testee.conferences.count == 1 &&
            self.testee.conferences.first?.id == self.testData.conferenceId2
        }
    }

    func test_dismissConference_whenLastConference_shouldSetEmptyState() {
        interactor.getConferencesOutputValue = [.make(id: testData.conferenceId1)]
        testee = makeViewModel()
        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(testee.state, .data)

        testee.conferences.first?.didTapDismiss()

        waitUntil(shouldFail: false) {
            self.testee.conferences.isEmpty &&
            self.testee.state == .empty
        }
    }

    func test_dismissConference_shouldCallInteractor() {
        interactor.getConferencesOutputValue = [.make(id: testData.conferenceId1)]
        testee = makeViewModel()
        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)
        XCTAssertEqual(interactor.dismissConferenceCallCount, 0)

        testee.conferences.first?.didTapDismiss()

        waitUntil(shouldFail: false) {
            self.interactor.dismissConferenceCallCount == 1 &&
            self.interactor.dismissConferenceInput == self.testData.conferenceId1
        }
    }

    // MARK: - Private helpers

    private func makeViewModel(
        config: DashboardWidgetConfig = .make(id: .conferences)
    ) -> ConferencesWidgetViewModel {
        ConferencesWidgetViewModel(
            config: config,
            interactor: interactor,
            snackBarViewModel: snackBarViewModel,
            environment: env
        )
    }

    private func setupTwoConferences() {
        interactor.getConferencesOutputValue = [
            .make(
                id: testData.conferenceId1,
                title: testData.conferenceTitle1,
                contextName: testData.courseName
            ),
            .make(
                id: testData.conferenceId2,
                title: testData.conferenceTitle2,
                contextName: testData.groupName
            )
        ]
    }
}
