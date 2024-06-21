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

@testable import Core
import XCTest

final class EditCalendarToDoViewModelTests: CoreTestCase {

    private enum TestConstants {
        static let title = "some title"
        static let details = "some details"
        static let date = DateComponents(calendar: .current, year: 2024, month: 1, day: 1).date!
        static let calendars: [(name: String, context: Context)] = [
            ("Course 2", .course("2")),
            ("Course 1", .course("1")),
            ("User 42", .user("42")),
            ("User 3", .user("3")),
            ("Group 6", .group("6"))
        ]
    }

    private var toDoInteractor: CalendarToDoInteractorPreview!
    private var calendarListProviderInteractor: CalendarFilterInteractorPreview!
    private var testee: EditCalendarToDoViewModel!

    private var completionCallsCount: Int = 0
    private var completionValue: PlannerAssembly.Completion?

    override func setUp() {
        super.setUp()
        toDoInteractor = .init()
        calendarListProviderInteractor = .init()
        calendarListProviderInteractor.mockedFilters = TestConstants.calendars
        testee = .init(
            toDoInteractor: toDoInteractor,
            calendarListProviderInteractor: calendarListProviderInteractor,
            completion: { [weak self] in
                self?.completionValue = $0
                self?.completionCallsCount += 1
            }
        )
    }

    override func tearDown() {
        toDoInteractor = nil
        calendarListProviderInteractor = nil
        testee = nil
        super.tearDown()
    }

    // MARK: - Basic properties

    func testInitialValues() {
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.shouldShowAlert, false)
        XCTAssertEqual(testee.calendarName, "User 42") // first user calendar in TestConstants.calendars
    }

    func testIsSaveButtonEnabled() {
        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        testee.title = "some title"
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        testee.title = " "
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        testee.title = ""
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        testee.title = "some title"
        toDoInteractor.createToDoResult = nil
        testee.didTapSave.send()
        XCTAssertEqual(testee.isSaveButtonEnabled, false)
    }

    // MARK: - Did Tap Cancel

    func testDidTapCancel() {
        testee.didTapCancel.send()

        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, .didCancel)
    }

    // MARK: - Did Tap Add

    func testDidTapAddShowsLoadingOverlayWhileLoading() {
        toDoInteractor.createToDoResult = nil

        testee.didTapSave.send()

        XCTAssertEqual(testee.state, .data(loadingOverlay: true))
    }

    func testDidTapAddCallsCreateToDo() {
        testee.title = TestConstants.title
        testee.date = TestConstants.date
        testee.details = TestConstants.details

        let selectedCalendar = calendarListProviderInteractor.filters.value[1]
        testee.selectCalendarViewModel.selectedCalendar = selectedCalendar

        testee.didTapSave.send()

        XCTAssertEqual(toDoInteractor.createToDoCallsCount, 1)
        let input = toDoInteractor.createToDoInput
        XCTAssertEqual(input?.title, TestConstants.title)
        XCTAssertEqual(input?.date, TestConstants.date)
        XCTAssertEqual(input?.calendar?.context, selectedCalendar.context)
        XCTAssertEqual(input?.details, TestConstants.details)
    }

    func testDidTapAddOnSuccess() {
        toDoInteractor.createToDoResult = .success

        testee.didTapSave.send()

        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, .didUpdate)
    }

    func testDidTapAddOnFailure() {
        toDoInteractor.createToDoResult = .failure(MockError())

        testee.didTapSave.send()

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.shouldShowAlert, true)
        XCTAssertEqual(completionCallsCount, 0)
    }

    func testRetryAfterFailure() {
        toDoInteractor.createToDoResult = .failure(MockError())
        testee.didTapSave.send()

        toDoInteractor.createToDoResult = .success(())
        testee.didTapSave.send()

        XCTAssertEqual(completionCallsCount, 1)
    }

    // MARK: - Select Calendar

    func testSelectCalendarViewModelReusesSameInteractor() {
        let vm = testee.selectCalendarViewModel

        let hasSpecificCalendar = {
            vm.sections.contains {
                $0.items.contains { calendar in calendar.name == "User 42" }
            }
        }

        XCTAssertEqual(hasSpecificCalendar(), true)

        calendarListProviderInteractor.mockedFilters = []
        XCTAssertFinish(calendarListProviderInteractor.load(ignoreCache: false))

        XCTAssertEqual(hasSpecificCalendar(), false)
    }

    func testSelectCalendarViewModelHasOnlyUserAndCourseCalendars() {
        let vm = testee.selectCalendarViewModel

        let hasUserCalendars = vm.sections.contains {
            $0.items.contains { calendar in calendar.context.contextType == .user }
        }
        let hasCourseCalendars = vm.sections.contains {
            $0.items.contains { calendar in calendar.context.contextType == .course }
        }
        let hasGroupCalendars = vm.sections.contains {
            $0.items.contains { calendar in calendar.context.contextType == .group }
        }

        XCTAssertEqual(hasUserCalendars, true)
        XCTAssertEqual(hasCourseCalendars, true)
        XCTAssertEqual(hasGroupCalendars, false)
    }

    func testSelectCalendarViewModelSelectsCalendar() {
        XCTAssertEqual(testee.calendarName, TestConstants.calendars[2].name)

        let selectedCalendar = calendarListProviderInteractor.filters.value[1]
        testee.selectCalendarViewModel.selectedCalendar = selectedCalendar

        XCTAssertEqual(testee.calendarName, TestConstants.calendars[1].name)
    }
}

private struct MockError: Error { }
