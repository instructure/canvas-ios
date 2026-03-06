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
    private var interactor: HelloWidgetInteractorMock!

    override func setUp() {
        super.setUp()
        interactor = .init()
        api.mock(GetUserProfile(userID: "self"), value: nil)
    }

    override func tearDown() {
        interactor = nil
        testee = nil
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_basicProperties() {
        testee = makeViewModel()

        XCTAssertEqual(testee.config.id, .helloWidget)
        XCTAssertEqual(testee.isEditable, true)
    }

    func test_initialState_shouldBeLoading() {
        testee = makeViewModel()

        XCTAssertEqual(testee.state, .loading)
    }

    // MARK: - State management

    func test_state_whenDataLoadsSuccessfully_shouldBeData() {
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false))

        XCTAssertEqual(testee.state, .data)
    }

    // MARK: - Greeting

    func test_greeting_withUserShortName_shouldIncludeShortName() {
        let shortName = "Test user"
        interactor.shortName = shortName
        testee = makeViewModel()

        Clock.mockNow(testData.morningDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        XCTAssertEqual(testee.greeting, "Good morning \(shortName)!")
    }

    func test_greeting_withEmptyShortName_shouldNotIncludeShortName() {
        testee = makeViewModel()

        Clock.mockNow(testData.morningDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        XCTAssertEqual(testee.greeting, "Good morning!")
    }

    func test_greeting_basedOnDayPeriod() {
        let shortName = "Test user"
        interactor.shortName = shortName

        // MARK: - Morning
        var testee = makeViewModel()
        Clock.mockNow(testData.morningDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        XCTAssertEqual(testee.greeting, "Good morning \(shortName)!")

        // MARK: - Afternoon
        testee = makeViewModel()
        Clock.mockNow(testData.afternoonDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        XCTAssertEqual(testee.greeting, "Good afternoon \(shortName)!")

        // MARK: - Evening
        testee = makeViewModel()
        Clock.mockNow(testData.eveningDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        XCTAssertEqual(testee.greeting, "Good evening \(shortName)!")

        // MARK: - Night
        testee = makeViewModel()
        Clock.mockNow(testData.nightDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        XCTAssertEqual(testee.greeting, "Good night \(shortName)!")
    }

    // MARK: - Message

    func test_message_shouldNotBeEmpty() {
        testee = makeViewModel()

        XCTAssertFinish(testee.refresh(ignoreCache: false))

        XCTAssertEqual(testee.message.isEmpty, false)
    }

    func test_message_shouldBeFromCorrectPeriodArray() {
        // MARK: - Morning
        let morningMessages = HelloWidgetViewModel.generic.union(HelloWidgetViewModel.morning)
        var testee = makeViewModel()
        Clock.mockNow(testData.morningDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        XCTAssertTrue(morningMessages.contains(testee.message))

        // MARK: - Afternoon
        let afternoonMessages = HelloWidgetViewModel.generic.union(HelloWidgetViewModel.afternoon)
        testee = makeViewModel()
        Clock.mockNow(testData.afternoonDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        XCTAssertTrue(afternoonMessages.contains(testee.message))

        // MARK: - Evening
        let eveningMessages = HelloWidgetViewModel.generic.union(HelloWidgetViewModel.evening)
        testee = makeViewModel()
        Clock.mockNow(testData.eveningDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        XCTAssertTrue(eveningMessages.contains(testee.message))

        // MARK: - Night
        let nightMessages = HelloWidgetViewModel.generic.union(HelloWidgetViewModel.night)
        testee = makeViewModel()
        Clock.mockNow(testData.nightDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        XCTAssertTrue(nightMessages.contains(testee.message))
    }

    // MARK: - Refresh

    func test_refresh_shouldTriggerStoreAndDateRefresh() {
        let shortName1 = "Test user 1"
        interactor.shortName = shortName1
        testee = makeViewModel()

        Clock.mockNow(testData.morningDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))
        XCTAssertEqual(testee.greeting, "Good morning \(shortName1)!")

        let shortName2 = "Test user 2"
        interactor.shortName = shortName2
        Clock.mockNow(testData.nightDate)

        XCTAssertFinish(testee.refresh(ignoreCache: true))
        XCTAssertEqual(testee.greeting, "Good night \(shortName2)!")
    }

    // MARK: - App Foreground

    func test_applicationBecomActive_shouldUpdateGreeting() {
        testee = makeViewModel()

        Clock.mockNow(testData.morningDate)
        XCTAssertFinish(testee.refresh(ignoreCache: false))

        Clock.mockNow(testData.nightDate)
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        waitUntil(shouldFail: true) { testee.greeting == "Good night!" }
    }

    // MARK: - Private helpers

    private func makeViewModel() -> HelloWidgetViewModel {
        HelloWidgetViewModel(
            config: .make(id: .helloWidget),
            interactor: interactor,
            dayPeriodProvider: .init()
        )
    }
}
