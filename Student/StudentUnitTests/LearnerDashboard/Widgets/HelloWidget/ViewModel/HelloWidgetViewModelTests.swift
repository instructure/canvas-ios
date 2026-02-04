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

import XCTest
import Combine
import TestsFoundation
@testable import Core
@testable import Student

final class HelloWidgetViewModelTests: StudentTestCase {
    private let testData = (
        morningDate: Date.make(year: 2025, month: 9, day: 15, hour: 8),
        afternoonDate: Date.make(year: 2025, month: 9, day: 15, hour: 14),
        eveningDate: Date.make(year: 2025, month: 9, day: 15, hour: 19),
        nightDate: Date.make(year: 2025, month: 9, day: 15, hour: 23)
    )

    private var testee: HelloWidgetViewModel!

    override func setUp() {
        super.setUp()
        api.mock(GetUserProfile(userID: "self"), value: nil)
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_basicProperties() {
        testee = makeViewModel()

        XCTAssertEqual(testee.config.id, .helloWidget)
        XCTAssertEqual(testee.isFullWidth, true)
        XCTAssertEqual(testee.isEditable, false)
    }

    func test_initialState_shouldBeLoading() {
        testee = makeViewModel()

        XCTAssertEqual(testee.state, .loading)
    }

    // MARK: - State management

    func test_state_whenDataLoadsSuccessfully_shouldBeData() {
        let shortNameExpectation = expectation(description: "Short name expectation")
        let interactor = HelloWidgetInteractorMock(shortNameExpectation: shortNameExpectation)

        testee = makeViewModel(interactor: interactor)

        wait(for: [shortNameExpectation], timeout: 1)
        XCTAssertEqual(testee.state, .data)
    }

    // MARK: - Greeting

    func test_greeting_withUserShortName_shouldIncludeShortName() {
        let shortName = "Test user"
        let shortNameExpectation = expectation(description: "Short name expectation")
        let interactor = HelloWidgetInteractorMock(shortName: shortName, shortNameExpectation: shortNameExpectation)

        testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.morningDate))

        wait(for: [shortNameExpectation])
        XCTAssertEqual(testee.greeting, "Good morning \(shortName)!")
    }

    func test_greeting_withEmptyShortName_shouldNotIncludeShortName() {
        let shortNameExpectation = expectation(description: "Short name expectation")
        let interactor = HelloWidgetInteractorMock(shortNameExpectation: shortNameExpectation)

        testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.morningDate))
        wait(for: [shortNameExpectation])
        XCTAssertEqual(testee.greeting, "Good morning!")
    }

    func test_greeting_basedOnDayPeriod() {
        // MARK: - Morning
        let shortName = "Test user"
        let morningShortNameExpectation = expectation(description: "Morning short name expectation")
        var interactor = HelloWidgetInteractorMock(shortName: shortName, shortNameExpectation: morningShortNameExpectation)

        var testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.morningDate))
        wait(for: [morningShortNameExpectation])
        XCTAssertEqual(testee.greeting, "Good morning \(shortName)!")

        // MARK: - Afternoon
        let afternoonShortNameExpectation = expectation(description: "Afternoon short name expectation")
        interactor = HelloWidgetInteractorMock(shortName: shortName, shortNameExpectation: afternoonShortNameExpectation)

        testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.afternoonDate))
        wait(for: [afternoonShortNameExpectation])
        XCTAssertEqual(testee.greeting, "Good afternoon \(shortName)!")

        // MARK: - Evening
        let eveningShortNameExpectation = expectation(description: "Evening short name expectation")
        interactor = HelloWidgetInteractorMock(shortName: shortName, shortNameExpectation: eveningShortNameExpectation)

        testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.eveningDate))
        wait(for: [eveningShortNameExpectation])
        XCTAssertEqual(testee.greeting, "Good evening \(shortName)!")

        // MARK: - Night
        let nightShortNameExpectation = expectation(description: "Night short name expectation")
        interactor = HelloWidgetInteractorMock(shortName: shortName, shortNameExpectation: nightShortNameExpectation)

        testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.nightDate))
        wait(for: [nightShortNameExpectation])
        XCTAssertEqual(testee.greeting, "Good night \(shortName)!")
    }

    // MARK: - Message

    func test_message_shouldNotBeEmpty() {
        let shortNameExpectation = expectation(description: "Short name expectation")
        let interactor = HelloWidgetInteractorMock(shortNameExpectation: shortNameExpectation)

        testee = makeViewModel(interactor: interactor)
        wait(for: [shortNameExpectation])
        XCTAssertEqual(testee.message.isEmpty, false)
    }

    func test_message_shouldBeFromCorrectPeriodArray() {
        // MARK: - Morning
        let morningShortNameExpectation = expectation(description: "Morning short name expectation")
        var interactor = HelloWidgetInteractorMock(shortNameExpectation: morningShortNameExpectation)
        let morningMessages = HelloWidgetViewModel.generic.union(HelloWidgetViewModel.morning)

        var testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.morningDate))
        wait(for: [morningShortNameExpectation], timeout: 1)
        XCTAssertTrue(morningMessages.contains(testee.message))

        // MARK: - Afternoon
        let afternoonShortNameExpectation = expectation(description: "Afternoon short name expectation")
        interactor = HelloWidgetInteractorMock(shortNameExpectation: afternoonShortNameExpectation)
        let afternoonMessages = HelloWidgetViewModel.generic.union(HelloWidgetViewModel.afternoon)

        testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.afternoonDate))
        wait(for: [afternoonShortNameExpectation], timeout: 1)
        XCTAssertTrue(afternoonMessages.contains(testee.message))

        // MARK: - Evening
        let eveningShortNameExpectation = expectation(description: "Evening short name expectation")
        interactor = HelloWidgetInteractorMock(shortNameExpectation: eveningShortNameExpectation)
        let eveningMessages = HelloWidgetViewModel.generic.union(HelloWidgetViewModel.evening)

        testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.eveningDate))
        wait(for: [eveningShortNameExpectation], timeout: 1)
        XCTAssertTrue(eveningMessages.contains(testee.message))

        // MARK: - Night
        let nightShortNameExpectation = expectation(description: "Night short name expectation")
        interactor = HelloWidgetInteractorMock(shortNameExpectation: nightShortNameExpectation)
        let nightMessages = HelloWidgetViewModel.generic.union(HelloWidgetViewModel.night)

        testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.nightDate))
        wait(for: [nightShortNameExpectation], timeout: 1)
        XCTAssertTrue(nightMessages.contains(testee.message))
    }

    // MARK: - Refresh

    func test_refresh_shouldTriggerStoreAndDateRefresh() {
        let shortNameExpectation = expectation(description: "Short name expectation")
        shortNameExpectation.assertForOverFulfill = false
        let refreshExpectation = expectation(description: "Refresh expectation")
        let shortName1 = "Test user 1"
        let interactor = HelloWidgetInteractorMock(shortName: shortName1, shortNameExpectation: shortNameExpectation)

        testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.morningDate))
        wait(for: [shortNameExpectation], timeout: 1)
        XCTAssertEqual(testee.greeting, "Good morning \(shortName1)!")

        let shortName2 = "Test user 2"
        interactor.shortName = shortName2
        Clock.mockNow(testData.nightDate)

        let subscription = testee.refresh(ignoreCache: true)
            .sink(receiveCompletion: { _ in refreshExpectation.fulfill() }, receiveValue: { _ in })

        wait(for: [refreshExpectation], timeout: 1)
        XCTAssertEqual(testee.greeting, "Good night \(shortName2)!")
        subscription.cancel()
    }

    // MARK: - timer
    func test_applicationBecomActive_shouldUpdateGreeting() {
        let shortNameExpectation = expectation(description: "Short name expectation")
        let interactor = HelloWidgetInteractorMock(shortNameExpectation: shortNameExpectation)

        testee = makeViewModel(interactor: interactor, dayPeriodProvider: .init(date: testData.morningDate))
        wait(for: [shortNameExpectation], timeout: 1)
        XCTAssertEqual(testee.greeting, "Good morning!")

        Clock.mockNow(testData.nightDate)
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        XCTAssertEqual(testee.greeting, "Good night!")
    }

    // MARK: - Private helpers

    private func makeViewModel(
        interactor: HelloWidgetInteractor = HelloWidgetInteractorLive(),
        dayPeriodProvider: DayPeriodProvider = .init()
    ) -> HelloWidgetViewModel {
        HelloWidgetViewModel(
            environment: env,
            dayPeriodProvider: dayPeriodProvider,
            interactor: interactor,
            config: DashboardWidgetConfig(
                id: .helloWidget,
                order: 42,
                isVisible: true,
                settings: nil
            )
        )
    }
}
