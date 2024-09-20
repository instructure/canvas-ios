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
    private var testee: EditCalendarEventViewModel!

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
        testee = nil
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
        testee = makeAddViewModel()
        XCTAssertEqual(testee.date, TestConstants.dateNow.startOfDay())

        testee = makeAddViewModel(selectedDate: TestConstants.dateStart)
        XCTAssertEqual(testee.date, TestConstants.dateStart.startOfDay())
    }

    func testEditModeInitialValues() {
        testee = makeEditViewModel(makeEvent(
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
        testee = makeAddViewModel()

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
        testee = makeEditViewModel(makeEvent(title: TestConstants.title))
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
        testee = makeEditViewModel(makeEvent(startAt: TestConstants.dateNow))
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
        testee = makeEditViewModel(makeEvent(isAllDay: false, startAt: TestConstants.dateNow))
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
        testee = makeEditViewModel(makeEvent(isAllDay: false, endAt: TestConstants.dateNow))
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
        testee = makeEditViewModel(makeEvent(locationName: TestConstants.locationName))
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
        testee = makeEditViewModel(makeEvent(locationAddress: TestConstants.locationAddress))
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
        testee = makeEditViewModel(makeEvent(details: TestConstants.details))
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
        testee = makeEditViewModel(makeEvent(context: TestConstants.calendars[0].context))
        eventInteractor.isRequestModelValidResult = true

        // initial state
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set the same value
        triggerCalendarSelection(at: 0)
        XCTAssertEqual(testee.isSaveButtonEnabled, false)

        // set another value
        triggerCalendarSelection(at: 1)
        XCTAssertEqual(testee.isSaveButtonEnabled, true)

        // reset to initial value
        triggerCalendarSelection(at: 0)
        XCTAssertEqual(testee.isSaveButtonEnabled, true)
    }

    // MARK: - Strings

    func testAddModeStrings() {
        testee = makeAddViewModel()

        XCTAssertEqual(testee.pageTitle, String(localized: "New Event", bundle: .core))
        XCTAssertEqual(testee.saveButtonTitle, String(localized: "Add", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.title, String(localized: "Creation not completed", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.message, String(localized: "We couldn't add your Event at this time. You can try it again.", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.buttonTitle, String(localized: "OK", bundle: .core))
    }

    func testEditModeStrings() {
        testee = makeEditViewModel(makeEvent())

        XCTAssertEqual(testee.pageTitle, String(localized: "Edit Event", bundle: .core))
        XCTAssertEqual(testee.saveButtonTitle, String(localized: "Save", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.title, String(localized: "Saving not completed", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.message, String(localized: "We couldn't save your Event at this time. You can try it again.", bundle: .core))
        XCTAssertEqual(testee.saveErrorAlert.buttonTitle, String(localized: "OK", bundle: .core))
    }

    func testErrorMessage() {
        testee = makeAddViewModel()
        let defaultMessage = String(localized: "We couldn't add your Event at this time. You can try it again.", bundle: .core)

        // initial state
        XCTAssertEqual(testee.saveErrorAlert.message, defaultMessage)

        // after save fails with bad request
        eventInteractor.createEventResult = .failure(NSError.instructureError("some error", code: HttpError.badRequest))
        testee.didTapSave.send()
        XCTAssertEqual(testee.saveErrorAlert.message, "some error")

        // after save fails with other recognized HttpError
        eventInteractor.createEventResult = .failure(NSError.instructureError("another error", code: HttpError.notFound))
        testee.didTapSave.send()
        XCTAssertEqual(testee.saveErrorAlert.message, defaultMessage)

        // after save fails with other error
        eventInteractor.createEventResult = .failure(MockError())
        testee.didTapSave.send()
        XCTAssertEqual(testee.saveErrorAlert.message, defaultMessage)

        // after save succeeds
        eventInteractor.createEventResult = .success
        testee.didTapSave.send()
        XCTAssertEqual(testee.saveErrorAlert.message, defaultMessage)
    }

    // MARK: - Did Tap Cancel

    func testDidTapCancel() {
        testee = makeAddViewModel()

        testee.didTapCancel.send()

        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, .didCancel)
    }

    // MARK: - Did Tap Save (Add mode)

    func testAddModeDidTapAddCallsCreateEvent() {
        testee = makeAddViewModel()
        testee.title = TestConstants.title
        testee.date = TestConstants.dateNow
        testee.isAllDay = true
        testee.startTime = TestConstants.dateStart
        testee.endTime = TestConstants.dateStart.addHours(3)
        testee.location = TestConstants.locationName
        testee.address = TestConstants.locationAddress
        testee.details = TestConstants.details
        let selectedCalendar = triggerCalendarSelection()

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

    func testEditModeDidTapSaveCallsUpdateEvent() {
        testee = makeEditViewModel(makeEvent(
            id: TestConstants.id,
            title: TestConstants.title,
            isAllDay: false,
            startAt: TestConstants.dateStart,
            endAt: TestConstants.dateStart.addHours(3),
            locationName: TestConstants.locationName,
            locationAddress: TestConstants.locationAddress,
            details: TestConstants.details
        ))
        let selectedCalendar = triggerCalendarSelection()

        testee.didTapSave.send()

        XCTAssertEqual(eventInteractor.createEventCallsCount, 0)
        XCTAssertEqual(eventInteractor.updateEventCallsCount, 1)
        let (id, model, _) = eventInteractor.updateEventInput ?? ("", .make(), nil)
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

    func testEditModeDidTapSaveCallsUpdateEventWithSelectedConfirmationOption() {
        testee = makeEditViewModel(makeEvent(repetitionRule: "some", seriesInNaturalLanguage: "thing"))
        triggerCalendarSelection()

        testee.didTapSave.send()
        testee.editConfirmation.notifyCompletion(option: .following)

        let (_, _, seriesModificationType) = eventInteractor.updateEventInput ?? ("", .make(), nil)
        XCTAssertEqual(seriesModificationType, .following)
    }

    // MARK: - Did Tap Save (common)

    func testDidTapSaveShowsLoadingOverlayWhileLoading() {
        testee = makeAddViewModel()
        eventInteractor.createEventResult = nil

        testee.didTapSave.send()

        XCTAssertEqual(testee.state, .data(loadingOverlay: true))
    }

    func testDidTapSaveOnSuccess() {
        testee = makeAddViewModel()
        eventInteractor.createEventResult = .success

        testee.didTapSave.send()

        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertEqual(completionValue, .didUpdate)
    }

    func testDidTapSaveOnFailure() {
        testee = makeAddViewModel()
        eventInteractor.createEventResult = .failure(MockError())

        testee.didTapSave.send()

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.shouldShowSaveError, true)
        XCTAssertEqual(completionCallsCount, 0)
    }

    func testRetryAfterFailure() {
        testee = makeAddViewModel()
        eventInteractor.createEventResult = .failure(MockError())
        testee.didTapSave.send()

        eventInteractor.createEventResult = .success(())
        testee.didTapSave.send()

        XCTAssertEqual(completionCallsCount, 1)
    }

    // MARK: - Edit Confirmation

    func testShouldShowEditConfirmationInAddMode() {
        testee = makeAddViewModel()

        XCTAssertEqual(testee.shouldShowEditConfirmation, false)

        testee.didTapSave.send()
        XCTAssertEqual(testee.shouldShowEditConfirmation, false)
        XCTAssertEqual(testee.state, .data(loadingOverlay: true))
    }

    func testShouldShowEditConfirmationInEditModeForSingleEvent() {
        testee = makeEditViewModel(makeEvent())

        XCTAssertEqual(testee.shouldShowEditConfirmation, false)

        testee.didTapSave.send()
        XCTAssertEqual(testee.shouldShowEditConfirmation, false)
        XCTAssertEqual(testee.state, .data(loadingOverlay: true))
    }

    func testShouldShowEditConfirmationInEditModeForRecurringEvent() {
        testee = makeEditViewModel(makeEvent(repetitionRule: "some", seriesInNaturalLanguage: "thing"))

        XCTAssertEqual(testee.shouldShowEditConfirmation, false)

        testee.didTapSave.send()
        XCTAssertEqual(testee.shouldShowEditConfirmation, true)
        XCTAssertEqual(testee.state, .data(loadingOverlay: false))

        testee.editConfirmation.notifyCompletion(option: .one)
        XCTAssertEqual(testee.state, .data(loadingOverlay: true))
    }

    func testEditConfirmationOptionsWhenEventIsSeriesHead() {
        testee = makeEditViewModel(makeEvent(
            repetitionRule: "some",
            isSeriesHead: true,
            seriesInNaturalLanguage: "thing"
        ))

        guard testee.editConfirmation.confirmButtons.count == 2 else {
            XCTFail("Invalid count")
            return
        }

        XCTAssertEqual(testee.editConfirmation.confirmButtons[0].option, .one)
        XCTAssertEqual(testee.editConfirmation.confirmButtons[1].option, .all)
    }

    func testEditConfirmationOptionsWhenEventIsNotSeriesHead() {
        testee = makeEditViewModel(makeEvent(
            repetitionRule: "some",
            isSeriesHead: false,
            seriesInNaturalLanguage: "thing"
        ))

        guard testee.editConfirmation.confirmButtons.count == 3 else {
            XCTFail("Invalid count")
            return
        }

        XCTAssertEqual(testee.editConfirmation.confirmButtons[0].option, .one)
        XCTAssertEqual(testee.editConfirmation.confirmButtons[1].option, .all)
        XCTAssertEqual(testee.editConfirmation.confirmButtons[2].option, .following)
    }

    // MARK: - EndTime Error

    func testEndTimeError() {
        testee = makeAddViewModel()

        testee.startTime = TestConstants.dateStart
        testee.endTime = nil
        XCTAssertNil(testee.endTimeErrorMessage)

        testee.startTime = nil
        testee.endTime = TestConstants.dateStart
        XCTAssertNil(testee.endTimeErrorMessage)

        testee.startTime = TestConstants.dateStart
        testee.endTime = TestConstants.dateStart
        XCTAssertNil(testee.endTimeErrorMessage)

        testee.startTime = TestConstants.dateStart
        testee.endTime = TestConstants.dateStart.addHours(1)
        XCTAssertNil(testee.endTimeErrorMessage)

        testee.startTime = TestConstants.dateStart
        testee.endTime = TestConstants.dateStart.addHours(-1)
        XCTAssertNotNil(testee.endTimeErrorMessage)
    }

    // MARK: - Select Calendar

    func testSelectCalendarViewModelReusesSameInteractor() {
        testee = makeAddViewModel()
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
        testee = makeAddViewModel()
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
        testee = makeAddViewModel()
        testee.showCalendarSelector.send(WeakViewController(sourceVC))

        guard let lastPresentation = router.viewControllerCalls.last else {
            return XCTFail()
        }
        XCTAssertTrue(lastPresentation.0 is CoreHostingController<SelectCalendarScreen>)
        XCTAssertEqual(lastPresentation.1, sourceVC)
        XCTAssertEqual(lastPresentation.2, .push)
    }

    func testSelectCalendarViewModelSelectsCalendar() {
        testee = makeAddViewModel()

        XCTAssertEqual(testee.calendarName, TestConstants.calendars[3].name)

        triggerCalendarSelection(at: 1)

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
        repetitionRule: String? = nil,
        isSeriesHead: Bool? = nil,
        seriesInNaturalLanguage: String? = nil,
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
                location_address: locationAddress,
                rrule: repetitionRule,
                series_head: isSeriesHead,
                series_natural_language: seriesInNaturalLanguage
            ),
            in: databaseClient
        )
        event.context = context
        return event
    }

    @discardableResult
    private func triggerCalendarSelection(at index: Int = 1) -> CDCalendarFilterEntry {
        let selectedCalendar = calendarListProviderInteractor.filters.value[index]
        testee.selectCalendarViewModel.selectedCalendar = selectedCalendar
        return selectedCalendar
    }
}

private struct MockError: Error { }
