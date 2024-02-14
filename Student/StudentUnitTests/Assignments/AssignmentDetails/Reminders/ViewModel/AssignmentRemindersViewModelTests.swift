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
        let interactor = AssignmentRemindersInteractorLive(notificationCenter: MockUserNotificationCenter())
        let testee = AssignmentRemindersViewModel(interactor: interactor, router: router)
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
}

class AssignmentRemindersInteractorMock: AssignmentRemindersInteractor {
    let newReminderCreationResult = PassthroughSubject<Student.NewReminderResult, Never>()
    let isRemindersSectionVisible = CurrentValueSubject<Bool, Never>(true)
    let reminders = CurrentValueSubject<[AssignmentReminderItem], Never>([])
    let contextDidUpdate = CurrentValueSubject<Student.AssignmentReminderContext?, Never>(nil)
    let newReminderDidSelect = PassthroughSubject<DateComponents, Never>()
    let reminderDidDelete = PassthroughSubject<AssignmentReminderItem, Never>()
}
