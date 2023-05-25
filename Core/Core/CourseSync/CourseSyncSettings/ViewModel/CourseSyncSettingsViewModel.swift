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
    @Published public var syncFrequencyLabel = ""
    public let confirmAlert = ConfirmationAlertViewModel(
        title: NSLocalizedString("Turn Off Wi-Fi Only Sync?", comment: ""),
        message: NSLocalizedString(
           """
           Content sync might use cellular data which may result in extra fees from your data provider.
           """, comment: ""),
        cancelButtonTitle: NSLocalizedString("Cancel", comment: ""),
        confirmButtonTitle: NSLocalizedString("Turn Off", comment: ""),
        isDestructive: false)
    public let labels = (
        autoContentSync: NSLocalizedString(
            """
            Enabling the Auto Content Sync will take care of downloading the selected content based on the below \
            settings. The content synchronization will happen even if the application is not running. If the setting is \
            switched off then no synchronization will happen. The already downloaded content will not be deleted.
            """, comment: ""),
        syncFrequency: NSLocalizedString("Specify the recurrence of the content synchronization. The system will download the selected content based on the frequency specified here.", comment: ""),
        wifiOnlySync: NSLocalizedString(
            """
            If this setting is enabled the content synchronization will only happen if the device connects \
            to a Wi-Fi network, otherwise it will be postponed until a Wi-Fi network is available.
            """, comment: "")
    )

    // MARK: - Input
    public let syncFrequencyDidTap = PassthroughRelay<WeakViewController>()

    // MARK: - Private
    private let interactor: CourseSyncSettingsInteractor
    private var subscriptions = Set<AnyCancellable>()

    public init(interactor: CourseSyncSettingsInteractor) {
        self.interactor = interactor
        handleSyncFrequencyTap()
        handleAllSettingsVisibilityChange()
        updateSyncFrequencyLabel()
        readInitialSwitchStatesFromInteractor()
        forwardSwitchStateChangesToInteractor()
        showConfirmationDialogWhenWifiSyncTurnedOff()
    }

    private func readInitialSwitchStatesFromInteractor() {
        isAutoContentSyncEnabled.accept(interactor.isAutoSyncEnabled.value)
        isWifiOnlySyncEnabled.accept(interactor.isWifiOnlySyncEnabled.value)
    }

    private func forwardSwitchStateChangesToInteractor() {
        isAutoContentSyncEnabled
            .subscribe(interactor.isAutoSyncEnabled)
            .store(in: &subscriptions)

        isWifiOnlySyncEnabled
            .subscribe(interactor.isWifiOnlySyncEnabled)
            .store(in: &subscriptions)
    }

    private func updateSyncFrequencyLabel() {
        interactor
            .syncFrequency
            .map { $0.stringValue }
            .assign(to: &$syncFrequencyLabel)
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
        let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
        var declined = true

        confirmAlert
            .userConfirmation()
            .sink { [unowned self] completion in
                guard case .finished = completion, declined else {
                    return
                }

                isWifiOnlySyncEnabled.accept(true)
                hapticGenerator.impactOccurred()
            } receiveValue: {
                declined = false
            }
            .store(in: &subscriptions)

    }

    private func handleSyncFrequencyTap() {
        syncFrequencyDidTap
            .map { [interactor] sourceController in
                let selection = IndexPath(row: interactor.syncFrequency.value.rawValue, section: 0)
                let picker = ItemPickerViewController
                    .create(title: NSLocalizedString("Sync Frequency", comment: ""),
                            sections: CourseSyncFrequency.itemPickerData,
                            selected: selection) { newValue in
                    defer {
                        sourceController.value.navigationController?.popViewController(animated: true)
                    }
                    guard let newFrequency = CourseSyncFrequency(rawValue: newValue.row) else {
                        return
                    }
                    interactor.syncFrequency.accept(newFrequency)
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
