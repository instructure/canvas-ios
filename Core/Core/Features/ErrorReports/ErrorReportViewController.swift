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

    private var selectedImpact: OptionItem?
    let impacts = [
        OptionItem(
            id: "comment",
            title: String(localized: "Comment", bundle: .core),
            subtitle: String(localized: "Casual question or suggestion", bundle: .core)
        ),
        OptionItem(
            id: "notUrgent",
            title: String(localized: "Not Urgent", bundle: .core),
            subtitle: String(localized: "I need help but it's not urgent", bundle: .core)
        ),
        OptionItem(
            id: "workaround",
            title: String(localized: "Workaround", bundle: .core),
            subtitle: String(localized: "Something is broken but I can work around it", bundle: .core)
        ),
        OptionItem(
            id: "blocking",
            title: String(localized: "Blocking", bundle: .core),
            subtitle: String(localized: "I can't get things done until I hear back from you", bundle: .core)
        ),
        OptionItem(
            id: "emergency",
            title: String(localized: "Emergency", bundle: .core),
            subtitle: String(localized: "Extremely critical emergency", bundle: .core)
        )
    ]

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
            title = String(localized: "Report a Problem", bundle: .core)
            subjectField?.placeholder = String(localized: "Something is Wrong", bundle: .core)
            commentsPlaceholder?.text = String(localized: "Describe the problem", bundle: .core)
        case .feature:
            title = String(localized: "Request a Feature", bundle: .core)
            subjectField?.placeholder = String(localized: "Something is Missing", bundle: .core)
            commentsPlaceholder?.text = String(localized: "Describe the feature", bundle: .core)
        }

        addCancelButton(side: .left)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Send", bundle: .core), style: .done, target: self, action: #selector(send))
        navigationItem.rightBarButtonItem?.isEnabled = false

        backgroundColorView?.backgroundColor = .backgroundLightest

        emailField?.textAlignment = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .left : .right
        emailLabel?.text = String(localized: "Your Email", bundle: .core)
        emailLabel?.accessibilityElementsHidden = true
        if let email = AppEnvironment.shared.currentSession?.userEmail, !email.isEmpty {
            emailField?.text = email
            emailView?.isHidden = true
        }
        emailField?.accessibilityLabel = String(localized: "Email address", bundle: .core)

        subjectField?.textAlignment = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .left : .right
        subjectField?.text = initialSubject
        let subjectLabelText = String(localized: "Subject", bundle: .core)
        subjectLabel?.text = subjectLabelText
        subjectLabel?.accessibilityElementsHidden = true
        subjectField?.accessibilityLabel = subjectLabelText

        impactButton?.setTitle(String(localized: "Select One", bundle: .core), for: .normal)
        impactButton?.accessibilityLabel = String(localized: "Select Impact", bundle: .core)
        impactLabel?.text = String(localized: "Impact", bundle: .core)
        impactLabel?.accessibilityElementsHidden = true

        commentsField?.textColor = .textDarkest
        commentsField?.textContainerInset = UIEdgeInsets(top: 11.5, left: 11, bottom: 11, right: 11)
        commentsField?.accessibilityLabel = String(localized: "Description", bundle: .core)

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
            let impact = selectedImpact.flatMap({ impacts.firstIndex(of: $0) }),
            let comments = commentsField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !comments.isEmpty
        else { return }

        let request = PostErrorReportRequest(error: error, email: email, subject: subject, impact: impact, comments: comments)
        env.api.makeRequest(request) { (_, response, error) in DispatchQueue.main.async {
            let isError = error != nil || ((response as? HTTPURLResponse)?.statusCode ?? 0) >= 300
            var title = String(localized: "Success!", bundle: .core)
            var message = String(localized: "Thanks, your request was received!", bundle: .core)
            if isError {
                title = String(localized: "Request Failed!", bundle: .core)
                message = String(localized: "Check network and try again!", bundle: .core)
            }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: String(localized: "Dismiss", bundle: .core), style: .default) { _ in
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

extension ErrorReportViewController {
    @IBAction public func pickImpact() {
        let picker = ItemPickerScreen(
            pageTitle: String(localized: "Impact Level", bundle: .core),
            identifierGroup: "ErrorReport.impactLevelOptions",
            allOptions: impacts,
            initialOptionId: selectedImpact?.id,
            didSelectOption: { [weak self] option in
                guard let self else { return }

                selectedImpact = option
                let impactTitle = option.title
                impactButton?.setTitle(impactTitle, for: .normal)
                impactButton?.accessibilityValue = impactTitle
                updateSendButton()
            }
        )

        show(CoreHostingController(picker), sender: self)
    }
}

extension ErrorReportViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        commentsPlaceholder?.isHidden = !textView.text.isEmpty
        updateSendButton()
    }
}
