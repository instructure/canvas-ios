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
        static let id = "some id"
        static let title = "some title"
        static let details = "some details"
        static let dateNow = DateComponents(calendar: .current, year: 2024, month: 1, day: 1, hour: 14).date!
        static let dateEarlier = DateComponents(calendar: .current, year: 2023, month: 8, day: 8, hour: 8).date!
        static let calendars: [(name: String, context: Context)] = [
            ("Course 2", .course("2")),
            ("Course 1", .course("1")),
            ("Course 4", .course("4")),
            ("User 42", .user("42")),
            ("User 3", .user("3")),
            ("Group 6", .group("6"))
        ]
    }

    private var toDoInteractor: CalendarToDoInteractorPreview!
    private var calendarListProviderInteractor: CalendarFilterInteractorPreview!

    private var completionCallsCount: Int = 0
    private var completionValue: PlannerAssembly.Completion?

    override func setUp() {
        super.setUp()
        Clock.mockNow(TestConstants.dateNow)
        toDoInteractor = .init()
        calendarListProviderInteractor = .init()
        calendarListProviderInteractor.mockedFilters = TestConstants.calendars
    }

    override func tearDown() {
        Clock.reset()
        toDoInteractor = nil
        calendarListProviderInteractor = nil
        super.tearDown()
    }

    // MARK: - Initial values

    func testAddModeInitialValues() {
        let testee = makeAddViewModel()

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.shouldShowAlert, false)

        XCTAssertEqual(testee.title, "")
        XCTAssertEqual(testee.date, TestConstants.dateNow.endOfDay())
        XCTAssertEqual(testee.calendarName, "User 42") // first user calendar in TestConstants.calendars
        XCTAssertEqual(testee.details, "")
    }

    func testEditModeInitialValues() {
        let testee = makeEditViewModel(makePlannable(
            title: TestConstants.title,
            details: TestConstants.details,
            todoDate: TestConstants.dateEarlier
        ))

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.shouldShowAlert, false)

        XCTAssertEqual(testee.title, TestConstants.title)
        XCTAssertEqual(testee.date, TestConstants.dateEarlier)
        XCTAssertEqual(testee.details, TestConstants.details)
    }

    func testEditModeInitialCalendar() {
        var testee: EditCalendarToDoViewModel
        let firstUserCalendarName = "User 42" // first user calendar in TestConstants.calendars

        // existing course context
        testee = makeEditViewModel(makePlannable(context: .course("4")))
        XCTAssertEqual(testee.calendarName, "Course 4")

        // no context (should not happen)
        testee = makeEditViewModel(makePlannable(context: nil))
        XCTAssertEqual(testee.calendarName, firstUserCalendarName)

        // existing non-course context
        testee = makeEditViewModel(makePlannable(context: .user("3")))
        XCTAssertEqual(testee.calendarName, firstUserCalendarName)

        // not existing context (should not happen)
        testee = makeEditViewModel(makePlannable(context: .course("not existing")))
        XCTAssertEqual(testee.calendarName, nil)
    }

    // MARK: - Save button enabling

    func testAddModeIsSaveButtonEnabled() {
        let testee = makeAddViewModel()

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        testee.title = "some title"
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        testee.title = " "
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        testee.title = ""
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // reset to enabled
        testee.title = "some title"

        // trigger saving state
        toDoInteractor.createToDoResult = nil
        testee.didTapSave.send()
        XCTAssertEqual(testee.isSaveButtonEnabled, false)
    }

    func testEditModeIsSaveButtonEnabledWhenTitleChanges() {
        let testee = makeEditViewModel(makePlannable(title: TestConstants.title))

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set the same value
        testee.title = TestConstants.title
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set another value
        testee.title = "another title"
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // reset to initial value
        testee.title = TestConstants.title
        XCTAssertEqual(testee.isSaveButtonEnabled, true)
    }

    func testEditModeIsSaveButtonEnabledWhenDetailChanges() {
        let testee = makeEditViewModel(makePlannable(
            title: TestConstants.title,
            details: TestConstants.details
        ))

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set the same value
        testee.details = TestConstants.details
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set another value
        testee.details = "another details"
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // reset to initial value
        testee.details = TestConstants.details
        XCTAssertEqual(testee.isSaveButtonEnabled, true)
    }

    func testEditModeIsSaveButtonEnabledWhenDateChanges() {
        let testee = makeEditViewModel(makePlannable(
            title: TestConstants.title,
            todoDate: TestConstants.dateNow
        ))

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set the same value
        testee.date = TestConstants.dateNow
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set another value
        testee.date = TestConstants.dateEarlier
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // reset to initial value
        testee.date = TestConstants.dateNow
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // set date to nil (should not happen)
        testee.date = nil
        XCTAssertEqual(testee.isSaveButtonEnabled, false)
    }

    func testEditModeIsSaveButtonEnabledWhenCalendarChanges() {
        let testee = makeEditViewModel(makePlannable(
            title: TestConstants.title,
            context: TestConstants.calendars[0].context
        ))
        // store calendars after viewModel loads the interactor
        let calendars = calendarListProviderInteractor.filters.value

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set the same value
        testee.selectCalendarViewModel.selectedCalendar = calendars[0]
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set another value
        testee.selectCalendarViewModel.selectedCalendar = calendars[1]
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // reset to initial value
        testee.selectCalendarViewModel.selectedCalendar = calendars[0]
        XCTAssertEqual(testee.isSaveButtonEnabled, true)
    }

    // MARK: - Strings

    func testAddModeStrings() {
        let testee = makeAddViewModel()

        XCTAssertEqual(testee.pageTitle, String(localized: "New To Do", bundle: .core))
        XCTAssertEqual(testee.saveButtonTitle, String(localized: "Add", bundle: .core))
        XCTAssertEqual(testee.alert.title, String(localized: "Creation not completed", bundle: .core))
        XCTAssertEqual(testee.alert.message, String(localized: "We couldn't add your To Do at this time. You can try it again.", bundle: .core))
        XCTAssertEqual(testee.alert.buttonTitle, String(localized: "OK", bundle: .core))
    }

    func testEditModeStrings() {
        let testee = makeEditViewModel(makePlannable())

        XCTAssertEqual(testee.pageTitle, String(localized: "Edit To Do", bundle: .core))
        XCTAssertEqual(testee.saveButtonTitle, String(localized: "Save", bundle: .core))
        XCTAssertEqual(testee.alert.title, String(localized: "Saving not completed", bundle: .core))
        XCTAssertEqual(testee.alert.message, String(localized: "We couldn't save your To Do at this time. You can try it again.", bundle: .core))
        XCTAssertEqual(testee.alert.buttonTitle, String(localized: "OK", bundle: .core))
    }

    // MARK: - Did Tap Cancel

    func testDidTapCancel() {
        let testee = makeAddViewModel()

        testee.didTapCancel.send()

        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, .didCancel)
    }

    // MARK: - Did Tap Save (Add mode)

    func testAddModeDidTapAddCallsCreateToDo() {
        let testee = makeAddViewModel()
        testee.title = TestConstants.title
        testee.date = TestConstants.dateEarlier
        testee.details = TestConstants.details

        let selectedCalendar = calendarListProviderInteractor.filters.value[1]
        testee.selectCalendarViewModel.selectedCalendar = selectedCalendar

        testee.didTapSave.send()

        XCTAssertEqual(toDoInteractor.createToDoCallsCount, 1)
        XCTAssertEqual(toDoInteractor.updateToDoCallsCount, 0)
        let input = toDoInteractor.createToDoInput
        XCTAssertEqual(input?.title, TestConstants.title)
        XCTAssertEqual(input?.date, TestConstants.dateEarlier)
        XCTAssertEqual(input?.calendar?.context, selectedCalendar.context)
        XCTAssertEqual(input?.details, TestConstants.details)
    }

    // MARK: - Did Tap Save (Edit mode)

    func testEditModeDidTapSaveCallsUpdateToDo() {
        let testee = makeEditViewModel(makePlannable(
            id: TestConstants.id,
            title: TestConstants.title,
            details: TestConstants.details,
            todoDate: TestConstants.dateEarlier
        ))

        let selectedCalendar = calendarListProviderInteractor.filters.value[1]
        testee.selectCalendarViewModel.selectedCalendar = selectedCalendar

        testee.didTapSave.send()

        XCTAssertEqual(toDoInteractor.createToDoCallsCount, 0)
        XCTAssertEqual(toDoInteractor.updateToDoCallsCount, 1)
        let input = toDoInteractor.updateToDoInput
        XCTAssertEqual(input?.id, TestConstants.id)
        XCTAssertEqual(input?.title, TestConstants.title)
        XCTAssertEqual(input?.date, TestConstants.dateEarlier)
        XCTAssertEqual(input?.calendar?.context, selectedCalendar.context)
        XCTAssertEqual(input?.details, TestConstants.details)
    }

    // MARK: - Did Tap Save (common)

    func testDidTapSaveShowsLoadingOverlayWhileLoading() {
        let testee = makeAddViewModel()
        toDoInteractor.createToDoResult = nil

        testee.didTapSave.send()

        XCTAssertEqual(testee.state, .data(loadingOverlay: true))
    }

    func testDidTapSaveOnSuccess() {
        let testee = makeAddViewModel()
        toDoInteractor.createToDoResult = .success

        testee.didTapSave.send()

        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, .didUpdate)
    }

    func testDidTapSaveOnFailure() {
        let testee = makeAddViewModel()
        toDoInteractor.createToDoResult = .failure(MockError())

        testee.didTapSave.send()

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.shouldShowAlert, true)
        XCTAssertEqual(completionCallsCount, 0)
    }

    func testRetryAfterFailure() {
        let testee = makeAddViewModel()
        toDoInteractor.createToDoResult = .failure(MockError())
        testee.didTapSave.send()

        toDoInteractor.createToDoResult = .success(())
        testee.didTapSave.send()

        XCTAssertEqual(completionCallsCount, 1)
    }

    // MARK: - Select Calendar

    func testSelectCalendarViewModelReusesSameInteractor() {
        let testee = makeAddViewModel()
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
        let testee = makeAddViewModel()
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
        let testee = makeAddViewModel()

        XCTAssertEqual(testee.calendarName, TestConstants.calendars[3].name)

        let selectedCalendar = calendarListProviderInteractor.filters.value[1]
        testee.selectCalendarViewModel.selectedCalendar = selectedCalendar

        XCTAssertEqual(testee.calendarName, TestConstants.calendars[1].name)
    }

    // MARK: - Helpers

    private func makeAddViewModel() -> EditCalendarToDoViewModel {
        makeEditViewModel(nil)
    }

    private func makeEditViewModel(_ plannable: Plannable?) -> EditCalendarToDoViewModel {
        .init(
            plannable: plannable,
            toDoInteractor: toDoInteractor,
            calendarListProviderInteractor: calendarListProviderInteractor,
            completion: { [weak self] in
                self?.completionValue = $0
                self?.completionCallsCount += 1
            }
        )
    }

    private func makePlannable(
        id: String = "",
        title: String = "",
        details: String? = nil,
        todoDate: Date = Clock.now,
        context: Context? = nil
    ) -> Plannable {
        let plannable = Plannable.save(
            .make(
                id: id,
                title: title,
                details: details,
                todo_date: todoDate
            ),
            contextName: nil,
            in: databaseClient)
        plannable.context = context
        return plannable
    }
}

private struct MockError: Error { }
