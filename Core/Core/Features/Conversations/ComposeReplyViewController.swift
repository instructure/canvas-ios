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

/**
 Used in Parent only.
 */
class ComposeReplyViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var attachmentsContainer: UIView!
    let attachmentsController = AttachmentCardsViewController.create()
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet var bodyMinHeight: NSLayoutConstraint!
    @IBOutlet weak var bodyView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var toLabel: UILabel!

    lazy var attachButton = UIBarButtonItem(image: .paperclipLine, style: .plain, target: self, action: #selector(attach))
    lazy var sendButton = UIBarButtonItem(title: String(localized: "Send", bundle: .core), style: .done, target: self, action: #selector(send))

    let batchID = UUID.string
    lazy var attachments = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.updateAttachments()
    }
    lazy var students = env.subscribe(GetObservedStudents(observerID: env.currentSession?.userID ??  "")) { [weak self] in
        self?.update()
    }
    lazy var filePicker = FilePicker(env: env, delegate: self)

    var conversation: Conversation?
    let env = AppEnvironment.shared
    var keyboard: KeyboardTransitioning?
    var message: ConversationMessage?
    var all: Bool = false

    static func create(
        conversation: Conversation?,
        message: ConversationMessage?,
        all: Bool
    ) -> ComposeReplyViewController {
        let controller = loadFromStoryboard()
        controller.loadViewIfNeeded()
        controller.conversation = conversation
        controller.message = message
        controller.all = all
        controller.update()
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        addCancelButton(side: .left)
        attachButton.accessibilityLabel = String(localized: "Add Attachments", bundle: .core)
        attachButton.accessibilityIdentifier = "ComposeReply.attachButton"
        sendButton.isEnabled = false
        sendButton.accessibilityIdentifier = "ComposeReply.sendButton"
        navigationItem.rightBarButtonItems = [ sendButton, attachButton ]

        embed(attachmentsController, in: attachmentsContainer)
        attachmentsContainer.isHidden = true
        attachmentsController.showOptions = { [weak self] in self?.showOptions(for: $0) }

        bodyView.placeholder = String(localized: "Message", bundle: .core)
        bodyView.placeholderColor = UIColor.textDark
        bodyView.font = .scaledNamedFont(.medium16)
        bodyView.textColor = .textDarkest
        bodyView.textContainerInset = UIEdgeInsets(top: 15.5, left: 11, bottom: 15, right: 11)
        bodyView.accessibilityLabel = String(localized: "Message", bundle: .core)
        if env.app == .parent {
            students.refresh()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        navigationController?.navigationBar.useModalStyle()
        if !UIAccessibility.isSwitchControlRunning, !UIAccessibility.isVoiceOverRunning {
            bodyView.becomeFirstResponder()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bodyMinHeight.constant = -bodyView.frame.minY
    }

    func update() {
        title = all
            ? String(localized: "Reply All", bundle: .core)
            : String(localized: "Reply", bundle: .core)

        guard let conversation = conversation,
            let message = message,
            let createdAt = message.createdAt else {
                return
        }
        let myID = env.currentSession?.userID ?? ""
        let userMap: [String: ConversationParticipant] = conversation.participants
            .reduce(into: [:]) { map, p in map[p.id] = p }
        messageLabel.text = message.body
        toLabel.text = message.localizedAudience(myID: myID, userMap: userMap)
        fromLabel.text = userMap[message.authorID]?.displayName
        dateLabel.text = DateFormatter.localizedString(from: createdAt, dateStyle: .medium, timeStyle: .short)
        avatarView.url = userMap[message.authorID]?.avatarURL
        avatarView.name = userMap[message.authorID]?.name ?? ""
    }

    @IBAction func updateSendButton() {
        sendButton.isEnabled = (
            sendButton.customView == nil &&
            conversation != nil &&
            message != nil &&
            bodyView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            (attachments.isEmpty || attachments.allSatisfy({ $0.isUploaded }))
        )
    }

    @objc func send() {
        guard
            sendButton.isEnabled,
            let conversation = conversation, let message = message,
            let body = bodyView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !body.isEmpty
        else { return }
        let spinner = CircleProgressView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        spinner.color = nil
        sendButton.customView = spinner
        updateSendButton()
        let recipients = all ? replyAllRecipientIDs : [ message.authorID ]
        let attachmentIDs = attachments.all.compactMap { $0.id }
        AddMessage(conversationID: conversation.id, attachmentIDs: attachmentIDs, body: body, recipientIDs: recipients).fetch { [weak self] _, _, error in performUIUpdate {
            guard let self = self else { return }
            if let error = error {
                self.sendButton.customView = nil
                self.updateSendButton()
                self.showError(error)
                return
            }
            self.env.router.dismiss(self)
        } }
    }

    var replyAllRecipientIDs: [String] {
        guard let conversation = conversation, let message = message else { return [] }
        let myID = env.currentSession?.userID ?? ""
        return message.participantIDs.filter { participantID in
            if participantID == myID {
                return false
            }
            if env.app == .parent {
                // Parents can only reply-all to their own students, teachers, and TAs
                if students.contains(where: { $0.id == participantID }) {
                    return true
                }
                let context = conversation.contextCode.flatMap { Context(canvasContextID: $0) }
                let participant = conversation.participants.first { $0.id == participantID }
                let role = participant?.commonCourses.first { $0.courseID == context?.id }.flatMap { Role(rawValue: $0.role) }
                return [.teacher, .ta].contains(role)
            }
            return true
        }
    }
}

extension ComposeReplyViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        updateSendButton()
    }
}

extension ComposeReplyViewController: FilePickerDelegate {
    @objc func attach() {
        filePicker.pick(from: self)
    }

    func showOptions(for file: File) {
        filePicker.showOptions(for: file, from: self)
    }

    func filePicker(didPick url: URL) {
        _ = attachments // lazy init
        env.uploadManager.upload(url: url, batchID: batchID, to: .myFiles, folderPath: "my files/conversation attachments")
    }

    func filePicker(didRetry file: File) {
        env.uploadManager.upload(file: file, to: .myFiles, folderPath: "my files/conversation attachments")
    }

    func updateAttachments() {
        bodyMinHeight.isActive = attachments.isEmpty
        attachmentsContainer.isHidden = attachments.isEmpty
        attachmentsController.updateAttachments(attachments.all.sorted(by: File.objectIDCompare))
    }
}
