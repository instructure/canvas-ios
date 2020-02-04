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
import Core

class ComposeViewController: UIViewController, ErrorViewController {
    weak var bodyMinHeight: NSLayoutConstraint!
    @IBOutlet weak var bodyView: UITextView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var recipientsView: ComposeRecipientsView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var subjectField: UITextField!
    let titleSubtitleView = TitleSubtitleView.create()

    var sendButton: UIBarButtonItem?

    var context: Context?
    let env = AppEnvironment.shared
    var keyboard: KeyboardTransitioning?
    var observeeID: String?
    var hiddenMessage: String?

    lazy var course: Store<GetCourse>? = {
        guard let context = context, context.contextType == .course else { return nil }
        return env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
            self?.titleSubtitleView.subtitle = self?.course?.first?.name
        }
    }()

    static func create(
        body: String?,
        context: Context?,
        observeeID: String?,
        recipients: [APIConversationRecipient],
        subject: String?,
        hiddenMessage: String?
    ) -> ComposeViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.loadViewIfNeeded()
        controller.bodyView.text = body
        controller.observeeID = observeeID
        controller.recipientsView.recipients = recipients.sortedByName()
        controller.subjectField.text = subject
        controller.textViewDidChange(controller.bodyView)
        controller.hiddenMessage = hiddenMessage
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)

        titleSubtitleView.titleLabel?.textColor = .named(.textDarkest)
        titleSubtitleView.subtitleLabel?.textColor = .named(.textDark)
        navigationItem.titleView = titleSubtitleView
        titleSubtitleView.title = NSLocalizedString("New Message", comment: "")

        addCancelButton(side: .left)
        sendButton = UIBarButtonItem(title: NSLocalizedString("Send", comment: ""), style: .done, target: self, action: #selector(send))
        sendButton?.isEnabled = false
        navigationItem.rightBarButtonItem = sendButton

        bodyMinHeight = bodyView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        bodyMinHeight.isActive = true
        bodyView.placeholder = NSLocalizedString("Message", comment: "")
        bodyView.placeholderColor = .named(.textDark)
        bodyView.font = .scaledNamedFont(.medium16)
        bodyView.textColor = .named(.textDarkest)
        bodyView.textContainerInset = UIEdgeInsets(top: 15.5, left: 11, bottom: 15, right: 11)
        bodyView.accessibilityLabel = NSLocalizedString("Message", comment: "")

        subjectField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Subject", comment: ""),
            attributes: [ .foregroundColor: UIColor.named(.textDark) ]
        )
        subjectField.accessibilityLabel = NSLocalizedString("Subject", comment: "")

        recipientsView.editButton.addTarget(self, action: #selector(editRecipients), for: .primaryActionTriggered)
        course?.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        navigationController?.navigationBar.useModalStyle()

        if recipientsView.recipients.count == 0 {
            fetchRecipients()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bodyMinHeight.constant = -bodyView.frame.minY
    }

    @IBAction func updateSendButton() {
        navigationItem.rightBarButtonItem?.isEnabled = (
            bodyView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            subjectField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            !recipientsView.recipients.isEmpty
        )
    }

    public func body() -> String {
        return """
\(bodyView.text ?? "")

\(hiddenMessage ?? "")
"""
    }

    @objc func send() {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        let subject = subjectField.text ?? ""
        let recipientIDs = recipientsView.recipients.map({ $0.id.value })
        CreateConversation(subject: subject, body: body(), recipientIDs: recipientIDs, canvasContextID: context?.canvasContextID).fetch { [weak self] _, _, error in
            performUIUpdate {
                if let error = error {
                    self?.navigationItem.rightBarButtonItem = self?.sendButton
                    self?.showError(error)
                    return
                }
                self?.dismiss(animated: true)
            }
        }
    }

    @objc func editRecipients() {
        guard let context = context else { return }
        let editRecipients = EditComposeRecipientsViewController.create(
            context: context,
            observeeID: observeeID,
            selectedRecipients: Set(recipientsView.recipients)
        )
        editRecipients.delegate = self
        let actionSheet = ActionSheetController(viewController: editRecipients)
        env.router.show(actionSheet, from: self, options: .modal())
    }

    func fetchRecipients(completionHandler: (() -> Void)? = nil) {
        guard let context = context else {
            return
        }
        let searchContext = "\(context.canvasContextID)_teachers"
        let request = GetConversationRecipientsRequest(search: "", context: searchContext, includeContexts: false)
        env.api.makeRequest(request) { [weak self] (recipients, _, _) in
            performUIUpdate {
                self?.recipientsView.recipients = recipients?.sortedByName() ?? []
            }
        }
    }
}

extension ComposeViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        updateSendButton()
    }
}

extension ComposeViewController: EditComposeRecipientsViewControllerDelegate {
    func editRecipientsControllerDidFinish(_ controller: EditComposeRecipientsViewController) {
        recipientsView.recipients = Array(controller.selectedRecipients).sortedByName()
        updateSendButton()
        UIAccessibility.post(notification: .screenChanged, argument: recipientsView.editButton)
    }
}
