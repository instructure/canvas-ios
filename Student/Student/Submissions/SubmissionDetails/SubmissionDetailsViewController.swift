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
    @IBOutlet weak var pickerButton: DynamicButton?
    @IBOutlet weak var pickerButtonArrow: IconView?
    @IBOutlet weak var pickerButtonDivider: DividerView?
    @IBOutlet weak var picker: UIPickerView?

    static func create(env: AppEnvironment = .shared, context: Context, assignmentID: String, userID: String) -> SubmissionDetailsViewController {
        let controller = loadFromStoryboard()
        controller.presenter = SubmissionDetailsPresenter(env: env, view: controller, context: context, assignmentID: assignmentID, userID: userID)
        controller.env = env
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        setupTitleViewInNavbar(title: NSLocalizedString("Submission", bundle: .student, comment: ""))
        drawer?.tabs?.addTarget(self, action: #selector(drawerTabChanged), for: .valueChanged)
        emptyView?.submitCallback = { [weak self] button in
            self?.presenter?.submit(button: button)
        }
        picker?.dataSource = self
        picker?.delegate = self
        picker?.backgroundColor = .backgroundLightest
        pickerButton?.setTitleColor(.textDark, for: .disabled)

        pickerButtonArrow?.isHidden = true
        pickerButtonDivider?.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        presenter?.viewIsReady()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = setDrawerPositionOnce
        drawerContentViewController?.view.accessibilityElementsHidden = drawer?.height == 0
        contentView?.accessibilityElementsHidden = drawer?.height != 0
        pickerButton?.accessibilityElementsHidden = drawer?.height == drawer?.maxDrawerHeight
    }

    func reload() {
        guard let presenter = presenter, let assignment = presenter.currentAssignment else {
            return
        }
        picker?.reloadAllComponents()

        let submission = presenter.currentSubmission

        let isSubmitted = submission?.workflowState != .unsubmitted && submission?.submittedAt != nil
        let isLocked = !presenter.lockedEmptyViewIsHidden()
        contentView?.isHidden = !isSubmitted && !assignment.isExternalToolAssignment
        drawer?.fileCount = submission?.attachments?.count ?? 0
        let title = presenter.submissionButtonText
        emptyView?.isHidden = isSubmitted || title == nil || assignment.isSubmittable == false || isLocked
        emptyView?.dueText = assignment.assignmentDueByText
        emptyView?.submitButtonTitle = title
        pickerButton?.isHidden = !isSubmitted
        if let submittedAt = submission?.submittedAt {
            pickerButton?.setTitle(DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short), for: .normal)
        }
        pickerButton?.isEnabled = presenter.pickerSubmissions.count > 1
        pickerButtonArrow?.isHidden = !isSubmitted || presenter.pickerSubmissions.count <= 1
        pickerButtonDivider?.isHidden = !isSubmitted
        if presenter.pickerSubmissions.count <= 1 || assignment.isExternalToolAssignment {
            picker?.isHidden = true
        }

        lockedEmptyView?.isHidden = !isLocked
        lockedEmptyView?.headerLabel.text = presenter.lockedEmptyViewHeader()
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
    }

    @IBAction func pickerButtonTapped(_ sender: Any) {
        picker?.isHidden = picker?.isHidden == false
        if picker?.isHidden == true {
            pickerButton?.tintColor = .textDark
            pickerButtonArrow?.tintColor = .textDark
            pickerButtonArrow?.image = .miniArrowDownSolid
        } else {
            pickerButton?.tintColor = Brand.shared.buttonPrimaryBackground
            pickerButtonArrow?.tintColor = Brand.shared.buttonPrimaryBackground
            pickerButtonArrow?.image = .miniArrowUpSolid
        }
    }
}

extension SubmissionDetailsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return presenter?.pickerSubmissions.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let text: String

        if let submittedAt = presenter?.pickerSubmissions[row].submittedAt {
            text = DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short)
        } else {
            text = NSLocalizedString("No Submission Date", bundle: .student, comment: "")
        }

        let label = UILabel()
        label.textColor = .textDarkest
        label.text = text
        label.font = .scaledNamedFont(.regular23)
        label.textAlignment = .center

        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let attempt = presenter?.pickerSubmissions[row].attempt else { return }
        presenter?.select(attempt: attempt)
    }
}
