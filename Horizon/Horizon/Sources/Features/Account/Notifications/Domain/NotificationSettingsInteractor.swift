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
import Core

protocol NotificationSettingsInteractor {
    func getNotificationPreferences() -> AnyPublisher<[NotificationPreference], Error>
    func isOSNotificationEnabled() -> AnyPublisher<Bool, Never>
    func updateNotificationPreferences(
        type: NotificationChannel.ChannelType,
        visibleCategory: NotificationPreference.VisibleCategories,
        currentPreferences: [NotificationPreference],
        isOn: Bool
    ) -> AnyPublisher<Void, Error>
}

final class NotificationSettingsInteractorLive: NotificationSettingsInteractor {
    private var currentPreferences: [NotificationPreference] = []

    public init() {}

    private func getNotificationChannels() -> AnyPublisher<[NotificationChannel], Error> {
        ReactiveStore(
            useCase: GetCommunicationChannels()
        )
        .getEntities(ignoreCache: true)
        .flatMap(\.publisher)
        .map { NotificationChannel(from: $0) }
        .collect()
        .eraseToAnyPublisher()
    }

    func getNotificationPreferences() -> AnyPublisher<[NotificationPreference], Error> {
        getNotificationChannels()
            .flatMap(\.publisher)
            .flatMap { channel in
                ReactiveStore(
                    useCase: GetNotificationCategories(channelID: channel.id)
                )
                .getEntities(ignoreCache: true)
                .flatMap(\.publisher)
                .compactMap { NotificationPreference(from: $0, type: channel.type) }
            }
            .collect()
            .eraseToAnyPublisher()
    }

    func isOSNotificationEnabled() -> AnyPublisher<Bool, Never> {
        return AnyPublisher<Bool, Never>.create { subscriber in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                subscriber.send(settings.authorizationStatus == .authorized)
                subscriber.send(completion: .finished)
            }
            return AnyCancellable {}
        }
    }

    func updateNotificationPreferences(
        type: NotificationChannel.ChannelType,
        visibleCategory: NotificationPreference.VisibleCategories,
        currentPreferences: [NotificationPreference],
        isOn: Bool
    ) -> AnyPublisher<Void, Error> {
        let frequency: NotificationFrequency = isOn ? .immediately : .never

        let categoriesToUpdate = currentPreferences
            .filter { cp in
                cp.category == visibleCategory && cp.type == type
            }

        return categoriesToUpdate
            .publisher
            .flatMap { category in
                ReactiveStore(
                    useCase: PutNotificationCategory(
                        channelID: category.channelID,
                        category: category.associatedCategory.rawValue,
                        notifications: category.notificationIDs,
                        frequency: frequency
                    )
                )
                .getEntities()
            }
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
