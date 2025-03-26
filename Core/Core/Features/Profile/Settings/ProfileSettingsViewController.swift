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
import Combine

public class ProfileSettingsViewController: ScreenViewTrackableViewController {
    let env = AppEnvironment.shared
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/profile/settings")

    private var sections: [Section] = []
    private var onElementaryViewToggleChanged: (() -> Void)?
    private var showInboxSignatureSettings = false
    private var isInboxSignatureEnabled = false
    private var offlineModeInteractor = OfflineModeAssembly.make()
    private var inboxSettingsInteractor = InboxSettingsInteractorLive()
    private var subscriptions = Set<AnyCancellable>()

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

        title = String(localized: "Settings", bundle: .core)

        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundLightest
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

        offlineModeInteractor
            .observeIsOfflineMode()
            .sink { [weak self] _ in
                self?.networkStateDidChange()
            }
            .store(in: &subscriptions)

        inboxSettingsInteractor
            .isFeatureEnabled
            .sink { [weak self] isFeatureEnabled in
                self?.showInboxSignatureSettings = isFeatureEnabled
                self?.reloadData()
            }
            .store(in: &subscriptions)

        inboxSettingsInteractor
            .settings
            .sink { [weak self] inboxSettings in
                guard let inboxSettings else { return }
                self?.isInboxSignatureEnabled = inboxSettings.useSignature
                self?.reloadData()
            }
            .store(in: &subscriptions)
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
        var channelTypes: [CommunicationChannelType: [CommunicationChannel]] = [:]
        for channel in channels {
            channelTypes[channel.type] = channelTypes[channel.type] ?? []
            channelTypes[channel.type]?.append(channel)
        }

        channelTypeRows = channelTypes.values.map({ channels -> Row in
            Row(channels[0].type.name, isSupportedOffline: false) { [weak self] in
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

        if showInboxSignatureSettings {
            sections.append(inboxSignatureSetingsSection)
        }

        if OfflineModeAssembly.make().isFeatureFlagEnabled(), env.app == .student {
            sections.append(offlineSettingSection)
        }

        sections.append(
            Section(String(localized: "Legal", bundle: .core), rows: [
                Row(String(localized: "Privacy Policy", bundle: .core), isSupportedOffline: false, accessibilityTraits: .link) { [weak self] in
                    guard let self = self else { return }
                    self.env.router.route(to: "https://www.instructure.com/canvas/privacy/", from: self)
                },
                Row(String(localized: "Terms of Use", bundle: .core), isSupportedOffline: false) { [weak self] in
                    guard let self = self else { return }
                    self.env.router.route(to: "/accounts/self/terms_of_service", from: self)
                }
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
        return Section(String(localized: "Offline Content", bundle: .core), rows: [
                Row(String(localized: "Synchronization", bundle: .core),
                    detail: detailLabel,
                    isSupportedOffline: true) { [weak self] in
                        guard let self = self else { return }
                        self.env.router.route(to: "/offline/settings", from: self)
                    }
               ])
    }

    private var inboxSignatureSetingsSection: Section {
        let detailLabel = isInboxSignatureEnabled
            ? String(localized: "Enabled", bundle: .core)
            : String(localized: "Not set", bundle: .core)

        return Section(String(localized: "Inbox", bundle: .core), rows: [
                Row(String(localized: "Inbox Signature", bundle: .core),
                    detail: detailLabel,
                    isSupportedOffline: true) { [weak self] in
                        guard let self = self else { return }
                        self.env.router.route(to: "/conversations/settings", from: self)
                    }
               ])
    }

    private var preferencesSection: Section {
        Section(String(localized: "Preferences", bundle: .core), rows: preferencesRows)
    }

    private var preferencesRows: [Any] {
        var rows = [Any]()
        rows.append(contentsOf: landingPageRow)
        rows.append(contentsOf: interfaceStyleSettings)
        rows.append(contentsOf: k5DashboardSwitch)
        rows.append(contentsOf: channelTypeRows ?? [])
        rows.append(contentsOf: pairWithObserverButton)

        if AppEnvironment.shared.app == .student {
            let row = Row(String(localized: "Subscribe to Calendar Feed", bundle: .core),
                          hasDisclosure: false,
                          isSupportedOffline: false) { [weak self] in
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
            ItemPickerItem(title: String(localized: "System Settings", bundle: .core)),
            ItemPickerItem(title: String(localized: "Light Theme", bundle: .core)),
            ItemPickerItem(title: String(localized: "Dark Theme", bundle: .core))
        ]
        let selectedStyleIndex = env.userDefaults?.interfaceStyle?.rawValue ?? 0

        return [
            Row(String(localized: "Appearance", bundle: .core), detail: options[selectedStyleIndex].title, isSupportedOffline: true) { [weak self] in
                guard let self = self else { return }

                let pickerVC = ItemPickerViewController.create(title: String(localized: "Appearance", bundle: .core),
                                                               sections: [ ItemPickerSection(items: options) ],
                                                               selected: IndexPath(row: selectedStyleIndex, section: 0)) { indexPath in
                    if let window = self.env.window, let style = UIUserInterfaceStyle(rawValue: indexPath.row) {
                        window.updateInterfaceStyle(style)
                        self.env.userDefaults?.interfaceStyle = style
                    }
                }
                self.show(pickerVC, sender: self)
            }
        ]
    }

    private var landingPageRow: [Row] {
        return [
            Row(String(localized: "Landing Page", bundle: .core), detail: landingPage.name, isSupportedOffline: true) { [weak self] in
                guard let self = self else { return }
                self.show(ItemPickerViewController.create(
                    title: String(localized: "Landing Page", bundle: .core),
                    sections: [ ItemPickerSection(items: LandingPage.appCases.map { page in
                        ItemPickerItem(title: page.name)
                    }) ],
                    selected: LandingPage.appCases.firstIndex(of: self.landingPage).flatMap {
                        IndexPath(row: $0, section: 0)
                    },
                    delegate: self
                ), sender: self)
            }
        ]
    }

    private var pairWithObserverButton: [Row] {
        guard isPairingWithObserverAllowed else { return [] }

        return [
            Row(String(localized: "Pair with Observer", bundle: .core), isSupportedOffline: false) { [weak self] in
                guard let self = self else { return }
                let vc = PairWithObserverViewController.create()
                self.env.router.show(vc, from: self, options: .modal(.formSheet, isDismissable: true, embedInNav: true, addDoneButton: true))
            }
        ]
    }

    private var aboutRow: [Row] {
        return [
            Row(String(localized: "About", bundle: .core), isSupportedOffline: true) { [weak self] in
                guard let self else { return }
                self.env.router.route(to: "/about", from: self)
            }
        ]
    }

    private var k5DashboardSwitch: [Any] {
        guard AppEnvironment.shared.k5.isK5Account, AppEnvironment.shared.k5.isRemoteFeatureFlagEnabled else { return [] }

        let row = Switch(String(localized: "Homeroom View", bundle: .core),
                         initialValue: AppEnvironment.shared.userDefaults?.isElementaryViewEnabled ?? false,
                         isSupportedOffline: true) { [weak self] isOn in
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

    private func networkStateDidChange() {
        tableView.reloadData()
    }
}

extension ProfileSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: GroupedSectionHeaderView = tableView.dequeueHeaderFooter()
        let section = sections[section]
        header.update(title: section.title, itemCount: section.rows.count)
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
            if row.hasDisclosure {
                cell.setupInstDisclosureIndicator()
            } else {
                cell.accessoryView = nil
            }
            let isAvailable = !offlineModeInteractor.isOfflineModeEnabled() || row.isSupportedOffline
            cell.contentView.alpha = isAvailable ? 1 : 0.5
            if let accessibilityTraits = row.accessibilityTraits {
                cell.accessibilityTraitsOverride = accessibilityTraits
            }
            return cell
        } else if let switchRow = row as? Switch {
            let cell: SwitchTableViewCell = tableView.dequeue(for: indexPath)
            cell.toggle.isOn = switchRow.value
            cell.onToggleChange = { toggle in
                switchRow.value = toggle.isOn
            }
            cell.backgroundColor = .backgroundLightest
            cell.textLabel?.text = switchRow.title
            let isAvailable = !offlineModeInteractor.isOfflineModeEnabled() || switchRow.isSupportedOffline
            cell.contentView.alpha = isAvailable ? 1 : 0.5
            return cell
        }

        return UITableViewCell()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]

        if let row = row as? Row {
            guard !offlineModeInteractor.isOfflineModeEnabled() || row.isSupportedOffline else {
                return UIAlertController.showItemNotAvailableInOfflineAlert {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            }
            row.onSelect()
        } else if let switchCell = tableView.cellForRow(at: indexPath) as? SwitchTableViewCell, let switchRow = row as? Switch {
            guard !offlineModeInteractor.isOfflineModeEnabled() || switchRow.isSupportedOffline else { return UIAlertController.showItemNotAvailableInOfflineAlert() }
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
    let isSupportedOffline: Bool
    let accessibilityTraits: UIAccessibilityTraits?
    let onSelect: () -> Void

    init(
        _ title: String,
        detail: String? = nil,
        style: UITableViewCell.CellStyle = .value1,
        hasDisclosure: Bool = true,
        isSupportedOffline: Bool,
        accessibilityTraits: UIAccessibilityTraits? = nil,
        onSelect: @escaping () -> Void
    ) {
        self.title = title
        self.detail = detail
        self.style = style
        self.isSupportedOffline = isSupportedOffline
        self.hasDisclosure = hasDisclosure
        self.accessibilityTraits = accessibilityTraits
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
    let isSupportedOffline: Bool
    private let onSelect: (_ value: Bool) -> Void

    init(_ title: String, initialValue: Bool = false, isSupportedOffline: Bool, onSelect: @escaping (_ value: Bool) -> Void) {
        self.title = title
        self.value = initialValue
        self.isSupportedOffline = isSupportedOffline
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
                return String(localized: "Courses", bundle: .core)
            }
            return String(localized: "Dashboard", bundle: .core)
        case .calendar:
            return String(localized: "Calendar", bundle: .core)
        case .todo:
            return String(localized: "To Do", bundle: .core)
        case .notifications:
            return String(localized: "Notifications", bundle: .core)
        case .inbox:
            return String(localized: "Inbox", bundle: .core)
        }
    }

    static var appCases: [LandingPage] = {
        return Bundle.main.isTeacherApp
            ? [ .dashboard, .todo, .inbox ]
            : [ .dashboard, .calendar, .todo, .notifications, .inbox ]
    }()
}
