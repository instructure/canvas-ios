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
import Core

class StudentListViewController: ScreenViewTrackableViewController {
    lazy var addStudentButton = UIBarButtonItem(
        image: .addSolid,
        style: .plain,
        target: addStudentController,
        action: #selector(AddStudentController.addStudent)
    )
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var loadingView: CircleProgressView!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var tableView: UITableView!

    let env = AppEnvironment.shared
    let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/profile/observees")

    lazy var addStudentController = AddStudentController(presentingViewController: self, handler: { [weak self] error in
        if error == nil {
            self?.students.exhaust()
        }
    })
    lazy var students = env.subscribe(GetObservedStudents(observerID: env.currentSession?.userID ??  "")) { [weak self] in
        self?.update()
    }

    static func create() -> StudentListViewController {
        loadFromStoryboard()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Manage Students", comment: "")
        navigationItem.rightBarButtonItem = addStudentButton

        emptyMessageLabel.text = NSLocalizedString("Add students at the top.", comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Students", comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading students. Pull to refresh to try again.", comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundLightest
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium

        students.exhaust()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.useContextColor(ColorScheme.observeeBlue.color)
    }

    func update() {
        loadingView.isHidden = !students.pending || !students.isEmpty || students.error != nil || refreshControl.isRefreshing
        emptyView.isHidden = students.pending || !students.isEmpty || students.error != nil
        errorView.isHidden = students.error == nil
        tableView.reloadData()
    }

    @objc func refresh() {
        students.exhaust(force: true) { [weak self] _ in
            guard self?.students.hasNextPage != true else { return true }
            self?.refreshControl.endRefreshing()
            return false
        }
    }
}

extension StudentListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(StudentListCell.self, for: indexPath)
        cell.update(students[indexPath.row], indexPath: indexPath)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let id = students[indexPath.row]?.id else { return }
        env.router.route(to: "/profile/observees/\(id)/thresholds", from: self, options: .detail)
    }
}

class StudentListCell: UITableViewCell {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!

    func update(_ student: User?, indexPath: IndexPath) {
        backgroundColor = .backgroundLightest
        accessibilityIdentifier = "StudentListCell.\(indexPath.row)"
        nameLabel.text = student.map {
            User.displayName($0.shortName, pronouns: $0.pronouns)
        }
        avatarView.name = student?.shortName ?? ""
        avatarView.url = student?.avatarURL
    }
}
