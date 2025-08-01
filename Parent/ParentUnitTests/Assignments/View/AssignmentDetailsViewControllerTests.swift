//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Parent
import TestsFoundation

class AssignmentDetailsViewControllerTests: ParentTestCase {
    lazy var controller = AssignmentDetailsViewController.create(
        studentID: "1",
        courseID: "1",
        assignmentID: "1",
        userNotificationCenter: notificationCenter,
        env: env
    )
    let url = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
    let dueAt = Clock.now.addDays(2).startOfDay()

    override func setUp() {
        super.setUp()
        api.mock(controller.assignment, value: .make(due_at: dueAt, html_url: url))
        api.mock(controller.course, value: .make())
        api.mock(controller.student, value: [.make()])
        api.mock(controller.teachers, value: [.make(id: "2", name: "t1")])
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, ColorScheme.observee("1").color.hexString)
        XCTAssertEqual(controller.title, "Course One")
        XCTAssertEqual(controller.titleLabel.text, "some assignment")
        XCTAssertEqual(controller.dateLabel.text, dueAt.dateTimeString)
        XCTAssertEqual(controller.reminderHeadingLabel.text, "Remind Me")
        XCTAssertEqual(controller.reminderMessageLabel.text, "Set a date and time to be notified of this event.")
        XCTAssertEqual(controller.reminderSwitch.isOn, false)
        XCTAssertEqual(controller.reminderDateButton.isHidden, true)
        XCTAssertFalse(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)

        api.mock(controller.assignment, value: .make(description: "", due_at: nil, html_url: url))
        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.dateLabel.text, "No Due Date")
        XCTAssertEqual(controller.descriptionView.isHidden, true)

        controller.composeButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.presented is CoreHostingController<ComposeMessageView>)
    }

    func testScoreLayoutWhenQuantitativeDataDisabled() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.pointsLabel.text, "10 pts")
    }

    func testScoreLayoutWhenQuantitativeDataEnabled() {
        api.mock(controller.course, value: .make(settings: .make(restrict_quantitative_data: true)))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.pointsLabel.text, " ")
    }

    func testReminder() {
        let localNotifications = LocalNotificationsInteractor(notificationCenter: notificationCenter)
        let prev = Clock.now.startOfDay().addDays(1)
        localNotifications.setReminder(id: "1", content: UNMutableNotificationContent(), at: prev) { _ in }
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.reminderHeadingLabel.text, "Remind Me")
        XCTAssertEqual(controller.reminderMessageLabel.text, "Set a date and time to be notified of this event.")
        XCTAssertEqual(controller.reminderSwitch.isOn, true)
        XCTAssertEqual(controller.reminderDateButton.isHidden, false)
        XCTAssertEqual(controller.reminderDateButton.title(for: .normal), prev.dateTimeString)
        XCTAssertFalse(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)

        controller.reminderDateButton.sendActions(for: .touchUpInside)
        XCTAssertTrue(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)
        XCTAssertEqual(controller.selectedDate, prev)

        controller.reminderDateChanged(selectedDate: prev.addDays(1))
        localNotifications.getReminder("1") { request in
            let date = (request?.trigger as? UNCalendarNotificationTrigger).flatMap {
                Calendar.current.date(from: $0.dateComponents)
            }
            XCTAssertEqual(date, prev.addDays(1))
        }
        notificationCenter.error = NSError.internalError()
        controller.reminderDateChanged(selectedDate: controller.selectedDate)
        XCTAssertEqual(controller.reminderSwitch.isOn, false)

        notificationCenter.authorized = false
        controller.reminderSwitch.isOn = true
        controller.reminderSwitch.sendActions(for: .valueChanged)
        XCTAssertEqual(controller.reminderSwitch.isOn, false)
        XCTAssertEqual((router.presented as? UIAlertController)?.title, "Permission Needed")

        controller.reminderSwitch.isOn = false
        controller.reminderSwitch.sendActions(for: .valueChanged)
        XCTAssertEqual(controller.reminderDateButton.isHidden, true)
        XCTAssertFalse(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)

        notificationCenter.authorized = true
        notificationCenter.error = nil
        controller.reminderSwitch.isOn = true
        controller.reminderSwitch.sendActions(for: .valueChanged)
        XCTAssertFalse(controller.reminderDateButton.isHidden)
        controller.reminderDateButtonPressed(UIButton())
        XCTAssertTrue(router.presented is CoreHostingController<CoreDatePickerActionSheetCard>)
    }

    func testSubmissionAndRubricButtonPresentsSubmissionViewer() {
        api.mock(controller.assignment, value: .make(description: "", due_at: nil, html_url: url))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        // WHEN
        controller.submissionAndRubricButtonPressed(self)

        // THEN
        let presentation = router.viewControllerCalls.last
        XCTAssertTrue(presentation?.0 is ParentSubmissionViewController)
        XCTAssertEqual(presentation?.1, controller)
        XCTAssertEqual(presentation?.2, .modal(.overFullScreen))
    }

    func testUsesSubmissionInteractorForSubmissionPresentation() {
        let submissionURLInteractorMock = ParentSubmissionURLInteractorMock()
        let testee = AssignmentDetailsViewController.create(
            studentID: "1",
            courseID: "1",
            assignmentID: "1",
            userNotificationCenter: notificationCenter,
            submissionURLInteractor: submissionURLInteractorMock,
            env: env
        )
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(submissionURLInteractorMock.isSubmissionURLCalled, false)

        // WHEN
        testee.submissionAndRubricButtonPressed(self)

        // THEN
        XCTAssertEqual(submissionURLInteractorMock.isSubmissionURLCalled, true)
    }
}

class ParentSubmissionURLInteractorMock: ParentSubmissionURLInteractor {
    var isSubmissionURLCalled = false

    func submissionURL(
        assignmentHtmlURL: URL,
        observedUserID: String,
        isAssignmentEnhancementsEnabled: Bool
    ) -> URL {
        isSubmissionURLCalled = true
        return .make("/submissionURL")
    }
}
