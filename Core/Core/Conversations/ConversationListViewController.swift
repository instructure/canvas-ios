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

public class ConversationListViewController: UIViewController, ConversationCoursesActionSheetDelegate {
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var composeButton: UIButton!
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    let env = AppEnvironment.shared
    lazy var conversations = env.subscribe(GetConversations()) { [weak self] in
        self?.update()
    }

    public static func create() -> ConversationListViewController {
        return loadFromStoryboard()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        title = NSLocalizedString("Inbox", comment: "")

        composeButton.accessibilityLabel = NSLocalizedString("Compose new message", comment: "")
        composeButton.layer.shadowColor = UIColor.named(.backgroundDarkest).cgColor

        emptyView.titleText = NSLocalizedString("Inbox Zero", comment: "")
        emptyView.bodyText = NSLocalizedString("You’re all caught up", comment: "")
        emptyView.isHidden = true

        errorView.isHidden = true
        retryButton.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
        retryButton.layer.borderColor = UIColor.named(.borderDark).cgColor

        tableView.refreshControl = CircleRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl?.tintColor = Brand.shared.primary
        tableView.separatorColor = .named(.borderMedium)

        conversations.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useGlobalNavStyle()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func refresh() {
        emptyView.isHidden = true
        errorView.isHidden = true
        tableView.refreshControl?.beginRefreshing()
        conversations.refresh(force: true)
    }

    func showError(_ error: Error) {
        errorLabel.text = error.localizedDescription
        errorView.isHidden = false
    }

    func update() {
        loadingView.isHidden = true
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
        if let error = conversations.error {
            showError(error)
        } else if conversations.isEmpty, !conversations.pending {
            emptyView.isHidden = false
        }
    }

    @IBAction func createNewConversation() {
        env.router.show(ConversationCoursesActionSheet.create(delegate: self), from: self, options: .modal())
    }

    public func courseSelected(course: Course, user: User) {
        let compose = ComposeViewController.create(
            context: ContextModel(.course, id: course.id),
            observeeID: user.id,
            subject: course.name,
            hiddenMessage: String.localizedStringWithFormat(
                NSLocalizedString("Regarding: %@", bundle: .core, comment: ""),
                user.name
            )
        )
        env.router.show(compose, from: self, options: .modal(embedInNav: true))
    }
}

extension ConversationListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConversationListCell = tableView.dequeue(for: indexPath)
        if let conversation = conversations[indexPath] {
            cell.update(conversation)
        }
        return cell
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            conversations.getNextPage()
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let conversation = conversations[indexPath] else { return }
        env.router.route(to: .conversation(conversation.id), from: self)
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let c = conversations[indexPath] else { return nil }
        var actions: [UIContextualAction] = []

        let title = NSLocalizedString("Unread", comment: "")
        let markAsUnread = UIContextualAction(style: .normal, title: title) { [weak self]  _, _, success in
            self?.markConversationAsUnread(c)
            success(true)
        }
        markAsUnread.backgroundColor = .named(.electric)
        markAsUnread.image = .icon(.email, .solid)
        actions.append(markAsUnread)

        return UISwipeActionsConfiguration(actions: actions)
    }

    func markConversationAsUnread(_ c: Conversation) {
        let u = UpdateConversation(id: c.id, state: .unread)
        u.fetch(environment: env, force: true) { [weak self] (apiConversation, _, error) in
            self?.conversations.refresh(force: true)
        }
    }
}
