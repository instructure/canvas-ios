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

    lazy var attachButton = UIBarButtonItem(image: .icon(.paperclip), style: .plain, target: self, action: #selector(attach))
    lazy var sendButton = UIBarButtonItem(title: NSLocalizedString("Send", comment: ""), style: .done, target: self, action: #selector(send))

    let batchID = UUID.string
    lazy var attachments = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.updateAttachments()
    }
    lazy var filePicker = FilePicker(delegate: self)

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
        view.backgroundColor = .named(.backgroundLightest)

        addCancelButton(side: .left)
        attachButton.accessibilityLabel = NSLocalizedString("Add Attachments", comment: "")
        attachButton.accessibilityIdentifier = "ComposeReply.attachButton"
        sendButton.isEnabled = false
        sendButton.accessibilityIdentifier = "ComposeReply.sendButton"
        navigationItem.rightBarButtonItems = [ sendButton, attachButton ]

        embed(attachmentsController, in: attachmentsContainer)
        attachmentsContainer.isHidden = true
        attachmentsController.showOptions = { [weak self] in self?.showOptions(for: $0) }

        bodyView.placeholder = NSLocalizedString("Message", comment: "")
        bodyView.placeholderColor = UIColor.named(.textDark)
        bodyView.font = .scaledNamedFont(.medium16)
        bodyView.textColor = .named(.textDarkest)
        bodyView.textContainerInset = UIEdgeInsets(top: 15.5, left: 11, bottom: 15, right: 11)
        bodyView.accessibilityLabel = NSLocalizedString("Message", comment: "")
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
            ? NSLocalizedString("Reply All", comment: "")
            : NSLocalizedString("Reply", comment: "")

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
        let myID = env.currentSession?.userID ?? ""
        let recipients = !all ? [ message.authorID ]
            : message.participantIDs.filter { $0 != myID }
        let attachmentIDs = attachments.all.compactMap { $0.id }
        AddMessage(conversationID: conversation.id, attachmentIDs: attachmentIDs, body: body, recipientIDs: recipients).fetch { [weak self] _, _, error in performUIUpdate {
            if let error = error {
                self?.sendButton.customView = nil
                self?.updateSendButton()
                self?.showError(error)
                return
            }
            self?.dismiss(animated: true)
        } }
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
        UploadManager.shared.upload(url: url, batchID: batchID, to: .myFiles, folderPath: "my files/conversation attachments")
    }

    func filePicker(didRetry file: File) {
        UploadManager.shared.upload(file: file, to: .myFiles, folderPath: "my files/conversation attachments")
    }

    func updateAttachments() {
        bodyMinHeight.isActive = attachments.isEmpty
        attachmentsContainer.isHidden = attachments.isEmpty
        attachmentsController.updateAttachments(attachments.all.sorted(by: File.objectIDCompare))
    }
}
