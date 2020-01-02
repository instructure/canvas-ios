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
        tableView?.refreshControl = refreshControl
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
        }
    }

    func mapUsers(conversation: Conversation?) {
        guard let c = conversation else { return }
        c.participants.forEach { userMap[ $0.id ] = $0 }
    }

    @IBAction func actionReplyClicked(_ sender: Any) {
        print(#function)
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
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0 : 16
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UITableViewHeaderFooterView = tableView.dequeueHeaderFooter(UITableViewHeaderFooterView.self)
        header.backgroundView = UIView()
        header.backgroundView?.backgroundColor = .named(.porcelain)
        return header
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        let reply = UIContextualAction(style: .normal, title: NSLocalizedString("Reply", comment: ""), handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            print("reply")
            success(true)
        })
        reply.backgroundColor = .named(.electric)
        reply.image = .icon(.reply, .solid)
        actions.append(reply)

        let replyAll = UIContextualAction(style: .normal, title: NSLocalizedString("Reply All", comment: ""), handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            print("replyAll")
            success(true)
        })
        replyAll.backgroundColor = .named(.oxford)
        replyAll.image = .icon(.replyAll, .solid)

        if userMap.count > 2 {
            actions.append(replyAll)
        }

        return UISwipeActionsConfiguration(actions: actions)
    }
}

class ConversationDetailCell: UITableViewCell {
    @IBOutlet weak var messageLabel: DynamicLabel!
    @IBOutlet weak var fromLabel: DynamicLabel!
    @IBOutlet weak var toLabel: DynamicLabel!
    @IBOutlet weak var dateLabel: DynamicLabel!
    @IBOutlet weak var avatar: AvatarView!

    func update(_ message: ConversationMessage?, myID: String, userMap: [String: ConversationParticipant]) {
        guard let m = message else { return }
        messageLabel.text = m.body
        toLabel.text = m.localizedAudience(myID: myID, userMap: userMap)
        fromLabel.text = userMap[ m.authorID ]?.name
        dateLabel.text = DateFormatter.localizedString(from: m.createdAt, dateStyle: .medium, timeStyle: .short)
        avatar.url = userMap[ m.authorID ]?.avatarURL
        avatar.name = userMap[ m.authorID ]?.name ?? ""
    }
}
