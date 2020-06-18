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

public class TodoListViewController: UIViewController, ErrorViewController, PageViewEventViewControllerLoggingProtocol {
    @IBOutlet var loadingView: CircleProgressView!
    @IBOutlet var emptyDescLabel: UILabel!
    @IBOutlet var emptyTitleLabel: UILabel!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var tableView: UITableView!

    lazy var profileButton = UIBarButtonItem(image: .icon(.hamburger, .solid), style: .plain, target: self, action: #selector(openProfile))

    let env = AppEnvironment.shared

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
       self?.update()
    }
    lazy var courses = env.subscribe(GetCourses()) { [weak self] in
        self?.update()
    }
    lazy var groups = env.subscribe(GetGroups()) { [weak self] in
        self?.update()
    }
    lazy var todos = env.subscribe(GetTodos()) { [weak self] in
        self?.update()
    }

    public static func create() -> TodoListViewController {
        return loadFromStoryboard()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        navigationItem.title = NSLocalizedString("To Do", bundle: .core, comment: "")
        navigationItem.leftBarButtonItem = profileButton

        emptyDescLabel.text = NSLocalizedString("Your to do list is empty. Time to recharge.", bundle: .core, comment: "")
        emptyTitleLabel.text = NSLocalizedString("Well Done!", bundle: .core, comment: "")
        emptyView.isHidden = true

        tableView.backgroundColor = .named(.backgroundLightest)
        tableView.refreshControl = CircleRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.separatorColor = .named(.borderMedium)

        colors.refresh()
        courses.exhaust()
        groups.exhaust()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useGlobalNavStyle()
        startTrackingTimeOnViewController()
        refresh()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTrackingTimeOnViewController(eventName: "/to-do", attributes: ["customPageViewPath": "/"])
    }

    func update() {
        guard todos.requested, !todos.pending else { return }
        loadingView.isHidden = true
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
        emptyView.isHidden = !todos.isEmpty
        if !colors.pending, !courses.pending, !groups.pending, let error = todos.error {
            showError(error)
        }
    }

    @objc func refresh() {
        todos.refresh(force: true)
    }

    @objc func openProfile() {
        env.router.route(to: "/profile", from: self, options: .modal())
    }
}

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = todos[indexPath]
        let cell: TodoListCell = tableView.dequeue(for: indexPath)
        cell.accessIconView.icon = todo?.assignment.icon
        cell.accessIconView.state = nil
        cell.titleLabel.text = todo?.assignment.name
        let color = todo?.course?.color ?? todo?.group?.color
        cell.accessIconView.iconView.tintColor = color
        cell.contextLabel.textColor = color
        cell.contextLabel.text = todo?.course?.courseCode ?? todo?.group?.name
        cell.subtitleLabel.text = todo?.subtitleText
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let todo = todos[indexPath],
            let assignmentURL = todo.assignment.htmlURL else {
                return
        }
        Analytics.shared.logEvent("todo_selected")
        env.router.route(to: assignmentURL, from: self, options: .detail)
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let ignore = UIContextualAction(style: .destructive, title: NSLocalizedString("Done", bundle: .core, comment: "")) { [weak self] _, _, done in
            self?.ignoreTodo(at: indexPath)
            done(true)
        }
        ignore.backgroundColor = .named(.backgroundDanger)
        return UISwipeActionsConfiguration(actions: [ ignore ])
    }

    func ignoreTodo(at indexPath: IndexPath) {
        guard let todo = todos[indexPath] else { return }
        let id = todo.id
        Analytics.shared.logEvent("todo_ignored")
        guard let ignoreURL = todo.ignoreURL else { return }
        env.api.makeRequest(DeleteTodoRequest(ignoreURL: ignoreURL)) { [weak self] (_, _, error) in
            if let error = error {
                self?.showError(error)
            }
            self?.env.database.performBackgroundTask { context in
                guard let todo: Todo = context.first(where: #keyPath(Todo.id), equals: id) else { return }
                context.delete(todo)
                try? context.save()
            }
        }
    }
}

class TodoListCell: UITableViewCell {
    @IBOutlet var accessIconView: AccessIconView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contextLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
}
