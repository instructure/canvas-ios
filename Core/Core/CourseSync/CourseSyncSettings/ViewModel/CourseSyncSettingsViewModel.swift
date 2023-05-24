//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
import CombineExt
import Foundation

class CourseSyncSettingsViewModel: ObservableObject {

    // MARK: - Output
    public let isAutoContentSyncEnabled = CurrentValueRelay(false)
    public let isWifiOnlySyncEnabled = CurrentValueRelay(true)
    @Published public var isAllSettingsVisible = false
    @Published public var isShowingConfirmationDialog = false
    public let confirmAlert = ConfirmationAlertViewModel(
        title: NSLocalizedString("Turn Off Content Sync Over Wi-fi Only?", comment: ""),
        message: NSLocalizedString(
           """
           If this setting is enabled the content synchronization will only happen if the device \
           connects to a Wi-Fi network, otherwise it will be postponed until a Wi-Fi network is available.
           """, comment: ""),
        cancelButtonTitle: NSLocalizedString("Cancel", comment: ""),
        confirmButtonTitle: NSLocalizedString("Turn Off", comment: ""),
        isDestructive: false)

    // MARK: - Input
    public let syncFrequencyDidTap = PassthroughRelay<WeakViewController>()

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()

    public init() {
        handleSyncFrequencyTap()
        handleAllSettingsVisibilityChange()
        showConfirmationDialogWhenWifiSyncTurnedOff()
    }

    private func showConfirmationDialogWhenWifiSyncTurnedOff() {
        isWifiOnlySyncEnabled
            .dropFirst()
            .filter { !$0 }
            .map { _ in true }
            .handleEvents(receiveOutput: { [unowned self] _ in
                turnOnWifiOnlySyncWhenUserCancelsConfirmation()
            })
            .assign(to: &$isShowingConfirmationDialog)
    }

    private func turnOnWifiOnlySyncWhenUserCancelsConfirmation() {
        var declined = true

        confirmAlert
            .userConfirmation()
            .sink { [unowned self] completion in
                guard case .finished = completion, declined else {
                    return
                }

                isWifiOnlySyncEnabled.accept(true)
            } receiveValue: {
                declined = false
            }
            .store(in: &subscriptions)

    }

    private func handleSyncFrequencyTap() {
        let pickerItems = ItemPickerSection(items: [
            .init(title: NSLocalizedString("Daily", comment: "")),
            .init(title: NSLocalizedString("Weekly", comment: "")),
        ])

        syncFrequencyDidTap
            .map { sourceController in
                let picker = ItemPickerViewController.create(title: NSLocalizedString("Sync Frequency", comment: ""),
                                                             sections: [pickerItems],
                                                             selected: IndexPath(row: 0, section: 0)) { _ in
                    // Update selection
                }

                return (picker: picker, source: sourceController)
            }
            .sink {
                $0.source.value.show($0.picker, sender: self)
            }
            .store(in: &subscriptions)
    }

    private func handleAllSettingsVisibilityChange() {
        isAutoContentSyncEnabled
            .assign(to: &$isAllSettingsVisible)
    }
}
