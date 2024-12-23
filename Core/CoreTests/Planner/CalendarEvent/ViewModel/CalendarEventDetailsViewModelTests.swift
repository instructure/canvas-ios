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
import Combine
import XCTest

class CalendarEventDetailsViewModelTests: CoreTestCase {

    private var event: CalendarEvent!
    private var contextColor: UIColor!
    private var interactor: CalendarEventInteractorPreview!

    override func setUp() {
        super.setUp()
        let event: CalendarEvent = databaseClient.insert()
        self.event = event
        contextColor = .red
        interactor = .init()
        interactor.getCalendarEventResult = .success((event, contextColor))
    }

    override func tearDown() {
        event = nil
        contextColor = nil
        interactor = nil
        super.tearDown()
    }

    // MARK: - Fields

    func testEventDateFormatting() {
        let startDate = Date(timeIntervalSince1970: 0)
        let endDate = startDate.inCalendar.addMinutes(60)

        event.isAllDay = true
        event.startAt = startDate
        let testee = makeViewModel()
        var expectedDate = startDate.dateOnlyString
        XCTAssertTrue(testee.date!.hasPrefix("\(expectedDate)\n"))

        event.isAllDay = false
        event.startAt = startDate
        event.endAt = endDate
        testee.reload {}
        expectedDate = startDate.intervalStringTo(endDate)
        XCTAssertTrue(testee.date!.hasPrefix("\(expectedDate)\n"))

        event.isAllDay = false
        event.startAt = startDate
        event.endAt = nil
        testee.reload {}
        expectedDate = startDate.dateTimeString
        XCTAssertTrue(testee.date!.hasPrefix("\(expectedDate)\n"))
    }

    func testEventSeriesInfo() {
        let startDate = Date(timeIntervalSince1970: 0)

        event.startAt = startDate
        let testee = makeViewModel()
        XCTAssertTrue(testee.date!.hasSuffix("\nDoes Not Repeat"))

        event.seriesInNaturalLanguage = "Weekly"
        testee.reload {}
        XCTAssertTrue(testee.date!.hasSuffix("\nRepeats Weekly"))
    }

    func testLocationInfo() {
        event.locationName = "test location"
        event.locationAddress = "test address"
        let testee = makeViewModel()
        XCTAssertEqual(testee.locationInfo, [
            .init(
                title: "Location",
                description: "test location",
                isRichContent: false
            ),
            .init(
                title: "Address",
                description: "test address",
                isRichContent: false
            )
        ])

        event.locationName = ""
        event.locationAddress = "test address"
        testee.reload {}
        XCTAssertEqual(testee.locationInfo, [
            .init(
                title: "Address",
                description: "test address",
                isRichContent: false
            )
        ])

        event.locationName = "test location"
        event.locationAddress = ""
        testee.reload {}
        XCTAssertEqual(testee.locationInfo, [
            .init(
                title: "Location",
                description: "test location",
                isRichContent: false
            )
        ])
    }

    func testEventDetails() {
        event.details = "test details"

        let testee = makeViewModel()

        XCTAssertEqual(testee.details, .init(title: "Details",
                                             description: "test details",
                                             isRichContent: true))
    }

    // MARK: - Properties

    func testOtherProperties() {
        event.title = "test title"
        event.contextName = "test context"

        let testee = makeViewModel()

        XCTAssertEqual(testee.pageTitle, "Event Details")
        XCTAssertEqual(testee.pageSubtitle, "test context")
        XCTAssertEqual(testee.contextColor, contextColor)
        XCTAssertEqual(testee.title, "test title")
        XCTAssertEqual(testee.pageViewEvent, .init(eventName: "/calendar"))
    }

    func testStates() {
        let testee = makeViewModel()
        XCTAssertEqual(testee.state, .data)

        interactor.getCalendarEventResult = .failure(NSError.internalError())
        testee.reload {}
        XCTAssertEqual(testee.state, .error)
    }

    func testIsMoreButtonEnabled() {
        let testee = makeViewModel()
        XCTAssertEqual(testee.isMoreButtonEnabled, true)

        interactor.getCalendarEventResult = .failure(NSError.internalError())
        testee.reload {}
        XCTAssertEqual(testee.isMoreButtonEnabled, false)
    }

    func testShouldShowMenuButton() {
        let testee = makeViewModel(userId: "42")

        // current user's calendar
        event.context = .user("42")
        testee.reload {}
        XCTAssertEqual(interactor.getCanManageCalendarPermissionCallsCount, 0)
        XCTAssertEqual(testee.shouldShowMenuButton, true)

        // another user's calendar (should not happen)
        event.context = .user("1")
        testee.reload {}
        XCTAssertEqual(testee.shouldShowMenuButton, false)
        XCTAssertEqual(interactor.getCanManageCalendarPermissionCallsCount, 0)

        // non user/course/group calendar (should not happen)
        event.context = .account("1")
        testee.reload {}
        XCTAssertEqual(testee.shouldShowMenuButton, false)
        XCTAssertEqual(interactor.getCanManageCalendarPermissionCallsCount, 0)

        // course calendar, with permission
        event.context = .course("1")
        interactor.getCanManageCalendarPermissionResult = .success(true)
        testee.reload {}
        XCTAssertEqual(testee.shouldShowMenuButton, true)
        XCTAssertEqual(interactor.getCanManageCalendarPermissionInput?.context, .course("1"))
        XCTAssertEqual(interactor.getCanManageCalendarPermissionInput?.ignoreCache, true)

        // course calendar, without permission
        event.context = .course("1")
        interactor.getCanManageCalendarPermissionResult = .success(false)
        testee.reload {}
        XCTAssertEqual(testee.shouldShowMenuButton, false)

        // group calendar, with permission
        event.context = .group("1")
        interactor.getCanManageCalendarPermissionResult = .success(true)
        testee.reload {}
        XCTAssertEqual(testee.shouldShowMenuButton, true)
        XCTAssertEqual(interactor.getCanManageCalendarPermissionInput?.context, .group("1"))
        XCTAssertEqual(interactor.getCanManageCalendarPermissionInput?.ignoreCache, true)

        // group calendar, without permission
        event.context = .group("1")
        interactor.getCanManageCalendarPermissionResult = .success(false)
        testee.reload {}
        XCTAssertEqual(testee.shouldShowMenuButton, false)
    }

    func testGetCanManageCalendarPermissionFailureHandling() {
        event.context = .user("42")
        let testee = makeViewModel(userId: "42")
        XCTAssertEqual(testee.shouldShowMenuButton, true)

        // on failure set to false
        event.context = .course("1")
        interactor.getCanManageCalendarPermissionResult = .failure(NSError.internalError())
        testee.reload {}
        XCTAssertEqual(testee.shouldShowMenuButton, false)

        // on reload with success set to result
        interactor.getCanManageCalendarPermissionResult = .success(true)
        testee.reload {}
        XCTAssertEqual(testee.shouldShowMenuButton, true)
    }

    // MARK: - Did Tap Edit

    func testDidTapEdit() {
        let sourceVC = UIViewController()
        let testee = makeViewModel()
        testee.didTapEdit.send(WeakViewController(sourceVC))

        guard let lastPresentation = router.viewControllerCalls.last else {
            return XCTFail()
        }
        XCTAssertTrue(lastPresentation.0 is CoreHostingController<EditCalendarEventScreen>)
        XCTAssertEqual(lastPresentation.1, sourceVC)
        XCTAssertEqual(lastPresentation.2, .modal(isDismissable: false, embedInNav: true))

        XCTAssertEqual(testee.shouldShowDeleteConfirmation, false)
    }

    // MARK: - Did Tap Delete

    func testDidTapDelete() {
        let testee = makeViewModel()
        testee.didTapDelete.send(.init())

        XCTAssertEqual(testee.shouldShowDeleteConfirmation, true)
        XCTAssertEqual(testee.shouldShowDeleteError, false)
        XCTAssertEqual(interactor.deleteEventCallsCount, 0)

        testee.deleteConfirmation.notifyCompletion(option: .one)
        XCTAssertEqual(interactor.deleteEventCallsCount, 1)
        XCTAssertEqual(testee.state, .data(loadingOverlay: true))
        XCTAssertEqual(testee.isMoreButtonEnabled, false)
    }

    func testDeleteConfirmation() {
        let testee = makeViewModel()

        updateEventAsPartOfSeries(false)
        testee.reload {}
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons.count, 1)
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons.first?.title, "Delete")
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons.first?.option, .one)
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons.first?.buttonRole, .destructive)

        updateEventAsPartOfSeries(true)
        event.isSeriesHead = true
        testee.reload {}
        guard testee.deleteConfirmation.confirmButtons.count == 2 else {
            XCTFail("Invalid confirm button count")
            return
        }
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[0].title, "Delete this event")
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[1].title, "Delete all events")
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[0].option, .one)
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[1].option, .all)
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[0].buttonRole, .destructive)
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[1].buttonRole, .destructive)

        updateEventAsPartOfSeries(true)
        event.isSeriesHead = false
        testee.reload {}
        guard testee.deleteConfirmation.confirmButtons.count == 3 else {
            XCTFail("Invalid confirm button count")
            return
        }
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[0].title, "Delete this event")
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[1].title, "Delete all events")
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[2].title, "Delete this and all following events")
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[0].option, .one)
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[1].option, .all)
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[2].option, .following)
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[0].buttonRole, .destructive)
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[1].buttonRole, .destructive)
        XCTAssertEqual(testee.deleteConfirmation.confirmButtons[2].buttonRole, .destructive)
    }

    func testDeleteEventOnSuccess() {
        interactor.deleteEventResult = .success
        let testee = makeViewModel()

        let sourceVC = UIViewController()
        testee.didTapDelete.send(WeakViewController(sourceVC))
        testee.deleteConfirmation.notifyCompletion(option: .one)

        XCTAssertEqual(router.popped, sourceVC)
    }

    func testDeleteEventOnFailure() {
        interactor.deleteEventResult = .failure(NSError.internalError())
        let testee = makeViewModel()

        testee.didTapDelete.send(.init())
        testee.deleteConfirmation.notifyCompletion(option: .one)

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.isMoreButtonEnabled, true)
        XCTAssertEqual(testee.shouldShowDeleteError, true)
        XCTAssertEqual(router.popped, nil)
    }

    // MARK: - Helpers

    private func makeViewModel(eventId: String = "1", userId: String = "") -> CalendarEventDetailsViewModel {
        .init(eventId: eventId, userId: userId, interactor: interactor, router: router, completion: nil)
    }

    private func updateEventAsPartOfSeries(_ isPart: Bool) {
        event.repetitionRule = isPart ? "something" : nil
        event.seriesInNaturalLanguage = "anything"
    }
}
