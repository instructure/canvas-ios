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

class NotificationChannelsViewController: UIViewController {
    let env = AppEnvironment.shared
    var channelType = CommunicationChannelType.email

    lazy var channels = env.subscribe(GetCommunicationChannels()) { [weak self] in
        self?.reloadData()
    }
    var rows: [CommunicationChannel] = []

    let tableView = UITableView(frame: .zero, style: .grouped)

    static func create(type: CommunicationChannelType) -> NotificationChannelsViewController {
        let controller = NotificationChannelsViewController()
        controller.channelType = type
        return controller
    }

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = channelType.name

        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundGrouped
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = CircleRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        tableView.registerCell(RightDetailTableViewCell.self)
        tableView.sectionFooterHeight = 0
        tableView.separatorColor = .borderMedium
        tableView.separatorInset = .zero
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
        refresh()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .screenChanged, argument: tableView)
    }

    @objc func refresh(sender: Any? = nil) {
        channels.exhaust(while: { _ in true })
    }

    func reloadData() {
        rows = channels.filter {
            $0.type == channelType &&
            ((channelType == .email && $0.id != PushNotificationsInteractor.shared.emailAsPushChannelID) ||
             channelType != .email)
        } .sorted { $0.address < $1.address }
        if !channels.pending {
            tableView.refreshControl?.endRefreshing()
        }
        tableView.reloadData()
    }
}

extension NotificationChannelsViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = rows[indexPath.row]
        let cell: RightDetailTableViewCell = tableView.dequeue(for: indexPath)
        cell.backgroundColor = .backgroundLightest
        cell.textLabel?.text = channel.address
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let channel = rows[indexPath.row]
        show(NotificationCategoriesViewController.create(
            title: channel.address,
            channelID: channel.id,
            type: channel.type
        ), sender: self)
    }
}
