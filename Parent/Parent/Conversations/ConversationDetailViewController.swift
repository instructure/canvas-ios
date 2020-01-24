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

    func showAttachment(_ url: URL) {
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
        cell.update(msg, myID: myID, userMap: userMap, parent: self)
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
