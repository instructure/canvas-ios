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

import UIKit
import UserNotifications
import Core
import SafariServices
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
    @IBOutlet weak var reminderSwitch: CoreSwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var statusIconView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var submissionAndRubricButton: UIButton!
    let webView = CoreWebView()
    let refreshControl = CircleRefreshControl()
    var selectedDate: Date?
    var assignmentID = ""
    var courseID = ""
    private(set) var env: AppEnvironment = .shared
    var studentID = ""
    private var minDate = Clock.now
    private var maxDate = Clock.now
    private var userNotificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current()
    private lazy var localNotifications = LocalNotificationsInteractor(notificationCenter: userNotificationCenter)
    private var submissionURLInteractor: ParentSubmissionURLInteractor!

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
    lazy var featuresStore = env.subscribe(GetEnabledFeatureFlags(context: .course(courseID))) {
    }

    static func create(
        studentID: String,
        courseID: String,
        assignmentID: String,
        userNotificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current(),
        submissionURLInteractor: ParentSubmissionURLInteractor = ParentSubmissionURLInteractorLive(),
        env: AppEnvironment
    ) -> AssignmentDetailsViewController {
        let controller = loadFromStoryboard()
        controller.assignmentID = assignmentID
        controller.courseID = courseID
        controller.studentID = studentID
        controller.userNotificationCenter = userNotificationCenter
        controller.submissionURLInteractor = submissionURLInteractor
        controller.env = env
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        title = String(localized: "Assignment Details", bundle: .parent)
        webViewContainer.addSubview(webView)
        webView.pinWithThemeSwitchButton(inside: webViewContainer)
        webView.autoresizesHeight = true
        webView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        webView.linkDelegate = self

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        scrollView.refreshControl = refreshControl

        composeButton.accessibilityLabel = String(localized: "Compose message to teachers", bundle: .parent)
        composeButton.backgroundColor = ColorScheme.observee(studentID).color.darkenToEnsureContrast(against: .textLightest.variantForLightMode)
        composeButton.isHidden = true

        dateHeadingLabel.text = String(localized: "Due", bundle: .parent)
        dateLabel.text = ""
        descriptionHeadingLabel.text = String(localized: "Description", bundle: .parent)
        titleLabel.text = ""

        pointsLabel.text = ""

        reminderHeadingLabel.text = String(localized: "Remind Me", bundle: .parent)
        reminderMessageLabel.text = String(localized: "Set a date and time to be notified of this event.", bundle: .parent)
        reminderSwitch.accessibilityLabel = String(localized: "Remind Me", bundle: .parent)
        reminderSwitch.isEnabled = false
        reminderSwitch.tintColor = ColorScheme.observee(studentID).color
        reminderDateButton.isEnabled = false
        reminderDateButton.isHidden = true
        reminderDateButton.setTitleColor(
            Brand.shared.primary.ensureContrast(against: .backgroundLightest),
            for: .normal
        )

        statusLabel.text = ""

        submissionAndRubricButton.configuration = {
            var config = UIButton.Configuration.borderedProminent()
            config.background.cornerRadius = 6
            config.background.strokeWidth = 1 / UIScreen.main.scale
            config.background.strokeColor = .textDark
            config.background.backgroundColor = .backgroundLightest
            config.baseForegroundColor = ColorScheme.observee(studentID).color.ensureContrast(against: .backgroundLightest)
            config.image = .arrowOpenRightLine
                .scaleTo(CGSize(width: 15, height: 15))
                .withRenderingMode(.alwaysTemplate)
            config.imagePadding = 3
            config.imagePlacement = .trailing
            config.attributedTitle = AttributedString(
                String(localized: "Submission & Rubric", bundle: .core),
                attributes: AttributeContainer(
                    [.font: UIFont.scaledNamedFont(.regular16)]
                )
            )
            return config
        }()

        assignment.refresh()
        course.refresh()
        student.refresh()
        teachers.refresh()
        featuresStore.refresh()
        localNotifications.getReminder(assignmentID) { [weak self] request in performUIUpdate {
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
        featuresStore.refresh(force: true)
    }

    func update() {
        guard let assignment = assignment.first else { return }
        let submission = assignment.submissions?.first(where: { $0.userID == studentID })
        let displayProperties = submission?.stateDisplayProperties ?? .usingStatus(.notSubmitted)
        title = course.first?.name ?? String(localized: "Assignment Details", bundle: .parent)

        titleLabel.text = assignment.name
        pointsLabel.text = {
            if assignment.hideQuantitativeData {
                if assignment.pointsPossibleText.containsNumber { return " " }
            }
            return assignment.pointsPossibleText
        }()
        statusIconView.isHidden = assignment.submissionStatusIsHidden
        statusIconView.image = displayProperties.icon
        statusIconView.tintColor = displayProperties.color
        statusLabel.isHidden = assignment.submissionStatusIsHidden
        statusLabel.textColor = displayProperties.color
        statusLabel?.text = displayProperties.text
        dateLabel.text = assignment.dueAt?.dateTimeString ?? String(localized: "No Due Date", bundle: .parent)
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
        localNotifications.setReminder(for: assignment, at: selectedDate, studentID: studentID) { error in performUIUpdate { [self] in
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
            userNotificationCenter
                .requestAuthorization(options: [.alert, .sound]) { success, error in performUIUpdate {
                guard error == nil && success else {
                    self.reminderSwitch.setOn(false, animated: true)
                    return self.showNotificationsPermissionError()
                }
                self.reminderDateButton.setTitle(defaultDate.dateTimeString, for: .normal)
                self.selectedDate = defaultDate
                UIView.animate(withDuration: 0.2) {
                    self.reminderDateButton.isHidden = false

                }
            } }
        } else {
            localNotifications.removeReminder(assignmentID)
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
        guard let assignment = assignment.first,
              let name = student.first?.fullName,
              let course = course.first
        else { return }

        let subject = String.localizedStringWithFormat(
            String(localized: "Regarding: %@, Assignment - %@", bundle: .parent, comment: "Regarding <Name>, Assignment - <Assignment Name>"),
            name,
            assignment.name
        )
        let hiddenMessage = String.localizedStringWithFormat(
            String(localized: "Regarding: %@, %@", bundle: .parent, comment: "Regarding <Name>, <URL>"),
            name,
            assignment.htmlURL?.absoluteString ?? ""
        )

        let options = ComposeMessageOptions(
            disabledFields: .init(
                contextDisabled: true
            ),
            fieldsContents: .init(
                selectedContext: .init(course: course),
                subjectText: subject
            ),
            extras: .init(
                hiddenMessage: hiddenMessage,
                autoTeacherSelect: true
            )
        )
        let composeController = ComposeMessageAssembly.makeComposeMessageViewController(options: options, env: env)
        env.router.show(composeController, from: self, options: .modal(isDismissable: false, embedInNav: true), analyticsRoute: "/conversations/compose")
    }

    @IBAction func submissionAndRubricButtonPressed(_ sender: Any) {
        guard let assignmentHtmlURL = assignment.first?.htmlURL else {
            return
        }

        let submissionURL = submissionURLInteractor.submissionURL(
            assignmentHtmlURL: assignmentHtmlURL,
            observedUserID: studentID,
            isAssignmentEnhancementsEnabled: featuresStore.isFeatureFlagEnabled(.assignmentEnhancements)
        )

        let interactor = ParentSubmissionInteractorLive(
            assignmentHtmlURL: submissionURL,
            observedUserID: studentID
        )
        let viewModel = ParentSubmissionViewModel(interactor: interactor, router: router)
        let submissionsViewController = ParentSubmissionViewController(viewModel: viewModel)
        env.router.show(
            submissionsViewController,
            from: self,
            options: .modal(.overFullScreen)
        )
    }
}
