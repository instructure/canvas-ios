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

public class ComposeViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var attachmentsContainer: UIView!
    let attachmentsController = AttachmentCardsViewController.create()
    @IBOutlet var bodyMinHeight: NSLayoutConstraint!
    @IBOutlet weak var bodyView: UITextView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var recipientsView: ComposeRecipientsView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var subjectField: UITextField!
    let titleSubtitleView = TitleSubtitleView.create()

    lazy var attachButton = UIBarButtonItem(image: .paperclipLine, style: .plain, target: self, action: #selector(attach))
    lazy var sendButton = UIBarButtonItem(title: String(localized: "Send", bundle: .core), style: .done, target: self, action: #selector(send))

    let batchID = UUID.string
    lazy var attachments = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.updateAttachments()
    }
    lazy var filePicker = FilePicker(env: env, delegate: self)

    var context = Context.currentUser
    let env = AppEnvironment.shared
    var keyboard: KeyboardTransitioning?
    var observeeID: String?
    var hiddenMessage: String?

    lazy var course: Store<GetCourse>? = {
        guard context.contextType == .course else { return nil }
        return env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
            self?.titleSubtitleView.subtitle = self?.course?.first?.courseCode
        }
    }()

    lazy var teachers = env.subscribe(GetSearchRecipients(context: context, qualifier: .teachers)) { [weak self] in
        self?.updateRecipients()
    }

    public static func create(
        body: String? = nil,
        context: Context,
        observeeID: String? = nil,
        recipients: [SearchRecipient]? = nil,
        subject: String? = nil,
        hiddenMessage: String? = nil
    ) -> ComposeViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        controller.loadViewIfNeeded()
        controller.bodyView.text = body
        controller.observeeID = observeeID
        controller.recipientsView.context = context
        controller.recipientsView.recipients = recipients?.sorted(by: { $0.name < $1.name }) ?? []
        controller.subjectField.text = subject
        controller.textViewDidChange(controller.bodyView)
        controller.hiddenMessage = hiddenMessage
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        titleSubtitleView.titleLabel?.textColor = .textDarkest
        titleSubtitleView.subtitleLabel?.textColor = .textDark
        navigationItem.titleView = titleSubtitleView
        titleSubtitleView.title = String(localized: "New Message", bundle: .core)

        addCancelButton(side: .left)
        attachButton.accessibilityLabel = String(localized: "Add Attachments", bundle: .core)
        sendButton.isEnabled = false
        navigationItem.rightBarButtonItems = [ sendButton, attachButton ]

        embed(attachmentsController, in: attachmentsContainer)
        attachmentsContainer.isHidden = true
        attachmentsController.showOptions = { [weak self] in self?.showOptions(for: $0) }

        bodyMinHeight.isActive = true
        bodyView.placeholder = String(localized: "Message", bundle: .core)
        bodyView.placeholderColor = UIColor.textDark
        bodyView.font = .scaledNamedFont(.medium16)
        bodyView.textColor = .textDarkest
        bodyView.textContainerInset = UIEdgeInsets(top: 15.5, left: 11, bottom: 15, right: 11)
        bodyView.accessibilityLabel = String(localized: "Message", bundle: .core)
        bodyView.accessibilityHint = String(localized: "Text Field", bundle: .core)

        subjectField.attributedPlaceholder = NSAttributedString(
            string: String(localized: "Subject", bundle: .core),
            attributes: [ .foregroundColor: UIColor.textDark ]
        )
        subjectField.accessibilityLabel = String(localized: "Subject", bundle: .core)

        recipientsView.editButton.addTarget(self, action: #selector(editRecipients), for: .primaryActionTriggered)
        course?.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        navigationController?.navigationBar.useModalStyle()
        if !UIAccessibility.isSwitchControlRunning, !UIAccessibility.isVoiceOverRunning {
            bodyView.becomeFirstResponder()
        }

        if recipientsView.recipients.count == 0 {
            teachers.refresh()
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bodyMinHeight.constant = -bodyView.frame.minY
    }

    @IBAction func updateSendButton() {
        sendButton.isEnabled = (
            sendButton.customView == nil &&
            bodyView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            subjectField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            !recipientsView.recipients.isEmpty &&
            (attachments.isEmpty || attachments.allSatisfy({ $0.isUploaded }))
        )
    }

    public func body() -> String {
        return "\(bodyView.text ?? "")\n\n\(hiddenMessage ?? "")"
    }

    @objc func send() {
        guard sendButton.isEnabled else { return }
        let spinner = CircleProgressView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        spinner.color = nil
        sendButton.customView = spinner
        updateSendButton()
        let subject = subjectField.text ?? ""
        let recipientIDs = recipientsView.recipients.map({ $0.id })
        let attachmentIDs = attachments.all.compactMap { $0.id }
        CreateConversation(subject: subject, body: body(), recipientIDs: recipientIDs, canvasContextID: context.canvasContextID, attachmentIDs: attachmentIDs).fetch { [weak self] _, _, error in
            performUIUpdate {
                if let error = error {
                    self?.sendButton.customView = nil
                    self?.updateSendButton()
                    self?.showError(error)
                    return
                }
                self?.dismiss(animated: true)
            }
        }
    }

    @objc func editRecipients() {
        let editRecipients = EditComposeRecipientsViewController.create(
            context: context,
            observeeID: observeeID,
            selectedRecipients: Set(recipientsView.recipients)
        )
        editRecipients.delegate = self
        env.router.show(editRecipients, from: self, options: .modal())
    }

    func updateRecipients() {
        guard !teachers.pending else { return }
        recipientsView.recipients = teachers.all.sorted(by: { $0.name < $1.name })
    }
}

extension ComposeViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        updateSendButton()
    }
}

extension ComposeViewController: EditComposeRecipientsViewControllerDelegate {
    func editRecipientsControllerDidFinish(_ controller: EditComposeRecipientsViewController) {
        recipientsView.recipients = Array(controller.selectedRecipients).sorted(by: { $0.name < $1.name })
        updateSendButton()
        UIAccessibility.post(notification: .screenChanged, argument: recipientsView.editButton)
    }
}

extension ComposeViewController: FilePickerDelegate {
    @objc func attach() {
        filePicker.pick(from: self)
    }

    func showOptions(for file: File) {
        filePicker.showOptions(for: file, from: self)
    }

    public func filePicker(didPick url: URL) {
        _ = attachments // lazy init
        env.uploadManager.upload(url: url, batchID: batchID, to: .myFiles, folderPath: "my files/conversation attachments")
    }

    public func filePicker(didRetry file: File) {
        UploadManager.shared.upload(file: file, to: .myFiles, folderPath: "my files/conversation attachments")
    }

    func updateAttachments() {
        bodyMinHeight.isActive = attachments.isEmpty
        attachmentsContainer.isHidden = attachments.isEmpty
        attachmentsController.updateAttachments(attachments.all.sorted(by: File.objectIDCompare))
        updateSendButton()
    }
}
