//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core

public class ProfileSettingsViewModel: ObservableObject {
    @Published public var settingsGroups: [SettingsGroup] = []

    private let inboxSettingsInteractor: InboxSettingsInteractor
    private let environment: AppEnvironment

    public init(inboxSettingsInteractor: InboxSettingsInteractor, environment: AppEnvironment) {
        self.inboxSettingsInteractor = inboxSettingsInteractor
        self.environment = environment

        initGroups()
    }

    private func initGroups() {
        var groups = [SettingsGroup]()

        groups.append(preferencesGroup())
        groups.append(inboxGroup())

        settingsGroups = groups
    }

    private func preferencesGroup() -> SettingsGroup {
        let options = [
            ItemPickerItem(title: String(localized: "System Settings", bundle: .core)),
            ItemPickerItem(title: String(localized: "Light Theme", bundle: .core)),
            ItemPickerItem(title: String(localized: "Dark Theme", bundle: .core))
        ]
        let selectedStyleIndex = environment.userDefaults?.interfaceStyle?.rawValue ?? 0

        return SettingsGroup(
            groupTitle: String(localized: "Preferences", bundle: .core),
            items: [
                SettingsGroupItem(
                    id: .appearance,
                    title: String(localized: "Appearance", bundle: .core),
                    valueLabel: options[selectedStyleIndex].title,
                    isSupportedOffline: true
                ) { [weak self] controller in
                    guard let self = self else { return }

                    let selectedStyleIndex = environment.userDefaults?.interfaceStyle?.rawValue ?? 0
                    let pickerVC = ItemPickerViewController.create(title: String(localized: "Appearance", bundle: .core),
                                                                   sections: [ ItemPickerSection(items: options) ],
                                                                   selected: IndexPath(row: selectedStyleIndex, section: 0)) { indexPath in
                        if let window = self.environment.window, let style = UIUserInterfaceStyle(rawValue: indexPath.row) {
                            window.updateInterfaceStyle(style)
                            self.environment.userDefaults?.interfaceStyle = style
                        }

                        let item = self.settingsGroups.flatMap { $0.items }.first { $0.id == .appearance }
                        self.settingsGroups.replace(item)
                        self.sett
                    }
                    controller.value.show(pickerVC, sender: controller)
                },
                SettingsGroupItem(
                    id: .about,
                    title: String(localized: "About", bundle: .core),
                    valueLabel: nil,
                    isSupportedOffline: true
                ) { [weak self] controller in
                    guard let self else { return }
                    self.environment.router.route(to: "/about", from: controller)
                }
            ]
        )
    }

    private func inboxGroup() -> SettingsGroup {
        return SettingsGroup(
            groupTitle: String(localized: "Inbox", bundle: .core),
            items: [
                SettingsGroupItem(
                    id: .inboxSignature,
                    title: String(localized: "Inbox Signature", bundle: .core),
                    valueLabel: "Not set",
                    isSupportedOffline: true
                ) { [weak self] controller in
                    guard let self = self else { return }
                    self.environment.router.route(to: "/conversations/settings", from: controller)
                }
            ]
        )
    }

    private func legalGroup() {

    }
}
