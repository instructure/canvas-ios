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

public class PeopleListViewController: UIViewController, ColoredNavViewProtocol {
    @IBOutlet weak var tableView: UITableView!

    public var color: UIColor?
    let env = AppEnvironment.shared
    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()
    var context: Context = ContextModel.currentUser

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var users = env.subscribe(GetContextUsers(context: context)) { [weak self] in
        self?.update()
    }

    public static func create(context: Context) -> PeopleListViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        return controller
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        navigationController?.navigationBar.barStyle == .black ? .lightContent : .default
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        setupTitleViewInNavbar(title: NSLocalizedString("People", bundle: .core, comment: ""))

        tableView.backgroundColor = .named(.backgroundLightest)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.separatorColor = .named(.borderMedium)

        colors.refresh()
        users.refresh()
        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }

    func updateNavBar() {
        guard let name = course.first?.name ?? group.first?.name, let color = course.first?.color ?? group.first?.color else {
            return
        }
        updateNavBar(subtitle: name, color: color)
    }

    func update() {
        tableView.reloadData()
    }

    @objc func refresh() {
        users.refresh(force: true) { [weak self] _ in
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension PeopleListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(PeopleListCell.self, for: indexPath)
        cell.update(user: users[indexPath.row])
        return cell
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            users.getNextPage()
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = users[indexPath.row] else { return }
        env.router.route(to: "/\(context.pathComponent)/users/\(user.id)", from: self, options: [ .detail, .embedInNav ])
    }
}

class PeopleListCell: UITableViewCell {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rolesLabel: UILabel!

    func update(user: User?) {
        backgroundColor = .named(.backgroundLightest)
        avatarView.name = user?.name ?? ""
        avatarView.url = user?.avatarURL
        nameLabel.text = user?.name
        let roles = user?.enrollments?.compactMap { $0.formattedRole }.sorted() ?? []
        if #available(iOS 13, *) {
            rolesLabel.text = ListFormatter.localizedString(from: roles)
        } else {
            rolesLabel.text = roles.joined(separator: ", ")
        }
        rolesLabel.isHidden = roles.isEmpty
    }
}
