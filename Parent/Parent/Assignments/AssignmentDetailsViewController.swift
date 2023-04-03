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

import Foundation
import UIKit
import UserNotifications
import Core
import SwiftUI

class AssignmentDetailsViewController: UIViewController, CoreWebViewLinkDelegate {
    @IBOutlet weak var composeButton: FloatingButton!
    @IBOutlet weak var dateHeadingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionHeadingLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var reminderDateButton: UIButton!
    @IBOutlet weak var reminderHeadingLabel: UILabel!
    @IBOutlet weak var reminderMessageLabel: UILabel!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var statusIconView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webViewContainer: UIView!
    let webView = CoreWebView()
    let refreshControl = CircleRefreshControl()
    var selectedDate: Date?
    var assignmentID = ""
    var courseID = ""
    let env = AppEnvironment.shared
    var studentID = ""
    private var minDate = Clock.now
    private var maxDate = Clock.now

    lazy var assignment = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [.observed_users, .submission])) {  [weak self] in
        self?.update()
    }
    lazy var course = env.subscribe(GetCourse(courseID: courseID)) {  [weak self] in
        self?.update()
    }
    lazy var student = env.subscribe(GetSearchRecipients(context: .course(courseID), userID: studentID)) { [weak self] in
        self?.update()
    }
    lazy var teachers = env.subscribe(GetSearchRecipients(context: .course(courseID), qualifier: .teachers)) { [weak self] in
        self?.update()
    }

    static func create(studentID: String, courseID: String, assignmentID: String) -> AssignmentDetailsViewController {
        let controller = loadFromStoryboard()
        controller.assignmentID = assignmentID
        controller.courseID = courseID
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        title = NSLocalizedString("Assignment Details", comment: "")
        webViewContainer.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: webViewContainer)
        webView.autoresizesHeight = true
        webView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        webView.linkDelegate = self

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        scrollView.refreshControl = refreshControl

        composeButton.accessibilityLabel = NSLocalizedString("Compose message to teachers", comment: "")
        composeButton.backgroundColor = ColorScheme.observee(studentID).color.darkenToEnsureContrast(against: .white)
        composeButton.isHidden = true

        dateHeadingLabel.text = NSLocalizedString("Due", comment: "")
        dateLabel.text = ""
        descriptionHeadingLabel.text = NSLocalizedString("Description", comment: "")
        titleLabel.text = ""

        pointsLabel.text = ""

        reminderHeadingLabel.text = NSLocalizedString("Remind Me", comment: "")
        reminderMessageLabel.text = NSLocalizedString("Set a date and time to be notified of this event.", comment: "")
        reminderSwitch.accessibilityLabel = NSLocalizedString("Remind Me", comment: "")
        reminderSwitch.isEnabled = false
        reminderDateButton.isEnabled = false
        reminderDateButton.isHidden = true
        reminderDateButton.setTitleColor(Brand.shared.primary, for: .normal)

        statusLabel.text = ""

        assignment.refresh()
        course.refresh()
        student.refresh()
        teachers.refresh()
        NotificationManager.shared.getReminder(assignmentID) { [weak self] request in performUIUpdate {
            guard let self = self else { return }
            let date = (request?.trigger as? UNCalendarNotificationTrigger).flatMap {
                Calendar.current.date(from: $0.dateComponents)
            }
            if let date = date {
                self.selectedDate = date
                self.reminderSwitch.isOn = true
                self.reminderDateButton.setTitle(date.dateTimeString, for: .normal)
                self.reminderDateButton.isHidden = false
            }
        } }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let color = ColorScheme.observee(studentID).color
        navigationController?.navigationBar.useContextColor(color)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @objc func refresh() {
        assignment.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
        course.refresh(force: true)
        student.refresh(force: true)
        teachers.refresh(force: true)
    }

    func update() {
        guard let assignment = assignment.first else { return }
        let status = assignment.submissions?.first(where: { $0.userID == studentID })?.status ?? .notSubmitted
        title = course.first?.name ?? NSLocalizedString("Assignment Details", comment: "")

        titleLabel.text = assignment.name
        pointsLabel.text = assignment.pointsPossibleText
        statusIconView.isHidden = assignment.submissionStatusIsHidden
        statusIconView.image = status.icon
        statusIconView.tintColor = status.color
        statusLabel.isHidden = assignment.submissionStatusIsHidden
        statusLabel.textColor = status.color
        statusLabel.text = status.text
        dateLabel.text = assignment.dueAt?.dateTimeString ?? NSLocalizedString("No Due Date", comment: "")
        reminderSwitch.isEnabled = true
        reminderDateButton.isEnabled = true
        if let html = assignment.details, !html.isEmpty {
            descriptionView.isHidden = false
            webView.loadHTMLString(html, baseURL: assignment.htmlURL)
        } else {
            descriptionView.isHidden = true
        }
        composeButton.isHidden = teachers.isEmpty || student.isEmpty
    }

    func reminderDateChanged(selectedDate: Date?) {
        guard let selectedDate = selectedDate, let assignment = assignment.first else { return }
        NotificationManager.shared.setReminder(for: assignment, at: selectedDate, studentID: studentID) { error in performUIUpdate { [self] in
            if error == nil {
                reminderDateButton.setTitle(selectedDate.dateTimeString, for: .normal)
                self.selectedDate = selectedDate
            } else {
                reminderSwitch.setOn(false, animated: true)
                reminderSwitchChanged()
            }
        } }
    }

    @IBAction func reminderSwitchChanged() {
        guard let assignment = assignment.first else { return }
        if reminderSwitch.isOn {
            reminderDateButton.isHidden = false
            minDate = Clock.now.addMinutes(1)
            maxDate = Clock.now.addYears(1)
            let defaultDate = max(minDate, min(maxDate,
                assignment.dueAt?.addDays(-1) ?? Clock.now.addDays(1)
            ))
            NotificationManager.shared.requestAuthorization(options: [.alert, .sound]) { success, error in performUIUpdate {
                guard error == nil && success else {
                    self.reminderSwitch.setOn(false, animated: true)
                    return self.showPermissionError(.notifications)
                }
                self.reminderDateButton.setTitle(defaultDate.dateTimeString, for: .normal)
                self.selectedDate = defaultDate
                UIView.animate(withDuration: 0.2) {
                    self.reminderDateButton.isHidden = false

                }
            } }
        } else {
            NotificationManager.shared.removeReminder(assignmentID)
            UIView.animate(withDuration: 0.2) {
                self.reminderDateButton.isHidden = true
            }
        }
    }

    @IBAction func reminderDateButtonPressed(_ sender: Any) {
        let dateBinding = Binding(get: { self.selectedDate },
                                  set: { self.reminderDateChanged(selectedDate: $0) })
        CoreDatePicker.showDatePicker(for: dateBinding, minDate: minDate, maxDate: maxDate, from: self)
    }

    @IBAction func compose() {
        guard let assignment = assignment.first, let name = student.first?.fullName else { return }
        let subject = String.localizedStringWithFormat(
            NSLocalizedString("Regarding: %@, Assignment - %@", comment: "Regarding <Name>, Assignment - <Assignment Name>"),
            name,
            assignment.name
        )
        let hiddenMessage = String.localizedStringWithFormat(
            NSLocalizedString("Regarding: %@, %@", comment: "Regarding <Name>, <URL>"),
            name,
            assignment.htmlURL?.absoluteString ?? ""
        )
        let compose = ComposeViewController.create(
            context: .course(courseID),
            observeeID: studentID,
            recipients: teachers.all,
            subject: subject,
            hiddenMessage: hiddenMessage
        )
        env.router.show(compose, from: self, options: .modal(isDismissable: false, embedInNav: true), analyticsRoute: "/conversations/compose")
    }
}
