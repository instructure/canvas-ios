//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public enum ErrorReportType: String {
    case problem, feature
}

public class ErrorReportViewController: ScreenViewTrackableViewController {
    @IBOutlet weak var backgroundColorView: UIView?
    @IBOutlet weak var commentsField: UITextView?
    weak var commentsMinHeight: NSLayoutConstraint?
    @IBOutlet weak var commentsPlaceholder: UILabel?
    @IBOutlet weak var emailField: UITextField?
    @IBOutlet weak var emailLabel: UILabel?
    @IBOutlet weak var emailView: UIView?
    @IBOutlet weak var impactButton: UIButton?
    @IBOutlet weak var impactLabel: UILabel?
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint?
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var subjectField: UITextField?
    @IBOutlet weak var subjectLabel: UILabel?

    var env: AppEnvironment = .shared
    var error: NSError?
    var keyboard: KeyboardTransitioning?
    var initialSubject: String?
    var type: ErrorReportType = .problem
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/support/problem")

    var selectedImpact: IndexPath?
    let impacts = [ ItemPickerSection(items: [
        ItemPickerItem(
            title: NSLocalizedString("Comment", bundle: .core, comment: ""),
            subtitle: NSLocalizedString("Casual question or suggestion", bundle: .core, comment: "")
        ),
        ItemPickerItem(
            title: NSLocalizedString("Not Urgent", bundle: .core, comment: ""),
            subtitle: NSLocalizedString("I need help but it's not urgent", bundle: .core, comment: "")
        ),
        ItemPickerItem(
            title: NSLocalizedString("Workaround", bundle: .core, comment: ""),
            subtitle: NSLocalizedString("Something is broken but I can work around it", bundle: .core, comment: "")
        ),
        ItemPickerItem(
            title: NSLocalizedString("Blocking", bundle: .core, comment: ""),
            subtitle: NSLocalizedString("I can't get things done until I hear back from you", bundle: .core, comment: "")
        ),
        ItemPickerItem(
            title: NSLocalizedString("Emergency", bundle: .core, comment: ""),
            subtitle: NSLocalizedString("Extremely critical emergency", bundle: .core, comment: "")
        ),
    ]), ]

    public static func create(env: AppEnvironment = .shared, type: ErrorReportType = .problem, error: NSError? = nil, subject: String? = nil) -> ErrorReportViewController {
        let controller = loadFromStoryboard()
        controller.env = env
        controller.error = error
        controller.initialSubject = subject
        controller.type = type
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        switch type {
        case .problem:
            title = NSLocalizedString("Report a Problem", bundle: .core, comment: "")
            subjectField?.placeholder = NSLocalizedString("Something is Wrong", bundle: .core, comment: "")
            commentsPlaceholder?.text = NSLocalizedString("Describe the problem", bundle: .core, comment: "")
        case .feature:
            title = NSLocalizedString("Request a Feature", bundle: .core, comment: "")
            subjectField?.placeholder = NSLocalizedString("Something is Missing", bundle: .core, comment: "")
            commentsPlaceholder?.text = NSLocalizedString("Describe the feature", bundle: .core, comment: "")
        }

        addCancelButton(side: .left)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Send", bundle: .core, comment: ""), style: .done, target: self, action: #selector(send))
        navigationItem.rightBarButtonItem?.isEnabled = false

        backgroundColorView?.backgroundColor = .backgroundLightest

        emailField?.textAlignment = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .left : .right
        emailLabel?.text = NSLocalizedString("Your Email", bundle: .core, comment: "")
        emailLabel?.accessibilityElementsHidden = true
        if let email = AppEnvironment.shared.currentSession?.userEmail, !email.isEmpty {
            emailField?.text = email
            emailView?.isHidden = true
        }
        emailField?.accessibilityLabel = NSLocalizedString("Email address", bundle: .core, comment: "")

        subjectField?.textAlignment = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .left : .right
        subjectField?.text = initialSubject
        let subjectLabelText = NSLocalizedString("Subject", bundle: .core, comment: "")
        subjectLabel?.text = subjectLabelText
        subjectLabel?.accessibilityElementsHidden = true
        subjectField?.accessibilityLabel = subjectLabelText

        impactButton?.setTitle(NSLocalizedString("Select One", bundle: .core, comment: ""), for: .normal)
        impactButton?.accessibilityLabel = NSLocalizedString("Select Impact", bundle: .core, comment: "")
        impactLabel?.text = NSLocalizedString("Impact", bundle: .core, comment: "")
        impactLabel?.accessibilityElementsHidden = true

        commentsField?.textColor = .textDarkest
        commentsField?.textContainerInset = UIEdgeInsets(top: 11.5, left: 11, bottom: 11, right: 11)
        commentsField?.accessibilityLabel = NSLocalizedString("Description", bundle: .core, comment: "")

        commentsMinHeight = commentsField?.heightAnchor.constraint(greaterThanOrEqualTo: scrollView!.heightAnchor)
        commentsMinHeight?.isActive = true
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        navigationController?.navigationBar.useModalStyle()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        commentsMinHeight?.constant = -(commentsField?.superview?.frame.minY ?? 100)
    }

    @objc func send() {
        guard
            let email = emailField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
            let subject = subjectField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !subject.isEmpty,
            let impact = selectedImpact?.row,
            let comments = commentsField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !comments.isEmpty
        else { return }

        let request = PostErrorReportRequest(error: error, email: email, subject: subject, impact: impact, comments: comments)
        env.api.makeRequest(request) { (_, response, error) in DispatchQueue.main.async {
            let isError = error != nil || ((response as? HTTPURLResponse)?.statusCode ?? 0) >= 300
            var title = NSLocalizedString("Success!", bundle: .core, comment: "")
            var message = NSLocalizedString("Thanks, your request was received!", bundle: .core, comment: "")
            if isError {
                title = NSLocalizedString("Request Failed!", bundle: .core, comment: "")
                message = NSLocalizedString("Check network and try again!", bundle: .core, comment: "")
            }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", bundle: .core, comment: ""), style: .default) { _ in
                if !isError { self.dismiss(animated: true) }
            })
            self.present(alert, animated: true)
        } }
    }

    @IBAction func updateSendButton() {
        navigationItem.rightBarButtonItem?.isEnabled = (
            selectedImpact != nil &&
            commentsField?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            emailField?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            subjectField?.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        )
    }
}

extension ErrorReportViewController: ItemPickerDelegate {
    @IBAction public func pickImpact() {
        show(ItemPickerViewController.create(
            title: NSLocalizedString("Impact Level", bundle: .core, comment: ""),
            sections: impacts,
            selected: selectedImpact,
            delegate: self
        ), sender: self)
    }

    public func itemPicker(_ itemPicker: ItemPickerViewController, didSelectRowAt indexPath: IndexPath) {
        selectedImpact = indexPath
        let impactTitle = impacts[indexPath.section].items[indexPath.row].title
        impactButton?.setTitle(impactTitle, for: .normal)
        impactButton?.accessibilityValue = impactTitle
        updateSendButton()
    }
}

extension ErrorReportViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        commentsPlaceholder?.isHidden = !textView.text.isEmpty
        updateSendButton()
    }
}
