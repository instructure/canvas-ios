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
    var isNotificationsEnabled = false
    private var sections: [Section] = []

    private var landingPage: LandingPage {
        get { LandingPage(rawValue: env.userDefaults?.landingPath ?? "/") ?? .dashboard }
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

        title = NSLocalizedString("Settings", comment: "")

        tableView.dataSource = self
        tableView.delegate = self

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: UIApplication.didBecomeActiveNotification, object: nil)

        refresh()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

        UNUserNotificationCenter.current().getNotificationSettings() { [weak self] settings in DispatchQueue.main.async {
            self?.isNotificationsEnabled = settings.authorizationStatus == .authorized
            self?.reloadData()
        } }
    }

    func reloadData() {
        sections = [
            Section(rows: [
                Row(NSLocalizedString("Landing Page", comment: ""), detail: landingPage.name) { [weak self] in
                    guard let self = self else { return }
                    self.show(ItemPickerViewController.create(
                        title: NSLocalizedString("Landing Page", comment: ""),
                        sections: [ItemPickerSection(items: LandingPage.allCases.map { page in
                            ItemPickerItem(title: page.name)
                        })],
                        selected: LandingPage.allCases.firstIndex(of: self.landingPage).flatMap {
                            IndexPath(row: $0, section: 0)
                        },
                        delegate: self
                    ), sender: self)
                },
            ]),

            Section(NSLocalizedString("Notifications", comment: ""), rows: [
                Row(NSLocalizedString("Allow Notifications in Settings", comment: "")) { [weak self] in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    self?.env.loginDelegate?.openExternalURL(url)
                },
            ], footer: isNotificationsEnabled
                ? NSLocalizedString("All notifications are currently enabled.", comment: "")
                : NSLocalizedString("All notifications are currently disabled.", comment: "")
            ),
            Section(rows: channels.map { channel in
                Row(channel.type.name, detail: channel.address, style: .subtitle) { [weak self] in
                    guard let self = self else { return }
                    self.show(NotificationCategoriesViewController.create(channelID: channel.id, type: channel.type), sender: self)
                }
            }),

            Section(rows: [
                Row(NSLocalizedString("Calendar Feed", comment: ""), hasDisclosure: false) { [weak self] in
                    guard let url = self?.profile.first?.calendarURL else { return }
                    self?.env.loginDelegate?.openExternalURL(url)
                },
            ]),

            Section(rows: [
                Row(NSLocalizedString("Open Source Components", comment: "")) { [weak self] in
                    self?.show(OpenSourceComponentsViewController.create(), sender: self)
                },
                Row(NSLocalizedString("Terms of Use", comment: "")) { [weak self] in
                    guard let self = self else { return }
                    self.env.router.route(to: .termsOfService(), from: self, options: nil)
                },
                Row(NSLocalizedString("Privacy Policy", comment: "")) { [weak self] in
                    guard let self = self else { return }
                    self.env.router.route(to: "https://www.instructure.com/policies/privacy/", from: self, options: nil)
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

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = UITableViewCell(style: row.style, reuseIdentifier: nil)
        cell.textLabel?.text = row.title
        cell.textLabel?.textColor = .named(.textDarkest)
        cell.textLabel?.font = .scaledNamedFont(.semibold16)
        cell.detailTextLabel?.text = row.detail
        cell.detailTextLabel?.textColor = .named(.textDark)
        switch row.style {
        case .value1:
            cell.detailTextLabel?.font = .scaledNamedFont(.semibold16)
        default:
            cell.detailTextLabel?.font = .scaledNamedFont(.medium14)
        }
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
        landingPage = LandingPage.allCases[indexPath.row]
        reloadData()
    }
}

private struct Section {
    let title: String?
    let rows: [Row]
    let footer: String?

    init(_ title: String? = nil, rows: [Row], footer: String? = nil) {
        self.title = title
        self.rows = rows
        self.footer = footer
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

private enum LandingPage: String, CaseIterable {
    case dashboard = "/"
    case calendar = "/calendar"
    case todo = "/to-do"
    case notifications = "/notifications"
    case inbox = "/conversations"

    var name: String {
        switch self {
        case .dashboard:
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
}
