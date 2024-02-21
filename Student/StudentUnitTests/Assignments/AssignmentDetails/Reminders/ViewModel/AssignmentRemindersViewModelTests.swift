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
import Student
import TestsFoundation
import XCTest

class AssignmentRemindersViewModelTests: StudentTestCase {
    private var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func testNewReminderTapOpensTimePicker() {
        let testee = AssignmentRemindersViewModel(interactor: AssignmentRemindersInteractorMock(), router: router)
        let hostView = UIViewController()

        // WHEN
        testee.newReminderDidTap(view: hostView)

        // THEN
        guard let lastPresentation = router.viewControllerCalls.last else {
            return XCTFail()
        }
        XCTAssertTrue(lastPresentation.0 is CoreHostingController<AssignmentReminderDatePickerView>)
        XCTAssertEqual(lastPresentation.1, hostView)
        XCTAssertEqual(lastPresentation.2, .modal(isDismissable: false, embedInNav: true))
    }

    func testReminderDelete() {
        let interactorMock = AssignmentRemindersInteractorMock()
        let itemToDelete = AssignmentReminderItem(title: "test")
        let testee = AssignmentRemindersViewModel(interactor: interactorMock, router: router)
        let deleteReceived = expectation(description: "Delete event received")
        interactorMock
            .reminderDidDelete
            .sink {
                deleteReceived.fulfill()
                XCTAssertEqual($0, itemToDelete)
            }
            .store(in: &subscriptions)

        // WHEN
        testee.reminderDeleteDidTap(itemToDelete)
        testee.confirmAlert.notifyCompletion(isConfirmed: true)

        // THEN
        waitForExpectations(timeout: 1)
    }

    func testErrorAlerts() {
        let interactorMock = AssignmentRemindersInteractorMock()
        let testee = AssignmentRemindersViewModel(interactor: interactorMock, router: router, scheduler: .immediate)
        let newReminderView = UIViewController()
        testee.newReminderDidTap(view: newReminderView)

        interactorMock.newReminderCreationResult.send(.failure(.reminderInPast))
        var alert = router.last as? UIAlertController
        XCTAssertEqual(alert?.title, String(localized: "Reminder Creation Failed"))
        XCTAssertEqual(alert?.message, String(localized: "Please choose a future time for your reminder!"))

        interactorMock.newReminderCreationResult.send(.failure(.duplicate))
        alert = router.last as? UIAlertController
        XCTAssertEqual(alert?.title, String(localized: "Reminder Creation Failed"))
        XCTAssertEqual(alert?.message, String(localized: "You have already set a reminder for this time."))

        interactorMock.newReminderCreationResult.send(.failure(.scheduleFailed))
        alert = router.last as? UIAlertController
        XCTAssertEqual(alert?.title, String(localized: "Reminder Creation Failed"))
        XCTAssertEqual(alert?.message, String(localized: "An unknown error occurred."))

        interactorMock.newReminderCreationResult.send(.failure(.application))
        alert = router.last as? UIAlertController
        XCTAssertEqual(alert?.title, String(localized: "Reminder Creation Failed"))
        XCTAssertEqual(alert?.message, String(localized: "An unknown error occurred."))

        interactorMock.newReminderCreationResult.send(.failure(.noPermission))
        alert = router.last as? UIAlertController
        XCTAssertEqual(alert?.title, String(localized: "Permission Needed"))
        XCTAssertEqual(alert?.message, String(localized: "You must allow notifications in Settings to set reminders."))
        XCTAssertEqual(alert?.actions[0].title, String(localized: "Settings"))
        XCTAssertEqual(alert?.actions[0].style, .default)
        XCTAssertEqual(alert?.actions[1].title, String(localized: "Cancel"))
        XCTAssertEqual(alert?.actions[1].style, .cancel)
    }

    func testDismissesTimePickerAfterNewReminderCreation() {
        let interactorMock = AssignmentRemindersInteractorMock()
        let testee = AssignmentRemindersViewModel(interactor: interactorMock, router: router, scheduler: .immediate)
        let newReminderView = UIViewController()
        testee.newReminderDidTap(view: newReminderView)
        let pickerView = router.lastViewController
        XCTAssertNotNil(pickerView)

        // WHEN
        interactorMock.newReminderCreationResult.send(.success(()))

        // THEN
        XCTAssertEqual(router.dismissed, pickerView)
    }
}

class AssignmentRemindersInteractorMock: AssignmentRemindersInteractor {
    let newReminderCreationResult = PassthroughSubject<Student.NewReminderResult, Never>()
    let isRemindersSectionVisible = CurrentValueSubject<Bool, Never>(true)
    let reminders = CurrentValueSubject<[AssignmentReminderItem], Never>([])
    let contextDidUpdate = CurrentValueSubject<AssignmentReminderContext?, Never>(nil)
    let newReminderDidSelect = PassthroughSubject<DateComponents, Never>()
    let reminderDidDelete = PassthroughSubject<AssignmentReminderItem, Never>()

    func deleteAllReminders(userId: String) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }
}
