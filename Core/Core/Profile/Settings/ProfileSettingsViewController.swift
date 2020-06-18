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

public class ProfileSettingsViewController: UIViewController, PageViewEventViewControllerLoggingProtocol {
    let env = AppEnvironment.shared
    private var sections: [Section] = []

    private var landingPage: LandingPage {
        get { return LandingPage(rawValue: env.userDefaults?.landingPath ?? "/") ?? .dashboard }
        set { env.userDefaults?.landingPath = newValue.rawValue }
    }

    lazy var channels = env.subscribe(GetCommunicationChannels()) { [weak self] in
        self?.reloadData()
    }

    lazy var profile = env.subscribe(GetUserProfile()) { [weak self] in
        self?.reloadData()
    }

    let tableView = UITableView(frame: .zero, style: .grouped)

    public static func create() -> ProfileSettingsViewController {
        return ProfileSettingsViewController()
    }

    public override func loadView() {
        view = tableView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Settings", bundle: .core, comment: "")

        tableView.backgroundColor = .named(.backgroundGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = CircleRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        tableView.registerHeaderFooterView(GroupedSectionHeaderView.self, fromNib: false)
        tableView.registerCell(RightDetailTableViewCell.self)
        tableView.sectionFooterHeight = 0
        tableView.separatorColor = .named(.borderMedium)
        tableView.separatorInset = .zero
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
        refresh()
        startTrackingTimeOnViewController()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTrackingTimeOnViewController(eventName: "/profile/settings")
    }

    @objc func refresh(sender: Any? = nil) {
        let force = sender != nil
        channels.exhaust(while: { _ in true })
        profile.refresh(force: force)
    }

    func reloadData() {
        var channelTypes: [CommunicationChannelType: [CommunicationChannel]] = [:]
        for channel in channels {
            channelTypes[channel.type] = channelTypes[channel.type] ?? []
            channelTypes[channel.type]?.append(channel)
        }
        sections = [
            Section(NSLocalizedString("Preferences", bundle: .core, comment: ""), rows: [
                Row(NSLocalizedString("Landing Page", bundle: .core, comment: ""), detail: landingPage.name) { [weak self] in
                    guard let self = self else { return }
                    self.show(ItemPickerViewController.create(
                        title: NSLocalizedString("Landing Page", bundle: .core, comment: ""),
                        sections: [ ItemPickerSection(items: LandingPage.appCases.map { page in
                            ItemPickerItem(title: page.name)
                        }), ],
                        selected: LandingPage.appCases.firstIndex(of: self.landingPage).flatMap {
                            IndexPath(row: $0, section: 0)
                        },
                        delegate: self
                    ), sender: self)
                },
            ] + channelTypes.values.map({ channels -> Row in
                Row(channels[0].type.name) { [weak self] in
                    guard let self = self else { return }
                    if channels.count == 1, let channel = channels.first {
                        let vc = NotificationCategoriesViewController.create(
                            title: channel.type.name,
                            channelID: channel.id,
                            type: channel.type
                        )
                        self.env.router.show(vc, from: self)
                    } else {
                        let vc = NotificationChannelsViewController.create(type: channels[0].type)
                        self.env.router.show(vc, from: self)
                    }
                }
            }).sorted(by: { $0.title < $1.title }) + [
                Row(NSLocalizedString("Pair with Observer", bundle: .core, comment: "")) { [weak self] in
                    guard let sself = self else { return }
                    let vc = PairWithObserverViewController.create()
                    sself.env.router.show(vc, from: sself, options: .modal(.formSheet, isDismissable: true, embedInNav: true, addDoneButton: true))
                },
                Row(NSLocalizedString("Subscribe to Calendar Feed", bundle: .core, comment: ""), hasDisclosure: false) { [weak self] in
                    guard let url = self?.profile.first?.calendarURL else { return }
                    self?.env.loginDelegate?.openExternalURL(url)
                },
            ]),

            Section(NSLocalizedString("Legal", bundle: .core, comment: ""), rows: [
                Row(NSLocalizedString("Privacy Policy", bundle: .core, comment: "")) { [weak self] in
                    guard let self = self else { return }
                    self.env.router.route(to: "https://www.instructure.com/policies/privacy/", from: self)
                },
                Row(NSLocalizedString("Terms of Use", bundle: .core, comment: "")) { [weak self] in
                    guard let self = self else { return }
                    self.env.router.route(to: "/accounts/self/terms_of_service", from: self)
                },
                Row(NSLocalizedString("Canvas on GitHub", bundle: .core, comment: "")) { [weak self] in
                    guard let self = self else { return }
                    self.env.router.route(to: "https://github.com/instructure/canvas-ios", from: self)
                },
            ]),
        ]
        if !channels.pending && !profile.pending {
            tableView.refreshControl?.endRefreshing()
        }
        tableView.reloadData()
    }
}

extension ProfileSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: GroupedSectionHeaderView = tableView.dequeueHeaderFooter()
        header.titleLabel.text = sections[section].title
        return header
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell: RightDetailTableViewCell = tableView.dequeue(for: indexPath)
        cell.backgroundColor = .named(.backgroundGroupedCell)
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.detail
        cell.accessoryType = row.hasDisclosure ? .disclosureIndicator : .none
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].rows[indexPath.row].onSelect()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProfileSettingsViewController: ItemPickerDelegate {
    public func itemPicker(_ itemPicker: ItemPickerViewController, didSelectRowAt indexPath: IndexPath) {
        landingPage = LandingPage.appCases[indexPath.row]
        reloadData()
    }
}

private struct Section {
    let title: String
    let rows: [Row]

    init(_ title: String, rows: [Row]) {
        self.title = title
        self.rows = rows
    }
}

private struct Row {
    let title: String
    let detail: String?
    let style: UITableViewCell.CellStyle
    let hasDisclosure: Bool
    let onSelect: () -> Void

    init(_ title: String, detail: String? = nil, style: UITableViewCell.CellStyle = .value1, hasDisclosure: Bool = true, onSelect: @escaping () -> Void) {
        self.title = title
        self.detail = detail
        self.style = style
        self.hasDisclosure = hasDisclosure
        self.onSelect = onSelect
    }
}

private enum LandingPage: String {
    case dashboard = "/"
    case calendar = "/calendar"
    case todo = "/to-do"
    case notifications = "/notifications"
    case inbox = "/conversations"

    var name: String {
        switch self {
        case .dashboard:
            if Bundle.main.isTeacherApp {
                return NSLocalizedString("Courses", bundle: .core, comment: "")
            }
            return NSLocalizedString("Dashboard", bundle: .core, comment: "")
        case .calendar:
            return NSLocalizedString("Calendar", bundle: .core, comment: "")
        case .todo:
            return NSLocalizedString("To Do", bundle: .core, comment: "")
        case .notifications:
            return NSLocalizedString("Notifications", bundle: .core, comment: "")
        case .inbox:
            return NSLocalizedString("Inbox", bundle: .core, comment: "")
        }
    }

    static var appCases: [LandingPage] = {
        return Bundle.main.isTeacherApp
            ? [ .dashboard, .todo, .inbox ]
            : [ .dashboard, .calendar, .todo, .notifications, .inbox ]
    }()
}
