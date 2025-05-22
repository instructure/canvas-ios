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
import UIKit

class CourseSyncSettingsViewModel: ObservableObject {

    // MARK: - Output
    public let isAutoContentSyncEnabled = CurrentValueRelay(false)
    public let isWifiOnlySyncEnabled = CurrentValueRelay(true)
    @Published public var isAllSettingsVisible = false
    @Published public var isShowingConfirmationDialog = false
    @Published public var syncFrequencyLabel = ""
    public let confirmAlert = ConfirmationAlertViewModel(
        title: String(localized: "Turn Off Wi-Fi Only Sync?", bundle: .core),
        message: String(localized:
           """
           Content sync might use cellular data which may result in extra fees from your data provider.
           """, bundle: .core),
        cancelButtonTitle: String(localized: "Cancel", bundle: .core),
        confirmButtonTitle: String(localized: "Turn Off", bundle: .core),
        isDestructive: false)
    public let labels = (
        autoContentSync: String(localized:
            """
            Enabling the Auto Content Sync will take care of downloading the selected content based on the below \
            settings. The content synchronization will happen even if the application is not running. If the setting is \
            switched off then no synchronization will happen. The already downloaded content will not be deleted.
            """, bundle: .core),
        syncFrequency: String(localized:
            """
            Specify the recurrence of the content synchronization. The system will download the selected content based on the frequency specified here.
            """, bundle: .core),
        wifiOnlySync: String(localized:
            """
            If this setting is enabled the content synchronization will only happen if the device connects \
            to a Wi-Fi network, otherwise it will be postponed until a Wi-Fi network is available.
            """, bundle: .core)
    )

    // MARK: - Input
    public let syncFrequencyDidTap = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Private
    private let interactor: CourseSyncSettingsInteractor
    private var subscriptions = Set<AnyCancellable>()

    public init(interactor: CourseSyncSettingsInteractor) {
        self.interactor = interactor
        handleSyncFrequencyTap()
        handleAllSettingsVisibilityChange()
        readInitialStateFromInteractor()
        forwardSwitchStateChangesToInteractor()
        showConfirmationDialogWhenWifiSyncTurnedOff()
        setupAnalytics()
    }

    private func setupAnalytics() {
        isAutoContentSyncEnabled
            .dropFirst() // We only want to report the change but not the initial value
            .logReceiveOutput(
                { $0 ? "offline_auto_sync_turned_on" : "offline_auto_sync_turned_off" },
                storeIn: &subscriptions
            )
    }

    private func readInitialStateFromInteractor() {
        interactor
            .getStoredPreferences()
            .sink { [unowned self] settings in
                isAutoContentSyncEnabled.accept(settings.isAutoSyncEnabled)
                isWifiOnlySyncEnabled.accept(settings.isWifiOnlySyncEnabled)
                syncFrequencyLabel = settings.syncFrequency.stringValue
            }
            .store(in: &subscriptions)
    }

    private func forwardSwitchStateChangesToInteractor() {
        isAutoContentSyncEnabled
            .flatMap { [interactor] isEnabled in
                interactor.setAutoSyncEnabled(isEnabled)
            }
            .sink()
            .store(in: &subscriptions)

        isWifiOnlySyncEnabled
            .flatMap { [interactor] isEnabled in
                interactor.setWifiOnlySyncEnabled(isEnabled)
            }
            .sink()
            .store(in: &subscriptions)
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
        let interactor = self.interactor

        syncFrequencyDidTap
            .flatMap { sourceController in
                interactor
                    .getStoredPreferences()
                    .map {(
                        previousSelection: $0.syncFrequency.rawValue,
                        sourceController: sourceController
                    )}
            }
            .flatMap { (previousSelection, sourceController) in
                Self.getNewFrequencyFromUser(previousSelection: previousSelection,
                                             sourceController: sourceController.value)
            }
            .flatMap { newFrequency in
                interactor.setSyncFrequency(newFrequency)
            }
            .map { $0.stringValue }
            .assign(to: &$syncFrequencyLabel)
    }

    private func handleAllSettingsVisibilityChange() {
        isAutoContentSyncEnabled
            .assign(to: &$isAllSettingsVisible)
    }

    private static func getNewFrequencyFromUser(previousSelection: Int,
                                                sourceController: UIViewController)
    -> AnyPublisher<CourseSyncFrequency, Never> {
        Future<CourseSyncFrequency, Never> { promise in
            let handleNewSelection: (Int) -> Void = { newSelection in
                defer {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        if sourceController.navigationController?.topViewController is CoreHostingController<ItemPickerScreen> {
                            sourceController.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                guard let newFrequency = CourseSyncFrequency(rawValue: newSelection) else {
                    return
                }

                promise(.success(newFrequency))
            }

            let pageTitle = String(localized: "Sync Frequency", bundle: .core)
            let picker = ItemPickerScreen(
                pageTitle: pageTitle,
                identifierGroup: "Settings.OfflineSync.syncFrequencyOptions",
                items: CourseSyncFrequency.itemPickerData,
                initialSelectionIndex: previousSelection,
                didSelect: handleNewSelection
            )
            let pickerVC = CoreHostingController(picker)
            pickerVC.navigationItem.title = pageTitle
            sourceController.show(pickerVC, sender: self)
        }
        .eraseToAnyPublisher()
    }
}
