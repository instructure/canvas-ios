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

import XCTest
@testable import Core

final class EditCalendarEventViewModelTests: CoreTestCase {

    private enum TestConstants {
        static let id = "some id"
        static let title = "some title"
        static let details = "some details"
        static let locationName = "some locationName"
        static let locationAddress = "some locationAddress"
        static let dateNow = Date.make(year: 2024, month: 1, day: 1, hour: 14, minute: 7)
        static let dateStart = Date.make(year: 2023, month: 8, day: 8, hour: 8, minute: 42)
        static let calendars: [(name: String, context: Context)] = [
            ("Course 2", .course("2")),
            ("Course 1", .course("1")),
            ("Course 4", .course("4")),
            ("User 42", .user("42")),
            ("User 3", .user("3")),
            ("Group 6", .group("6"))
        ]
        static let uploadContext: Context = .course("some upload target")
    }

    private var eventInteractor: CalendarEventInteractorPreview!
    private var calendarListProviderInteractor: CalendarFilterInteractorPreview!

    private var completionCallsCount: Int = 0
    private var completionValue: PlannerAssembly.Completion?

    override func setUp() {
        super.setUp()
        Clock.mockNow(TestConstants.dateNow)
        eventInteractor = .init()
        calendarListProviderInteractor = .init()
        calendarListProviderInteractor.mockedFilters = TestConstants.calendars
    }

    override func tearDown() {
        Clock.reset()
        eventInteractor = nil
        calendarListProviderInteractor = nil
        super.tearDown()
    }

    // MARK: - Initial values

    func testAddModeInitialValues() {
        let testee = makeAddViewModel()

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.endTimeErrorMessage, nil)
        XCTAssertEqual(testee.shouldShowSaveError, false)
        XCTAssertEqual(testee.uploadParameters.context, TestConstants.uploadContext)

        XCTAssertEqual(testee.title, "")
        XCTAssertEqual(testee.date, Date.make(year: 2024, month: 1, day: 1))
        XCTAssertEqual(testee.isAllDay, false)
        XCTAssertEqual(testee.startTime, Date.make(year: 2024, month: 1, day: 1, hour: 15))
        XCTAssertEqual(testee.endTime, Date.make(year: 2024, month: 1, day: 1, hour: 16))
        XCTAssertEqual(testee.calendarName, "User 42") // first user calendar in TestConstants.calendars
        XCTAssertEqual(testee.location, "")
        XCTAssertEqual(testee.address, "")
        XCTAssertEqual(testee.details, "")
    }

    func testAddModeDefaultDate() {
        var testee: EditCalendarEventViewModel

        testee = makeAddViewModel()
        XCTAssertEqual(testee.date, TestConstants.dateNow.startOfDay())

        testee = makeAddViewModel(selectedDate: TestConstants.dateStart)
        XCTAssertEqual(testee.date, TestConstants.dateStart.startOfDay())
    }

    func testEditModeInitialValues() {
        let testee = makeEditViewModel(makeEvent(
            title: TestConstants.title,
            locationName: TestConstants.locationName,
            locationAddress: TestConstants.locationAddress,
            details: TestConstants.details
        ))

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.endTimeErrorMessage, nil)
        XCTAssertEqual(testee.shouldShowSaveError, false)
        XCTAssertEqual(testee.uploadParameters.context, TestConstants.uploadContext)

        XCTAssertEqual(testee.title, TestConstants.title)
        XCTAssertEqual(testee.location, TestConstants.locationName)
        XCTAssertEqual(testee.address, TestConstants.locationAddress)
        XCTAssertEqual(testee.details, TestConstants.details)
    }

    func testEditModeInitialDates() {
        var testee: EditCalendarEventViewModel

        testee = makeEditViewModel(makeEvent(
            isAllDay: true,
            startAt: TestConstants.dateStart,
            endAt: TestConstants.dateStart.addHours(3)
        ))

        XCTAssertEqual(testee.isAllDay, true)
        XCTAssertEqual(testee.date, TestConstants.dateStart)
        XCTAssertEqual(testee.startTime, Date.make(year: 2024, month: 1, day: 1, hour: 15))
        XCTAssertEqual(testee.endTime, Date.make(year: 2024, month: 1, day: 1, hour: 16))

        testee = makeEditViewModel(makeEvent(
            isAllDay: false,
            startAt: TestConstants.dateStart,
            endAt: TestConstants.dateStart.addHours(3)
        ))

        XCTAssertEqual(testee.isAllDay, false)
        XCTAssertEqual(testee.date, TestConstants.dateStart)
        XCTAssertEqual(testee.startTime, TestConstants.dateStart)
        XCTAssertEqual(testee.endTime, TestConstants.dateStart.addHours(3))
    }

    func testEditModeInitialCalendar() {
        var testee: EditCalendarEventViewModel

        // existing course context
        testee = makeEditViewModel(makeEvent(context: .course("4")))
        XCTAssertEqual(testee.calendarName, "Course 4")

        // existing non-course context
        testee = makeEditViewModel(makeEvent(context: .user("3")))
        XCTAssertEqual(testee.calendarName, "User 3")

        // not existing context (should not happen)
        testee = makeEditViewModel(makeEvent(context: .course("not existing")))
        XCTAssertEqual(testee.calendarName, nil)
    }

    // MARK: - Save button enabling

    func testAddModeIsSaveButtonEnabled() {
        let testee = makeAddViewModel()

        // initial state, valid model (should not happen)
        eventInteractor.isRequestModelValidResult = true
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // initial state
        eventInteractor.isRequestModelValidResult = false
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // changed something, valid model
        testee.title = "some title"
        eventInteractor.isRequestModelValidResult = true
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // changed something, invalid model
        testee.title = "another title"
        eventInteractor.isRequestModelValidResult = false
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // reset to enabled
        eventInteractor.isRequestModelValidResult = true
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // start uploading details media
        testee.isUploading = true
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // reset to enabled (stop uploading)
        testee.isUploading = false
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // trigger saving state
        eventInteractor.createEventResult = nil
        testee.didTapSave.send()
        XCTAssertEqual(testee.isSaveButtonEnabled, false)
    }

    func testEditModeIsSaveButtonEnabledWhenTitleChanges() {
        let testee = makeEditViewModel(makeEvent(title: TestConstants.title))
        eventInteractor.isRequestModelValidResult = true

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

    func testEditModeIsSaveButtonEnabledWhenDateChanges() {
        let testee = makeEditViewModel(makeEvent(startAt: TestConstants.dateNow))
        eventInteractor.isRequestModelValidResult = true

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set the same value
        testee.date = TestConstants.dateNow
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set another value
        testee.date = TestConstants.dateStart
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // reset to initial value
        testee.date = TestConstants.dateNow
        XCTAssertEqual(testee.isSaveButtonEnabled, true)
    }

    func testEditModeIsSaveButtonEnabledWhenStartTimeChanges() {
        let testee = makeEditViewModel(makeEvent(isAllDay: false, startAt: TestConstants.dateNow))
        eventInteractor.isRequestModelValidResult = true

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set the same value
        testee.startTime = TestConstants.dateNow
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set another value
        testee.startTime = TestConstants.dateStart
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // reset to initial value
        testee.startTime = TestConstants.dateNow
        XCTAssertEqual(testee.isSaveButtonEnabled, true)
    }

    func testEditModeIsSaveButtonEnabledWhenEndTimeChanges() {
        let testee = makeEditViewModel(makeEvent(isAllDay: false, endAt: TestConstants.dateNow))
        eventInteractor.isRequestModelValidResult = true

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set the same value
        testee.endTime = TestConstants.dateNow
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set another value
        testee.endTime = TestConstants.dateStart
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // reset to initial value
        testee.endTime = TestConstants.dateNow
        XCTAssertEqual(testee.isSaveButtonEnabled, true)
    }

    func testEditModeIsSaveButtonEnabledWhenLocationChanges() {
        let testee = makeEditViewModel(makeEvent(locationName: TestConstants.locationName))
        eventInteractor.isRequestModelValidResult = true

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set the same value
        testee.location = TestConstants.locationName
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set another value
        testee.location = "another locationName"
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // reset to initial value
        testee.location = TestConstants.locationName
        XCTAssertEqual(testee.isSaveButtonEnabled, true)
    }

    func testEditModeIsSaveButtonEnabledWhenAddressChanges() {
        let testee = makeEditViewModel(makeEvent(locationAddress: TestConstants.locationAddress))
        eventInteractor.isRequestModelValidResult = true

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set the same value
        testee.address = TestConstants.locationAddress
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set another value
        testee.address = "another locationAddress"
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // reset to initial value
        testee.address = TestConstants.locationAddress
        XCTAssertEqual(testee.isSaveButtonEnabled, true)
    }

    func testEditModeIsSaveButtonEnabledWhenDetailChanges() {
        let testee = makeEditViewModel(makeEvent(details: TestConstants.details))
        eventInteractor.isRequestModelValidResult = true

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

    func testEditModeIsSaveButtonEnabledWhenCalendarChanges() {
        let testee = makeEditViewModel(makeEvent(context: TestConstants.calendars[0].context))
        eventInteractor.isRequestModelValidResult = true
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

        XCTAssertEqual(testee.pageTitle, String(localized: "New Event", bundle: .core))
        XCTAssertEqual(testee.saveButtonTitle, String(localized: "Add", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.title, String(localized: "Creation not completed", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.message, String(localized: "We couldn't add your Event at this time. You can try it again.", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.buttonTitle, String(localized: "OK", bundle: .core))
    }

    func testEditModeStrings() {
        let testee = makeEditViewModel(makeEvent())

        XCTAssertEqual(testee.pageTitle, String(localized: "Edit Event", bundle: .core))
        XCTAssertEqual(testee.saveButtonTitle, String(localized: "Save", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.title, String(localized: "Saving not completed", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.message, String(localized: "We couldn't save your Event at this time. You can try it again.", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.buttonTitle, String(localized: "OK", bundle: .core))
    }

    // MARK: - Did Tap Cancel

    func testDidTapCancel() {
        let testee = makeAddViewModel()

        testee.didTapCancel.send()

        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, .didCancel)
    }

    // MARK: - Did Tap Save (Add mode)

    func testAddModeDidTapAddCallsCreateEvent() {
        let testee = makeAddViewModel()
        testee.title = TestConstants.title
        testee.date = TestConstants.dateNow
        testee.isAllDay = true
        testee.startTime = TestConstants.dateStart
        testee.endTime = TestConstants.dateStart.addHours(3)
        testee.location = TestConstants.locationName
        testee.address = TestConstants.locationAddress
        testee.details = TestConstants.details

        let selectedCalendar = calendarListProviderInteractor.filters.value[1]
        testee.selectCalendarViewModel.selectedCalendar = selectedCalendar

        testee.didTapSave.send()

        XCTAssertEqual(eventInteractor.createEventCallsCount, 1)
        XCTAssertEqual(eventInteractor.updateEventCallsCount, 0)
        let model = eventInteractor.createEventInput
        XCTAssertEqual(model?.title, TestConstants.title)
        XCTAssertEqual(model?.date, TestConstants.dateNow)
        XCTAssertEqual(model?.isAllDay, true)
        XCTAssertEqual(model?.startTime, TestConstants.dateStart)
        XCTAssertEqual(model?.endTime, TestConstants.dateStart.addHours(3))
        XCTAssertEqual(model?.contextCode, selectedCalendar.rawContextID)
        XCTAssertEqual(model?.location, TestConstants.locationName)
        XCTAssertEqual(model?.address, TestConstants.locationAddress)
        XCTAssertEqual(model?.details, TestConstants.details)
    }

    // MARK: - Did Tap Save (Edit mode)

    func testEditModeDidTapSaveCallsUpdateToDo() {
        let testee = makeEditViewModel(makeEvent(
            id: TestConstants.id,
            title: TestConstants.title,
            isAllDay: false,
            startAt: TestConstants.dateStart,
            endAt: TestConstants.dateStart.addHours(3),
            locationName: TestConstants.locationName,
            locationAddress: TestConstants.locationAddress,
            details: TestConstants.details
        ))

        let selectedCalendar = calendarListProviderInteractor.filters.value[1]
        testee.selectCalendarViewModel.selectedCalendar = selectedCalendar

        testee.didTapSave.send()

        XCTAssertEqual(eventInteractor.createEventCallsCount, 0)
        XCTAssertEqual(eventInteractor.updateEventCallsCount, 1)
        let (id, model) = eventInteractor.updateEventInput ?? ("", .make())
        XCTAssertEqual(id, TestConstants.id)
        XCTAssertEqual(model.title, TestConstants.title)
        XCTAssertEqual(model.date, TestConstants.dateStart)
        XCTAssertEqual(model.isAllDay, false)
        XCTAssertEqual(model.startTime, TestConstants.dateStart)
        XCTAssertEqual(model.endTime, TestConstants.dateStart.addHours(3))
        XCTAssertEqual(model.contextCode, selectedCalendar.rawContextID)
        XCTAssertEqual(model.location, TestConstants.locationName)
        XCTAssertEqual(model.address, TestConstants.locationAddress)
        XCTAssertEqual(model.details, TestConstants.details)
    }

    // MARK: - Did Tap Save (common)

    func testDidTapSaveShowsLoadingOverlayWhileLoading() {
        let testee = makeAddViewModel()
        eventInteractor.createEventResult = nil

        testee.didTapSave.send()

        XCTAssertEqual(testee.state, .data(loadingOverlay: true))
    }

    func testDidTapSaveOnSuccess() {
        let testee = makeAddViewModel()
        eventInteractor.createEventResult = .success

        testee.didTapSave.send()

        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, .didUpdate)
    }

    func testDidTapSaveOnFailure() {
        let testee = makeAddViewModel()
        eventInteractor.createEventResult = .failure(MockError())

        testee.didTapSave.send()

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.shouldShowSaveError, true)
        XCTAssertEqual(completionCallsCount, 0)
    }

    func testRetryAfterFailure() {
        let testee = makeAddViewModel()
        eventInteractor.createEventResult = .failure(MockError())
        testee.didTapSave.send()

        eventInteractor.createEventResult = .success(())
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

    func testSelectCalendarViewModelHasOnlyUserAndGroupCalendars() {
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
        XCTAssertEqual(hasCourseCalendars, false)
        XCTAssertEqual(hasGroupCalendars, true)
    }

    func testShowCalendarScreen() {
        let sourceVC = UIViewController()
        let testee = makeAddViewModel()
        testee.showCalendarSelector.send(WeakViewController(sourceVC))

        guard let lastPresentation = router.viewControllerCalls.last else {
            return XCTFail()
        }
        XCTAssertTrue(lastPresentation.0 is CoreHostingController<SelectCalendarScreen>)
        XCTAssertEqual(lastPresentation.1, sourceVC)
        XCTAssertEqual(lastPresentation.2, .push)
    }

    func testSelectCalendarViewModelSelectsCalendar() {
        let testee = makeAddViewModel()

        XCTAssertEqual(testee.calendarName, TestConstants.calendars[3].name)

        let selectedCalendar = calendarListProviderInteractor.filters.value[1]
        testee.selectCalendarViewModel.selectedCalendar = selectedCalendar

        XCTAssertEqual(testee.calendarName, TestConstants.calendars[1].name)
    }

    // MARK: - Helpers

    private func makeAddViewModel(selectedDate: Date? = nil) -> EditCalendarEventViewModel {
        makeEditViewModel(nil, selectedDate: selectedDate)
    }

    private func makeEditViewModel(_ event: CalendarEvent?, selectedDate: Date? = nil) -> EditCalendarEventViewModel {
        .init(
            event: event,
            selectedDate: selectedDate,
            eventInteractor: eventInteractor,
            calendarListProviderInteractor: calendarListProviderInteractor,
            uploadParameters: .init(context: TestConstants.uploadContext),
            router: router,
            completion: { [weak self] in
                self?.completionValue = $0
                self?.completionCallsCount += 1
            }
        )
    }

    private func makeEvent(
        id: String = "",
        title: String = "",
        isAllDay: Bool = false,
        startAt: Date? = nil,
        endAt: Date? = nil,
        locationName: String? = nil,
        locationAddress: String? = nil,
        details: String? = nil,
        context: Context = .account("")
    ) -> CalendarEvent {
        let event = CalendarEvent.save(
            .make(
                id: .init(id),
                title: title,
                start_at: startAt,
                end_at: endAt,
                all_day: isAllDay,
                description: details,
                location_name: locationName,
                location_address: locationAddress
            ),
            in: databaseClient
        )
        event.context = context
        return event
    }
}

private struct MockError: Error { }
