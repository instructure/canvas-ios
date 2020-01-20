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

import Foundation
import Core

class ConversationDetailViewController: UIViewController {

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var conversationID: String!
    let env = AppEnvironment.shared
    let refreshControl = UIRefreshControl()
    var userMap = [String: ConversationParticipant]()
    var myID: String = ""

    lazy var conversations = env.subscribe(GetConversation(id: conversationID)) { [weak self] in
        self?.update()
    }

    static func create(conversationID: String) -> ConversationDetailViewController {
        let vc = loadFromStoryboard()
        vc.conversationID = conversationID
        vc.myID = vc.env.currentSession?.userID ?? ""
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    private func configureTableView() {
        tableView.refreshControl = refreshControl
        tableView.backgroundColor = .named(.backgroundGrouped)
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.registerHeaderFooterView(UITableViewHeaderFooterView.self, fromNib: false)
    }

    @objc func refresh(force: Bool = false) {
        conversations.refresh(force: true)
    }

    func update() {
        if !conversations.pending {
            mapUsers(conversation: conversations.first)
            if refreshControl.isRefreshing { refreshControl.endRefreshing() }
            tableView?.reloadData()
            title = conversations.first?.subject.isEmpty ?? true ? NSLocalizedString("No Subject", comment: "") : conversations.first?.subject
            let lastParticipantCount = conversations.first?.messages.first?.participantIDs.count ?? 0
            if lastParticipantCount > 2 {
                replyButton.setImage(.icon(.replyAll, .solid), for: .normal)
                replyButton.accessibilityLabel = NSLocalizedString("Reply All", comment: "")
            } else {
                replyButton.setImage(.icon(.reply, .solid), for: .normal)
                replyButton.accessibilityLabel = NSLocalizedString("Reply", comment: "")
            }
        }
    }

    func mapUsers(conversation: Conversation?) {
        guard let c = conversation else { return }
        c.participants.forEach { userMap[ $0.id ] = $0 }
    }

    @IBAction func actionReplyClicked(_ sender: Any) {
        guard let message = conversations.first?.messages.first else { return }
        showReplyFor(IndexPath(row: 0, section: 0), all: message.participantIDs.count > 2)
    }

    func showAttachment(_ attachment: File) {
        guard let url = attachment.url else { return }
        env.router.route(to: url, from: self, options: .modal(embedInNav: true, addDoneButton: true))
    }
}

extension ConversationDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        conversations.first?.messages.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConversationDetailCell = tableView.dequeue(for: indexPath)
        let msg = conversations.first?.messages[indexPath.section]
        cell.update(msg, myID: myID, userMap: userMap)
        cell.onTapAttachment = { [weak self] file in self?.showAttachment(file) }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section + 1 == conversations.first?.messages.count ? 0 : 16
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        let reply = UIContextualAction(style: .normal, title: NSLocalizedString("Reply", comment: "")) { [weak self] _, _, success in
            self?.showReplyFor(indexPath, all: false)
            success(true)
        }
        reply.backgroundColor = .named(.electric)
        reply.image = .icon(.reply, .solid)
        actions.append(reply)

        if let msg = conversations.first?.messages[indexPath.section], msg.participantIDs.count > 2 {
            let replyAll = UIContextualAction(style: .normal, title: NSLocalizedString("Reply All", comment: "")) { [weak self] _, _, success in
                self?.showReplyFor(indexPath, all: true)
                success(true)
            }
            replyAll.backgroundColor = .named(.oxford)
            replyAll.image = .icon(.replyAll, .solid)
            actions.append(replyAll)
        }

        return UISwipeActionsConfiguration(actions: actions)
    }

    func showReplyFor(_  indexPath: IndexPath, all: Bool) {
        guard let conversation = conversations.first else { return }
        env.router.show(ComposeReplyViewController.create(
            conversation: conversation,
            message: conversation.messages[indexPath.section],
            all: all
        ), from: self, options: .modal(embedInNav: true))
    }
}

class ConversationDetailCell: UITableViewCell {
    @IBOutlet weak var messageLabel: DynamicLabel!
    @IBOutlet weak var fromLabel: DynamicLabel!
    @IBOutlet weak var toLabel: DynamicLabel!
    @IBOutlet weak var dateLabel: DynamicLabel!
    @IBOutlet weak var avatar: AvatarView!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var attachmentCollectionView: UICollectionView!

    var onTapAttachment: ((File) -> Void)?
    var message: ConversationMessage?

    func update(_ message: ConversationMessage?, myID: String, userMap: [String: ConversationParticipant]) {
        guard let m = message else { return }
        self.message = m
        messageLabel.text = m.body
        toLabel.text = m.localizedAudience(myID: myID, userMap: userMap)
        fromLabel.text = userMap[ m.authorID ]?.name
        dateLabel.text = DateFormatter.localizedString(from: m.createdAt, dateStyle: .medium, timeStyle: .short)
        avatar.url = userMap[ m.authorID ]?.avatarURL
        avatar.name = userMap[ m.authorID ]?.name ?? ""

        attachmentCollectionView.dataSource = nil
        attachmentCollectionView.isHidden = message?.attachments.isEmpty == true
        if message?.attachments.isEmpty == false {
            attachmentCollectionView.dataSource = self
            attachmentCollectionView.reloadData()
        }
    }

    @objc func tapAttachment(sender: UIButton) {
        guard message?.attachments.count ?? 0 > sender.tag,
            let attachment = message?.attachments[sender.tag] else { return }
        onTapAttachment?(attachment)
    }
}

class ConversationDetailAttachmentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
}

extension ConversationDetailCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        message?.attachments.count ??  0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ConversationDetailAttachmentCollectionViewCell = collectionView.dequeue(for: indexPath)
        guard message?.attachments.count ?? 0 > indexPath.item else { return cell }
        let attachment = message?.attachments[indexPath.item]
        cell.button.tag = indexPath.item
        cell.button.addTarget(self, action: #selector(tapAttachment(sender:)), for: .primaryActionTriggered)
        if let icon = attachment?.attachmentIcon {
            cell.imageView.image = icon
            cell.imageView.contentMode = .scaleAspectFit

            cell.contentView.layer.borderColor = cell.tintColor.cgColor
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.cornerRadius = 8
        } else {
            cell.imageView.load(url: attachment?.previewURL ?? attachment?.thumbnailURL ?? attachment?.url)
            cell.imageView.contentMode = .scaleAspectFill

            cell.contentView.layer.borderColor = nil
            cell.contentView.layer.borderWidth = 0
            cell.contentView.layer.cornerRadius = 0

        }
        cell.imageView.setNeedsLayout()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { CGSize(width: 120, height: 104) }
}
