//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import UIKit
import Core

protocol SubmissionDetailsViewAssignmentModel: DueViewable, SubmissionViewable {}
protocol SubmissionDetailsViewModel {
    var attempt: Int { get }
    var submittedAt: Date? { get }
    var workflowState: SubmissionWorkflowState { get }
}

protocol SubmissionDetailsViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func update(assignment: SubmissionDetailsViewAssignmentModel, submissions: [SubmissionDetailsViewModel], selectedAttempt: Int)
    var navigationItem: UINavigationItem { get }
    func embed(_ controller: UIViewController?)
}

class SubmissionDetailsViewController: UIViewController, SubmissionDetailsViewProtocol {
    var color: UIColor?
    var presenter: SubmissionDetailsPresenter?
    var titleSubtitleView = TitleSubtitleView.create()
    var contentViewController: UIViewController?
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var emptyView: SubmissionDetailsEmptyView?
    @IBOutlet weak var pickerButton: DynamicButton?
    @IBOutlet weak var pickerButtonArrow: IconView?
    @IBOutlet weak var pickerButtonDivider: DividerView?
    @IBOutlet weak var picker: UIPickerView?

    var submissions: [SubmissionDetailsViewModel] = []

    static func create(env: AppEnvironment = .shared, context: Context, assignmentID: String, userID: String) -> SubmissionDetailsViewController {
        let controller = Bundle.loadController(self)
        controller.presenter = SubmissionDetailsPresenter(env: env, view: controller, context: context, assignmentID: assignmentID, userID: userID)
        return controller
    }

    override func viewDidLoad() {
        setupTitleViewInNavbar(title: NSLocalizedString("Submission", bundle: .student, comment: ""))
        picker?.dataSource = self
        picker?.delegate = self
        presenter?.viewIsReady()
    }

    func update(assignment: SubmissionDetailsViewAssignmentModel, submissions: [SubmissionDetailsViewModel], selectedAttempt: Int) {
        self.submissions = submissions
        picker?.reloadAllComponents()
        var selected: SubmissionDetailsViewModel?
        for (i, submission) in submissions.enumerated() {
            guard submission.attempt == selectedAttempt else { continue }
            selected = submission
            picker?.selectRow(i, inComponent: 0, animated: false)
        }
        let isSubmitted = selected != nil && selected?.workflowState != .unsubmitted
        contentView?.isHidden = !isSubmitted && !assignment.isExternalToolAssignment
        emptyView?.isHidden = isSubmitted || assignment.isExternalToolAssignment
        emptyView?.dueText = assignment.assignmentDueByText
        pickerButton?.isHidden = !isSubmitted
        if let submittedAt = selected?.submittedAt {
            pickerButton?.setTitle(DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short), for: .normal)
        }
        pickerButton?.isEnabled = submissions.count > 1
        pickerButtonArrow?.isHidden = !isSubmitted || submissions.count <= 1
        pickerButtonDivider?.isHidden = !isSubmitted
        if submissions.count <= 1 || assignment.isExternalToolAssignment {
            picker?.isHidden = true
        }
    }

    func embed(_ controller: UIViewController?) {
        if let old = contentViewController {
            navigationItem.rightBarButtonItems = []
            old.willMove(toParent: nil)
            old.removeFromParent()
            old.view.removeFromSuperview()
            old.didMove(toParent: nil)
        }

        guard let contentView = contentView, let controller = controller, let view = controller.view else { return }

        controller.willMove(toParent: self)
        contentView.addSubview(view)
        view.pin(inside: contentView)
        addChild(controller)
        controller.didMove(toParent: self)
    }

    func showError(_ error: Error) {
        assertionFailure(error.localizedDescription)
    }

    @IBAction func pickerButtonTapped(_ sender: Any) {
        picker?.isHidden = picker?.isHidden == false
        if picker?.isHidden == true {
            pickerButton?.tintColor = .named(.textDark)
            pickerButtonArrow?.tintColor = .named(.textDark)
            pickerButtonArrow?.image = .icon(.miniArrowDown, .solid)
        } else {
            pickerButton?.tintColor = Brand.shared.buttonPrimaryBackground
            pickerButtonArrow?.tintColor = Brand.shared.buttonPrimaryBackground
            pickerButtonArrow?.image = .icon(.miniArrowUp, .solid)
        }
    }
}

extension SubmissionDetailsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return submissions.count
    }

    func submissionAt(_ row: Int) -> SubmissionDetailsViewModel {
        return submissions[row]
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let submittedAt = submissionAt(row).submittedAt else {
            return NSLocalizedString("No Submission Date", bundle: .student, comment: "")
        }
        return DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        presenter?.select(attempt: submissionAt(row).attempt)
    }
}
