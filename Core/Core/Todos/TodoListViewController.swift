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
import UIKit

public class TodoListViewController: ScreenViewTrackableViewController, ErrorViewController {
    @IBOutlet weak var emptyDescLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!

    lazy var profileButton = UIBarButtonItem(image: .hamburgerSolid, style: .plain, target: self, action: #selector(openProfile))

    let env = AppEnvironment.shared
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "/to-do",
        attributes: ["customPageViewPath": "/"]
    )
    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
       self?.update()
    }
    lazy var courses = env.subscribe(GetCourses()) { [weak self] in
        self?.update()
    }
    lazy var groups = env.subscribe(GetGroups()) { [weak self] in
        self?.update()
    }
    lazy var todos = env.subscribe(GetTodos(env.app == .student ? .submitting : nil)) { [weak self] in
        self?.update()
    }
    private var lastVoiceoverAnnouncement: String?

    public static func create() -> TodoListViewController {
        return loadFromStoryboard()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        title = NSLocalizedString("To Do", comment: "")
        navigationItem.leftBarButtonItem = profileButton
        navigationItem.titleView = Brand.shared.headerImageView()

        emptyDescLabel.text = NSLocalizedString("Your to do list is empty. Time to recharge.", comment: "")
        emptyTitleLabel.text = NSLocalizedString("Well Done!", comment: "")
        emptyView.accessibilityLabel = "\(emptyTitleLabel.text!) \(emptyDescLabel.text!)"
        errorView.messageLabel.text = NSLocalizedString("There was an error loading items to do. Pull to refresh to try again.", comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        profileButton.accessibilityLabel = NSLocalizedString("Profile Menu", comment: "")

        tableView.backgroundColor = .backgroundLightest
        tableView.refreshControl = CircleRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.separatorColor = .borderMedium

        colors.refresh()
        courses.exhaust()
        groups.exhaust()
        todos.exhaust(force: true)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useGlobalNavStyle()
        tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        refresh()
    }

    func update() {
        guard todos.requested && !todos.pending && !todos.hasNextPage else { return }

        emptyView.isHidden = todos.state != .empty
        errorView.isHidden = todos.state != .error
        loadingView.isHidden = todos.state != .loading || tableView.refreshControl?.isRefreshing == true
        TabBarBadgeCounts.todoListCount = todos.reduce(into: UInt(0)) { badgeCount, todo in
            badgeCount += todo.needsGradingCount > 0 ? todo.needsGradingCount : 1
        }
        tableView.reloadData()
        announceVoiceoverState()
    }

    @objc func refresh() {
        UIAccessibility.post(notification: .announcement, argument: NSLocalizedString("Refreshing", comment: "Downloading new content has started"))
        lastVoiceoverAnnouncement = nil
        todos.exhaust(force: true) { [weak self] _ in
            if self?.todos.hasNextPage == false {
                self?.tableView.refreshControl?.endRefreshing()
            }
            return true
        }
    }

    @objc func openProfile() {
        env.router.route(to: "/profile", from: self, options: .modal())
    }

    private func announceVoiceoverState() {
        if view.window == nil {
            lastVoiceoverAnnouncement = nil
            return
        }
        var announcement: String?

        if emptyView.isHidden == false {
            announcement = emptyView.accessibilityLabel
        } else if errorView.isHidden == false {
            announcement = errorView.messageLabel.text
        } else {
            announcement = String.localizedStringWithFormat(NSLocalizedString("%d items", comment: ""), todos.count)
        }

        if let announcement = announcement {
            if lastVoiceoverAnnouncement == announcement {
                return
            }
            lastVoiceoverAnnouncement = announcement
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
}

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TodoListCell = tableView.dequeue(for: indexPath)
        cell.update(todos[indexPath])
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Analytics.shared.logEvent("todo_selected")
        guard let url = todos[indexPath]?.assignment.htmlURL else { return }
        if env.app == .teacher, let todo = todos[indexPath], todo.type == .grading {
            let speedGrader = url.appendingPathComponent("submissions/speedgrader")
                .appendingQueryItems(URLQueryItem(name: "filter", value: "needs_grading"))
            return env.router.route(to: speedGrader, from: self, options: .modal(.fullScreen, isDismissable: false))
        }
        env.router.route(to: url, from: self, options: .detail)
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let ignore = UIContextualAction(style: .destructive, title: NSLocalizedString("Done", comment: "")) { [weak self] _, _, done in
            self?.ignoreTodo(at: indexPath)
            done(true)
        }
        ignore.backgroundColor = .backgroundDanger
        return UISwipeActionsConfiguration(actions: [ ignore ])
    }

    func ignoreTodo(at indexPath: IndexPath) {
        guard let todo = todos[indexPath], let ignoreURL = todo.ignoreURL else { return }
        Analytics.shared.logEvent("todo_ignored")
        DeleteTodo(id: todo.id, ignoreURL: ignoreURL).fetch { [weak self] _, _, error in performUIUpdate {
            if let error = error { self?.showError(error) }
        } }
    }
}

class TodoListCell: UITableViewCell {
    @IBOutlet weak var accessIconView: AccessIconView!
    @IBOutlet weak var contextLabel: UILabel!
    @IBOutlet weak var needsGradingSpacer: UIView!
    @IBOutlet weak var needsGradingLabel: UILabel!
    @IBOutlet weak var needsGradingView: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        needsGradingLabel.textColor = Brand.shared.primary
        needsGradingView.layer.borderColor = Brand.shared.primary.cgColor
        needsGradingView.layer.borderWidth = 1
        needsGradingView.layer.cornerRadius = needsGradingView.frame.height / 2
    }

    func update(_ todo: Todo?) {
        accessIconView.icon = todo?.assignment.icon
        if todo?.type == .submitting {
            accessIconView.state = nil
        } else {
            accessIconView.published = todo?.assignment.published == true
        }
        backgroundColor = .backgroundLightest
        titleLabel.setText(todo?.assignment.name, style: .textCellTitle)
        subtitleLabel.setText(todo?.dueText, style: .textCellSupportingText)
        tintColor = todo?.contextColor
        contextLabel.textColor = tintColor
        contextLabel.setText(todo?.contextName, style: .textCellTopLabel)
        needsGradingView.isHidden = todo?.type != .grading
        needsGradingSpacer.isHidden = needsGradingView.isHidden
        needsGradingLabel.text = todo?.needsGradingText
        accessibilityIdentifier = "to-do.list.\(todo?.assignment.id ?? "unknown").row"
        accessibilityLabel = [accessIconView.accessibilityLabel, todo?.contextName, todo?.assignment.name, todo?.dueText, todo?.needsGradingText].compactMap { $0 }.joined(separator: ", ")
    }
}
