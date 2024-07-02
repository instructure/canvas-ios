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
    @IBOutlet weak var attemptLabel: UILabel!
    @IBOutlet weak var pickerButton: DynamicButton?
    @IBOutlet weak var pickerButtonDivider: DividerView?
    @IBOutlet weak var picker: UIPickerView?

    static func create(env: AppEnvironment = .shared, context: Context, assignmentID: String, userID: String, selectedAttempt: Int? = nil) -> SubmissionDetailsViewController {
        let controller = loadFromStoryboard()
        controller.presenter = SubmissionDetailsPresenter(env: env, view: controller, context: context, assignmentID: assignmentID, userID: userID, selectedAttempt: selectedAttempt)
        controller.env = env
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
        picker?.dataSource = self
        picker?.delegate = self
        picker?.backgroundColor = .backgroundLightest
        pickerButton?.textColorName = "textDark"
        pickerButton?.isEnabled = false
        attemptLabel.isEnabled = false
        attemptLabel.font = .scaledNamedFont(.regular14)
        attemptLabel.textColor = .textDark

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

        if let selectedAttempt = presenter.selectedAttempt,
           let pickerRow = presenter.pickerSubmissions.firstIndex(where: { $0.attempt == selectedAttempt}) {
            picker?.selectRow(pickerRow, inComponent: 0, animated: false)
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
        pickerButton?.isHidden = !isSubmitted
        attemptLabel?.isHidden = !isSubmitted
        pickerButtonDivider?.isHidden = !isSubmitted
        if let submittedAt = submission?.submittedAt, let attempt = submission?.attempt {
            let title = DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short)
            updateAttemptPickerButton(isActive: presenter.pickerSubmissions.count > 1, title: title)
            attemptLabel.isEnabled = presenter.pickerSubmissions.count > 1
            let format = String(localized: "Attempt %d", bundle: .student)
            attemptLabel?.text = String.localizedStringWithFormat(format, attempt)
        }
        if presenter.pickerSubmissions.count <= 1 || assignment.isExternalToolAssignment {
            picker?.isHidden = true
        }

        lockedEmptyView?.isHidden = !isLocked
        lockedEmptyView?.headerLabel.text = presenter.lockedEmptyViewHeader()
    }

    private func updateAttemptPickerButton(isActive: Bool, title: String) {
        pickerButton?.isEnabled = isActive
        pickerButton?.setTitle(title, for: .normal)

        var buttonConfig = UIButton.Configuration.plain()
        if isActive {
            if picker?.isHidden == true {
                buttonConfig.image = .arrowOpenDownSolid
                    .scaleTo(.init(width: 14, height: 14))
                    .withRenderingMode(.alwaysTemplate)
            } else {
                buttonConfig.image = .arrowOpenUpSolid
                    .scaleTo(.init(width: 14, height: 14))
                    .withRenderingMode(.alwaysTemplate)
            }
            buttonConfig.imagePlacement = .trailing
            buttonConfig.imagePadding = 6
        }

        buttonConfig.contentInsets = {
            var result = buttonConfig.contentInsets
            result.trailing = 0
            return result
        }()
        buttonConfig.indicator = .none

        buttonConfig.titleTextAttributesTransformer = .init { attributes in
            var result = attributes
            result.font = UIFont.scaledNamedFont(.regular14)
            return result
        }
        pickerButton?.configuration = buttonConfig
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
            pickerButton?.configuration?.image = .arrowOpenDownSolid
                .scaleTo(.init(width: 14, height: 14))
                .withRenderingMode(.alwaysTemplate)
        } else {
            pickerButton?.configuration?.image = .arrowOpenUpSolid
                .scaleTo(.init(width: 14, height: 14))
                .withRenderingMode(.alwaysTemplate)
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

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        guard presenter?.pickerSubmissions.isEmpty == false else { return 40 }

        let renderSize = CGSize(width: pickerView.frame.width, height: .infinity)
        let text = text(forRow: 0)
        let textHeight = text.boundingRect(with: renderSize,
                                           options: [.usesLineFragmentOrigin, .usesFontLeading],
                                           context: nil).height
        // Increase height to have some top/bottom padding
        return textHeight + 2 * 8
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.attributedText = text(forRow: row)
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let attempt = presenter?.pickerSubmissions[row].attempt else { return }
        presenter?.select(attempt: attempt)
    }

    private func text(forRow row: Int) -> NSAttributedString {
        let submissionDateText: String = {
            guard let submittedAt = presenter?.pickerSubmissions[row].submittedAt else {
                return String(localized: "No Submission Date", bundle: .student)
            }

            return DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short)
        }()
        let attemptText: String = {
            guard let attempt = presenter?.pickerSubmissions[row].attempt else {
                return ""
            }

            let format = String(localized: "Attempt %d", bundle: .student)
            return String.localizedStringWithFormat(format, attempt)
        }()

        let text = NSMutableAttributedString(string: "\(submissionDateText)\n\(attemptText)")
        let paragraphStyle = NSMutableParagraphStyle()
        // This visually will match the top/bottom padding cells have
        paragraphStyle.tailIndent = -12
        text.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.length))
        let dateRange = text.mutableString.range(of: submissionDateText)
        let attemptRange = text.mutableString.range(of: attemptText)

        if dateRange.location != NSNotFound, attemptRange.location != NSNotFound {
            text.addAttributes([
                                .font: UIFont.scaledNamedFont(.regular20),
                                .foregroundColor: UIColor.textDarkest,
                               ],
                               range: dateRange)
            text.addAttributes([
                                .font: UIFont.scaledNamedFont(.regular17),
                                .foregroundColor: UIColor.textDarkest,
                                ],
                               range: attemptRange)
        }

        return text
    }
}
