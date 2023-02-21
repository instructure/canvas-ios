//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class GroupNavigationViewController: ScreenViewTrackableTableViewController, ColoredNavViewProtocol, ErrorViewController {
    let env = AppEnvironment.shared
    var context = Context.currentUser
    var color: UIColor?
    let titleSubtitleView = TitleSubtitleView.create()
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/\(context.pathComponent)")

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var groups = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.update()
    }
    lazy var tabs = env.subscribe(GetContextTabs(context: context)) { [weak self] in
        self?.update()
    }

    static func create(context: Context) -> GroupNavigationViewController {
        let controller = GroupNavigationViewController()
        controller.context = context
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: groups.first?.name ?? "")

        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundLightest
        tableView.registerCell(RightDetailTableViewCell.self)
        tableView.separatorColor = .borderMedium
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()

        colors.refresh()
        groups.refresh()
        tabs.exhaust()
        update()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    func update() {
        if let group = groups.first {
            titleSubtitleView.title = group.name
            if !colors.pending {
                color = group.color
                navigationController?.navigationBar.useContextColor(group.color)
            }
        }
        if !colors.pending, !groups.pending, !tabs.pending, let error = tabs.error {
            showError(error)
        }
        tableView.reloadData()
    }
}

extension GroupNavigationViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tab = tabs[indexPath]
        let cell: RightDetailTableViewCell = tableView.dequeue(for: indexPath)
        cell.textLabel?.text = tab?.label
        cell.imageView?.image = tab?.icon
        cell.imageView?.tintColor = color
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tab = tabs[indexPath] else { return }
        switch tab.id {
        case "home":
            env.router.route(to: "\(context.pathComponent)/activity_stream", from: self)
        case "wiki", "pages":
            env.router.route(to: "\(context.pathComponent)/pages", from: self)
        default:
            if let url = tab.htmlURL {
                env.router.route(to: url, from: self)
            }
        }
    }
}
