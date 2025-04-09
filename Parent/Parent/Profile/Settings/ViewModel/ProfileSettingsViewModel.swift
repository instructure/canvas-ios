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
import Combine
import UIKit

public class ProfileSettingsViewModel: ObservableObject {
    @Published public var settingsGroups: [SettingsGroupView] = []

    private let inboxSettingsInteractor: InboxSettingsInteractor
    private let offlineInteractor: OfflineModeInteractor
    private let environment: AppEnvironment

    private var subscriptions = Set<AnyCancellable>()

    public init(inboxSettingsInteractor: InboxSettingsInteractor, offlineInteractor: OfflineModeInteractor, environment: AppEnvironment) {
        self.inboxSettingsInteractor = inboxSettingsInteractor
        self.offlineInteractor = offlineInteractor
        self.environment = environment

        self.initGroups()
    }

    private func initGroups() {
        initPreferencesGroup()
        initInboxGroup()
        initLegalGroup()

        offlineInteractor
            .observeIsOfflineMode()
            .sink { [weak self] isOffline in
                if let items = self?.settingsGroups.flatMap({ $0.viewModel.itemViews.compactMap { $0.viewModel } }) {
                    items.forEach { item in
                        item.disabled = !item.availableOffline && isOffline
                    }
                }
            }
            .store(in: &subscriptions)
    }
}

// MARK: Preferences Group
extension ProfileSettingsViewModel {
    private func initPreferencesGroup() {
        let appearanceView = initAppearanceGroupItem()
        let aboutView = initAboutItem()
        let groupViewModel = SettingsGroupViewModel(
            title: String(localized: "Preferences", bundle: .core),
            itemViews: [appearanceView, aboutView]
        )

        let groupView =  SettingsGroupView(
            viewModel: groupViewModel
        )

        self.settingsGroups.append(groupView)
    }

    private func initAppearanceGroupItem() -> SettingsGroupItemView {
        let options = [
            ItemPickerItem(title: String(localized: "System Settings", bundle: .core)),
            ItemPickerItem(title: String(localized: "Light Theme", bundle: .core)),
            ItemPickerItem(title: String(localized: "Dark Theme", bundle: .core))
        ]
        let selectedStyleIndex = CurrentValueSubject<Int, Never>(environment.userDefaults?.interfaceStyle?.rawValue ?? 0)

        let itemViewModel = SettingsGroupItemViewModel(
            title: String(localized: "Appearance", bundle: .core),
            valueLabel: nil
        ) { [weak self] controller in
            guard let self = self else { return }
            self.showAppereanceItemPicker(controller: controller, selectedIndex: selectedStyleIndex, options: options)
        }

        selectedStyleIndex
            .sink { index in
                itemViewModel.valueLabel = options[safeIndex: index]?.title
            }
            .store(in: &subscriptions)

        return SettingsGroupItemView(viewModel: itemViewModel)
    }

    private func initAboutItem() -> SettingsGroupItemView {
        let itemViewModel = SettingsGroupItemViewModel(
            title: String(localized: "About", bundle: .core),
            valueLabel: nil
        ) { [weak self] controller in
            guard let self = self else { return }
            self.environment.router.route(to: "/about", from: controller)
        }

        return SettingsGroupItemView(viewModel: itemViewModel)
    }

    private func showAppereanceItemPicker(controller: WeakViewController, selectedIndex: CurrentValueSubject<Int, Never>, options: [ItemPickerItem]) {
        let selectedStyleIndex = environment.userDefaults?.interfaceStyle?.rawValue ?? 0
        let pickerVC = ItemPickerViewController.create(
            title: String(localized: "Appearance", bundle: .core),
            sections: [ ItemPickerSection(items: options) ],
            selected: IndexPath(row: selectedStyleIndex, section: 0)
        ) { [weak self] indexPath in
            if let window = self?.environment.window, let style = UIUserInterfaceStyle(rawValue: indexPath.row) {
                window.updateInterfaceStyle(style)
                self?.environment.userDefaults?.interfaceStyle = style
            }

            selectedIndex.send(indexPath.row)
        }
        controller.value.show(pickerVC, sender: controller)
    }
}

// MARK: Inbox Group
extension ProfileSettingsViewModel {
    private func initInboxGroup() {
        let inboxSignatureSettingView = initInboxSignatureGroupItem()
        let groupViewModel = SettingsGroupViewModel(
            title: String(localized: "Inbox", bundle: .core),
            itemViews: [inboxSignatureSettingView]
        )

        let inboxGroupView = SettingsGroupView(viewModel: groupViewModel)

        inboxSettingsInteractor
            .isFeatureEnabled
            .sink { isEnabled in
                inboxSignatureSettingView.viewModel.isHidden = !isEnabled
                groupViewModel.itemViews = groupViewModel.itemViews
            }
            .store(in: &subscriptions)

        self.settingsGroups.append(inboxGroupView)
    }

    private func initInboxSignatureGroupItem() -> SettingsGroupItemView {
        let itemViewModel = SettingsGroupItemViewModel(
            title: String(localized: "Inbox Signature", bundle: .core),
            valueLabel: nil,
            availableOffline: false,
            isHidden: true
        ) { [weak self] controller in
            guard let self = self else { return }
            self.environment.router.route(to: "/conversations/settings", from: controller)
        }

        inboxSettingsInteractor
            .signature
            .sink { (useSignature, _) in
                let newValue = useSignature
                ? String(localized: "Enabled", bundle: .core)
                : String(localized: "Not set", bundle: .core)

                itemViewModel.valueLabel = newValue
            }
            .store(in: &subscriptions)

        return SettingsGroupItemView(viewModel: itemViewModel)
    }
}

// MARK: Legal Group
extension ProfileSettingsViewModel {
    private func initLegalGroup() {
        let privacyPolicySettingView = initPrivacyPolicyItem()
        let termsOfUseSettingView = initTermsOfUseItem()
        let groupViewModel = SettingsGroupViewModel(
            title: String(localized: "Legal", bundle: .core),
            itemViews: [privacyPolicySettingView, termsOfUseSettingView]
        )

        let inboxGroupView = SettingsGroupView(viewModel: groupViewModel)
        self.settingsGroups.append(inboxGroupView)
    }

    private func initPrivacyPolicyItem() -> SettingsGroupItemView {
        let itemViewModel = SettingsGroupItemViewModel(
            title: String(localized: "Privacy Policy", bundle: .core),
            valueLabel: nil,
            isLink: true
        ) { [weak self] controller in
            guard let self = self else { return }
            self.environment.router.route(to: "https://www.instructure.com/canvas/privacy/", from: controller)
        }

        return SettingsGroupItemView(viewModel: itemViewModel)
    }

    private func initTermsOfUseItem() -> SettingsGroupItemView {
        let itemViewModel = SettingsGroupItemViewModel(
            title: String(localized: "Terms of Use", bundle: .core),
            valueLabel: nil
        ) { [weak self] controller in
            guard let self = self else { return }
            self.environment.router.route(to: "/accounts/self/terms_of_service", from: controller)
        }

        return SettingsGroupItemView(viewModel: itemViewModel)
    }
}
