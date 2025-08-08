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

import Combine
import CombineExt
import CombineSchedulers
import Core
import Foundation
import Observation
import UIKit

@Observable
final class NotificationSettingsViewModel {
    // MARK: - Outputs

    /// iOS level notifications are enabled or not.
    var isOSNotificationEnabled: Bool = true

    /// Push notifications are configured on the backend or not.
    var isPushConfigured = false

    // MARK: - Inputs/Outputs

    var isMessagesEmailEnabled = false {
        didSet {
            updateNotificationPreference(
                type: .email,
                category: .announcementsAndMesages,
                isOn: isMessagesEmailEnabled
            )
        }
    }

    var isMessagesPushEnabled = false {
        didSet {
            updateNotificationPreference(
                type: .push,
                category: .announcementsAndMesages,
                isOn: isMessagesPushEnabled
            )
        }
    }

    var isDueDatesEmailEnabled = false {
        didSet {
            updateNotificationPreference(
                type: .email,
                category: .assignmentDueDates,
                isOn: isDueDatesEmailEnabled
            )
        }
    }

    var isDueDatesPushEnabled = false {
        didSet {
            updateNotificationPreference(
                type: .push,
                category: .assignmentDueDates,
                isOn: isDueDatesPushEnabled
            )
        }
    }

    var isScoreEmailEnabled = false {
        didSet {
            updateNotificationPreference(
                type: .email,
                category: .scores,
                isOn: isScoreEmailEnabled
            )
        }
    }

    var isScorePushEnabled = false {
        didSet {
            updateNotificationPreference(
                type: .push,
                category: .scores,
                isOn: isScorePushEnabled
            )
        }
    }

    var viewState: ViewState = .loading

    enum ViewState {
        case loading
        case data
    }

    // MARK: - Dependencies

    private let notificationSettingsInteractor: NotificationSettingsInteractor
    private let router: Router

    // MARK: - Private properties

    private var notificationPreferences = [NotificationPreference]()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        notificationSettingsInteractor: NotificationSettingsInteractor = NotificationSettingsInteractorLive(),
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.notificationSettingsInteractor = notificationSettingsInteractor
        self.router = router

        self.notificationSettingsInteractor
            .getNotificationPreferences()
            .replaceError(with: [])
            .receive(on: scheduler)
            .sink(receiveValue: { [weak self] prefs in self?.setNotificationPreferences(preferences: prefs) })
            .store(in: &subscriptions)

        self.notificationSettingsInteractor
            .isOSNotificationEnabled()
            .assign(to: \.isOSNotificationEnabled, on: self)
            .store(in: &subscriptions)
    }

    private func setNotificationPreferences(preferences: [NotificationPreference]) {
        isMessagesEmailEnabled = preferences
            .getIsOn(
                for: .announcementsAndMesages,
                type: .email
            )

        isMessagesPushEnabled = preferences
            .getIsOn(
                for: .announcementsAndMesages,
                type: .push
            )

        isDueDatesEmailEnabled = preferences
            .getIsOn(
                for: .assignmentDueDates,
                type: .email
            )

        isDueDatesPushEnabled = preferences
            .getIsOn(
                for: .assignmentDueDates,
                type: .push
            )
        isScoreEmailEnabled = preferences
            .getIsOn(
                for: .scores,
                type: .email
            )

        isScorePushEnabled = preferences
            .getIsOn(
                for: .scores,
                type: .push
            )

        isPushConfigured = preferences.isPushNotificationConfigured()
        viewState = .data
        notificationPreferences = preferences
    }

    // MARK: - Inputs

    private func updateNotificationPreference(
        type: NotificationChannel.ChannelType,
        category: NotificationPreference.VisibleCategories,
        isOn: Bool
    ) {
        notificationSettingsInteractor.updateNotificationPreferences(
            type: type,
            visibleCategory: category,
            currentPreferences: notificationPreferences,
            isOn: isOn
        )
        .ignoreFailure()
        .sink { _ in }
        .store(in: &subscriptions)
    }

    func navigateBack(viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func goToAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
