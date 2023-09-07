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

public class ProfileSettingsViewController: ScreenViewTrackableViewController {
    let env = AppEnvironment.shared
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/profile/settings")

    private var sections: [Section] = []
    private var onElementaryViewToggleChanged: (() -> Void)?

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
    private var isPairingWithObserverAllowed = false {
        didSet {
            reloadData()
        }
    }
    private var termsOfServiceRequest: APITask?

    private var channelTypeRows: [Row]?

    public static func create(onElementaryViewToggleChanged: (() -> Void)? = nil) -> ProfileSettingsViewController {
        let viewController = ProfileSettingsViewController()
        viewController.onElementaryViewToggleChanged = onElementaryViewToggleChanged
        return viewController
    }

    public override func loadView() {
        view = tableView
        view.accessibilityIdentifier = "settings.tableView"
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Settings", bundle: .core, comment: "")

        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundGrouped
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = CircleRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        tableView.registerHeaderFooterView(GroupedSectionHeaderView.self, fromNib: false)
        tableView.registerCell(RightDetailTableViewCell.self)
        tableView.registerCell(SwitchTableViewCell.self)
        tableView.sectionFooterHeight = 0
        tableView.separatorColor = .borderMedium
        tableView.separatorInset = .zero
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
        refresh()
    }

    @objc func refresh(sender: Any? = nil) {
        let force = sender != nil
        channels.exhaust(while: { _ in true })
        profile.refresh(force: force)
        refreshTermsOfService()
    }

    func reloadData() {
        var channelTypes: [CommunicationChannelType: [GeneratedCommunicationChannel]] = [:]
        for channel in channels where channel.type != .push {
            let isOverrided: Bool = channel.id == NotificationManager.shared.emailAsPushChannelID
            let generatedChannel = GeneratedCommunicationChannel(type: isOverrided ? .push : channel.type, id: channel.id)
            channelTypes[generatedChannel.type] = channelTypes[generatedChannel.type] ?? []
            channelTypes[generatedChannel.type]?.append(generatedChannel)
        }

        channelTypeRows = channelTypes.values.map({ channels -> Row in
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
        }).sorted(by: { $0.title < $1.title })

        var sections: [Section] = [preferencesSection]

        if OfflineModeAssembly.make().isFeatureFlagEnabled(), env.app == .student {
            sections.append(offlineSettingSection)
        }

        sections.append(
            Section(NSLocalizedString("Legal", bundle: .core, comment: ""), rows: [
                Row(NSLocalizedString("Privacy Policy", bundle: .core, comment: "")) { [weak self] in
                    guard let self = self else { return }
                    self.env.router.route(to: "https://www.instructure.com/canvas/privacy/", from: self)
                },
                Row(NSLocalizedString("Terms of Use", bundle: .core, comment: "")) { [weak self] in
                    guard let self = self else { return }
                    self.env.router.route(to: "/accounts/self/terms_of_service", from: self)
                },
                Row(NSLocalizedString("Canvas on GitHub", bundle: .core, comment: "")) { [weak self] in
                    guard let self = self else { return }
                    self.env.router.route(to: "https://github.com/instructure/canvas-ios", from: self)
                },
            ])
        )
        self.sections = sections

        if !channels.pending && !profile.pending && termsOfServiceRequest == nil {
            tableView.refreshControl?.endRefreshing()
        }
        tableView.reloadData()
    }

    private var offlineSettingSection: Section {
        let detailLabel: String = {
            guard let defaults = env.userDefaults else {
                return ""
            }

            return CourseSyncSettingsInteractorLive(storage: defaults).getOfflineSyncSettingsLabel()
        }()
        return Section(NSLocalizedString("Offline Content", comment: ""), rows: [
                Row(NSLocalizedString("Synchronization", comment: ""),
                    detail: detailLabel) { [weak self] in
                        guard let self = self else { return }
                        self.env.router.route(to: "/offline/settings", from: self)
                    },
               ])
    }

    private var preferencesSection: Section {
        Section(NSLocalizedString("Preferences", bundle: .core, comment: ""), rows: preferencesRows)
    }

    private var preferencesRows: [Any] {
        var rows = [Any]()
        rows.append(contentsOf: landingPageRow)
        rows.append(contentsOf: interfaceStyleSettings)
        rows.append(contentsOf: k5DashboardSwitch)
        rows.append(contentsOf: channelTypeRows ?? [])
        rows.append(contentsOf: pairWithObserverButton)

        if AppEnvironment.shared.app == .student {
            let row = Row(NSLocalizedString("Subscribe to Calendar Feed",
                                            bundle: .core,
                                            comment: ""),
                          hasDisclosure: false) { [weak self] in
                guard let url = self?.profile.first?.calendarURL else { return }
                self?.env.loginDelegate?.openExternalURL(url)
            }
            rows.append(contentsOf: [row])
        }

        rows.append(contentsOf: aboutRow)

        return rows
    }

    private var interfaceStyleSettings: [Row] {
        let options = [
            ItemPickerItem(title: NSLocalizedString("System Settings", bundle: .core, comment: "")),
            ItemPickerItem(title: NSLocalizedString("Light Theme", bundle: .core, comment: "")),
            ItemPickerItem(title: NSLocalizedString("Dark Theme", bundle: .core, comment: "")),
        ]
        let selectedStyleIndex = env.userDefaults?.interfaceStyle?.rawValue ?? 0

        return [
            Row(NSLocalizedString("Appearance", bundle: .core, comment: ""), detail: options[selectedStyleIndex].title) { [weak self] in
                guard let self = self else { return }

                let pickerVC = ItemPickerViewController.create(title: NSLocalizedString("Appearance", bundle: .core, comment: ""),
                                                               sections: [ ItemPickerSection(items: options) ],
                                                               selected: IndexPath(row: selectedStyleIndex, section: 0)) { indexPath in
                    if let window = self.env.window, let style = UIUserInterfaceStyle(rawValue: indexPath.row) {
                        window.updateInterfaceStyle(style)
                        self.env.userDefaults?.interfaceStyle = style
                    }
                }
                self.show(pickerVC, sender: self)
            },
        ]
    }

    private var landingPageRow: [Row] {
        return [
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
        ]
    }

    private var pairWithObserverButton: [Row] {
        guard isPairingWithObserverAllowed else { return [] }

        return [
            Row(NSLocalizedString("Pair with Observer", bundle: .core, comment: "")) { [weak self] in
                guard let self = self else { return }
                let vc = PairWithObserverViewController.create()
                self.env.router.show(vc, from: self, options: .modal(.formSheet, isDismissable: true, embedInNav: true, addDoneButton: true))
            },
        ]
    }

    private var aboutRow: [Row] {
        return [
            Row(NSLocalizedString("About", comment: "")) { [weak self] in
                guard let self else { return }
                self.env.router.route(to: "/about", from: self)
            },
        ]
    }

    private var k5DashboardSwitch: [Any] {
        guard AppEnvironment.shared.k5.isK5Account, AppEnvironment.shared.k5.isRemoteFeatureFlagEnabled else { return [] }

        let row = Switch(NSLocalizedString("Homeroom View", bundle: .core, comment: ""), initialValue: AppEnvironment.shared.userDefaults?.isElementaryViewEnabled ?? false) { [weak self] isOn in
            AppEnvironment.shared.userDefaults?.isElementaryViewEnabled = isOn
            self?.onElementaryViewToggleChanged?()
        }
        return [row]
    }

    private func refreshTermsOfService() {
        if AppEnvironment.shared.app == .teacher {
            if isPairingWithObserverAllowed {
                isPairingWithObserverAllowed = false
            }
            return
        }

        termsOfServiceRequest = env.api.makeRequest(GetAccountTermsOfServiceRequest()) { [weak self] response, _, _ in
            self?.termsOfServiceRequest = nil
            let isPairingAllowed: Bool

            if let self_registration = response?.self_registration_type {
                isPairingAllowed = [APISelfRegistrationType.all, .observer].contains(self_registration)
            } else {
                isPairingAllowed = false
            }

            performUIUpdate {
                self?.isPairingWithObserverAllowed = isPairingAllowed
            }
        }
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

        if let row = row as? Row {
            let cell: RightDetailTableViewCell = tableView.dequeue(for: indexPath)
            cell.backgroundColor = .backgroundLightest
            cell.textLabel?.text = row.title
            cell.detailTextLabel?.text = row.detail
            cell.accessoryType = row.hasDisclosure ? .disclosureIndicator : .none
            return cell
        } else if let switchRow = row as? Switch {
            let cell: SwitchTableViewCell = tableView.dequeue(for: indexPath)
            cell.toggle.isOn = switchRow.value
            cell.onToggleChange = { toggle in
                switchRow.value = toggle.isOn
            }
            cell.backgroundColor = .backgroundLightest
            cell.textLabel?.text = switchRow.title
            return cell
        }

        return UITableViewCell()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]

        if let row = row as? Row {
            row.onSelect()
        } else if let switchCell = tableView.cellForRow(at: indexPath) as? SwitchTableViewCell, let switchRow = row as? Switch {
            let newValue = !switchCell.toggle.isOn
            switchCell.toggle.setOn(newValue, animated: true)
            switchRow.value = newValue
        }

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
    let rows: [Any]

    init(_ title: String, rows: [Any]) {
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

private class Switch {
    let title: String
    var value: Bool {
        didSet {
            onSelect(value)
        }
    }
    private let onSelect: (_ value: Bool) -> Void

    init(_ title: String, initialValue: Bool = false, onSelect: @escaping (_ value: Bool) -> Void) {
        self.title = title
        self.value = initialValue
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

struct GeneratedCommunicationChannel {
    var type: CommunicationChannelType
    var id: String
}
