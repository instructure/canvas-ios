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
    @IBOutlet weak var header: DynamicLabel!
    @IBOutlet weak var filterButton: DynamicButton!
    private var selectedCourse: Course?

    let env = AppEnvironment.shared
    var scope: GetConversationsRequest.Scope? = nil {
        didSet {
            if scope != oldValue {
                refreshConversations(force: true) //  TODO: - this is force refreshing b/c caching does not seem to be working
            }
        }
    }
    var conversations: Store<GetConversations>!

    lazy var enrollments = env.subscribe(GetConversationCourses(role: .student)) { [weak self] in // TODO: - fix role, could be different for teacher
        self?.enrollmentsDidUpdate()
    }

    public static func create() -> ConversationListViewController {
        return loadFromStoryboard()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        title = NSLocalizedString("Inbox", comment: "")
        header.text = NSLocalizedString("All Courses", comment: "")

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

        filterButton.isEnabled = false
        filterButton.setTitleColor(Brand.shared.primary, for: .normal)
        refreshConversations()
        enrollments.refresh(force: true)
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
        refreshConversations(force: true)
    }

    func refreshConversations(force: Bool = false) {
        var filter: String?
        if let context = selectedCourse?.canvasContextID { filter = context }
        conversations = env.subscribe(GetConversations(scope: scope, filter: filter)) { [weak self] in
            self?.update()
        }
        conversations.refresh(force: force)
    }

    func showError(_ error: Error) {
        errorLabel.text = error.localizedDescription
        errorView.isHidden = false
    }

    func update() {
        loadingView.isHidden = true
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
        header.text = selectedCourse == nil ? NSLocalizedString("All Courses", comment: "") : selectedCourse?.name
        if let error = conversations.error {
            showError(error)
        } else if conversations.isEmpty, !conversations.pending {
            emptyView.isHidden = false
        } else if !conversations.pending {
            emptyView.isHidden = true
        }
    }

    func enrollmentsDidUpdate() {
        if enrollments.pending == false && enrollments.requested {
            filterButton.isEnabled = true
        }
    }

    @IBAction func createNewConversation() {
        env.router.route(to: URL(string: "/conversations/compose")!, from: self, options: .modal(embedInNav: true))
    }

    public func courseSelected(course: Course, user: User) {
        let compose = ComposeViewController.create(
            context: .course(course.id),
            observeeID: user.id,
            subject: course.name,
            hiddenMessage: String.localizedStringWithFormat(
                NSLocalizedString("Regarding: %@", bundle: .core, comment: ""),
                user.name
            )
        )
        env.router.show(compose, from: self, options: .modal(embedInNav: true))
    }

    @IBAction func actionFilterButtonPushed(_ sender: UIButton) {
        if selectedCourse != nil {
            updateSelectedCourse(nil)
        } else {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Filter by:", bundle: .core, comment: ""), preferredStyle: .actionSheet)
            for e in enrollments {
                guard let course = e.course else { continue }
                alert.addAction(AlertAction(course.name, style: .default) { [weak self] _ in
                    self?.updateSelectedCourse(course)
                })
            }
            alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            env.router.show(alert, from: self, options: .modal())
        }
    }

    func updateSelectedCourse(_ course: Course?) {
        selectedCourse = course
        let buttonTitle = selectedCourse == nil ? NSLocalizedString("Filter", comment: "") : NSLocalizedString("Clear Filter", comment: "")
        filterButton.setTitle(buttonTitle, for: .normal)
        refreshConversations(force: true)
    }
}

extension ConversationListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = conversations.sections?[section].numberOfObjects ?? 0
        if conversations.hasNextPage, conversations.sections?.count == section + 1 {
            count += 1
        }
        return count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if conversations.hasNextPage && indexPath.row == conversations.sections?[indexPath.section].numberOfObjects {
            conversations.getNextPage()
            return LoadingCell(style: .default, reuseIdentifier: nil)
        }

        let cell: ConversationListCell = tableView.dequeue(for: indexPath)
        if let conversation = conversations[indexPath] {
            cell.update(conversation)
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let conversation = conversations[indexPath] else { return }
        env.router.route(to: "/conversations/\(conversation.id)", from: self, options: .detail)
        markConversation(conversation, workflowState: .read)
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let c = conversations[indexPath] else { return nil }
        var actions: [UIContextualAction] = []

        let title = NSLocalizedString("Unread", comment: "")
        let markAsUnread = UIContextualAction(style: .normal, title: title) { [weak self]  _, _, success in
            self?.markConversation(c, workflowState: .unread)
            success(true)
        }
        markAsUnread.backgroundColor = .named(.electric)
        markAsUnread.image = .icon(.email, .solid)
        actions.append(markAsUnread)

        return UISwipeActionsConfiguration(actions: actions)
    }

    func markConversation(_ c: Conversation, workflowState: ConversationWorkflowState) {
        let u = UpdateConversation(id: c.id, state: workflowState)
        u.fetch(environment: env, force: true) { [weak self] (_, _, error) in
            if let error = error { self?.showError(error) }
        }
    }
}
