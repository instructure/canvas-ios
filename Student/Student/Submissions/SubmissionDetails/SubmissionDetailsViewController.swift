//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import Core

class SubmissionDetailsViewController: ScreenViewTrackableViewController, SubmissionDetailsViewProtocol {
    var color: UIColor?
    var presenter: SubmissionDetailsPresenter?
    var titleSubtitleView = TitleSubtitleView.create()
    var contentViewController: UIViewController?
    var drawerContentViewController: UIViewController?
    var env: AppEnvironment?
    public lazy var screenViewTrackingParameters: ScreenViewTrackingParameters = {
        let courseID = presenter?.course.first?.id ?? ""
        let assignmentID = presenter?.assignmentID ?? ""
        let submissionID = presenter?.submissions.first?.id ?? ""
        return ScreenViewTrackingParameters(
            eventName: "/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(submissionID)"
        )
    }()

    private lazy var setDrawerPositionOnce: () = {
        drawer?.setMiddle()
    }()

    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var drawer: Drawer?
    @IBOutlet weak var emptyView: SubmissionDetailsEmptyView?
    @IBOutlet weak var lockedEmptyView: SubmissionDetailsLockedEmptyView?
    @IBOutlet weak var attemptPicker: SubmissionAttemptPickerView?

    static func create(env: AppEnvironment, context: Context, assignmentID: String, userID: String, selectedAttempt: Int? = nil) -> SubmissionDetailsViewController {
        let controller = loadFromStoryboard()
        controller.env = env
        controller.presenter = SubmissionDetailsPresenter(env: env, view: controller, context: context, assignmentID: assignmentID, userID: userID, selectedAttempt: selectedAttempt)
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        setupTitleViewInNavbar(title: String(localized: "Submission", bundle: .student))
        drawer?.tabs?.addTarget(self, action: #selector(drawerTabChanged), for: .valueChanged)
        emptyView?.submitCallback = { [weak self] button in
            self?.presenter?.submit(button: button)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        presenter?.viewIsReady()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = setDrawerPositionOnce
        drawerContentViewController?.view.accessibilityElementsHidden = drawer?.height == 0
        contentView?.accessibilityElementsHidden = drawer?.height != 0
    }

    func reload() {
        guard let presenter = presenter, let assignment = presenter.currentAssignment else {
            return
        }

        let submission = presenter.currentSubmission

        let isSubmitted = submission?.workflowState != .unsubmitted && submission?.submittedAt != nil
        let isLocked = !presenter.lockedEmptyViewIsHidden()
        contentView?.isHidden = !isSubmitted && !assignment.isExternalToolAssignment
        drawer?.fileCount = submission?.attachments?.count ?? 0
        let title = presenter.submissionButtonText
        emptyView?.isHidden = isSubmitted || title == nil || assignment.isSubmittable == false || isLocked
        emptyView?.dueText = assignment.assignmentDueByText
        emptyView?.submitButtonTitle = title

        updateAttemptPicker(
            assignment: assignment,
            submissions: presenter.pickerSubmissions,
            currentSubmission: submission,
            isSubmitted: isSubmitted
        )

        lockedEmptyView?.isHidden = !isLocked
        lockedEmptyView?.headerLabel.text = presenter.lockedEmptyViewHeader()
    }

    private func updateAttemptPicker(
        assignment: Assignment,
        submissions: [Submission],
        currentSubmission: Submission?,
        isSubmitted: Bool
    ) {
        attemptPicker?.isHidden = !isSubmitted

        guard let attemptPicker,
              let currentSubmission,
              let currentAttemptDate = currentSubmission.submittedAt
        else { return }

        let isActive = submissions.count > 1 && !assignment.isExternalToolAssignment

        let currentAttemptNumber = String.localizedAttemptNumber(currentSubmission.attempt)

        let items: [UIAction] = {
            guard isActive else { return [] }

            return submissions.map { submission in
                let date = submission.submittedAt?.dateTimeString ?? ""
                let attemptNumber = String.localizedAttemptNumber(submission.attempt)
                let isSelected = submission.attempt == currentSubmission.attempt
                return UIAction(title: date, subtitle: attemptNumber, state: isSelected ? .on : .off) { [weak self] _ in
                    self?.presenter?.select(attempt: submission.attempt)
                }
            }
        }()

        attemptPicker.updateLabel(text: currentAttemptNumber)
        attemptPicker.updatePickerButton(isActive: isActive, attemptDate: currentAttemptDate.dateTimeString, items: items)

    }

    func reloadNavBar() {
        guard let assignment = presenter?.assignment.first, let course = presenter?.course.first else {
            return
        }
        updateNavBar(subtitle: assignment.name, color: course.color)
        view.tintColor = course.color
    }

    func embed(_ controller: UIViewController?) {
        if let old = contentViewController {
            navigationItem.rightBarButtonItems = []
            old.unembed()
        }

        contentViewController = controller
        guard let contentView = contentView, let controller = contentViewController else { return }

        embed(controller, in: contentView)
    }

    func embedInDrawer(_ controller: UIViewController?) {
        if let old = drawerContentViewController {
            old.unembed()
        }

        drawerContentViewController = controller
        guard let contentView = drawer?.contentView, let controller = drawerContentViewController else { return }

        embed(controller, in: contentView)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let drawer = drawer else { return }
        drawer.moveTo(height: drawer.maxDrawerHeight, velocity: 1)
    }

    @IBAction func drawerTabChanged(_ sender: UISegmentedControl) {
        presenter?.select(drawerTab: Drawer.Tab(rawValue: sender.selectedSegmentIndex))
        if let drawer = drawer, drawer.height == 0 {
            drawer.moveTo(height: drawer.midDrawerHeight, velocity: 1)
        }
        UIAccessibility.post(notification: .screenChanged, argument: drawerContentViewController)
    }
}
