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
import UIKit

public class CourseSyncNotificationInteractor {
    private let localNotifications: LocalNotificationsInteractor
    private let progressInteractor: CourseSyncProgressObserverInteractor

    init(localNotifications: LocalNotificationsInteractor = LocalNotificationsInteractor(),
         progressInteractor: CourseSyncProgressObserverInteractor) {
        self.localNotifications = localNotifications
        self.progressInteractor = progressInteractor
    }

    func send(window: UIWindow? = AppEnvironment.shared.window) -> AnyPublisher<Void, Never> {
        let itemCountPublisher = progressInteractor
            .observeStateProgress()
            .first()
            .map { $0.filterToCourses().count }
        let isSuccessfulSyncPublisher = progressInteractor
            .observeDownloadProgress()
            .first()
            .map { $0.error == nil }

        return Publishers
            .CombineLatest(itemCountPublisher, isSuccessfulSyncPublisher)
            .receive(on: RunLoop.main)
            .filter { _ in window.isSyncProgressNotOnScreen() }
            .filter { itemCount, _ in itemCount > 0 } // We want to avoid sending notifications about courses that have already ended.
            .flatMap { [localNotifications] (itemCount, isSuccessful) in
                if isSuccessful {
                    return localNotifications.sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: itemCount)
                } else {
                    return localNotifications.sendOfflineSyncFailedNotification()
                }
            }
            .ignoreFailure()
            .eraseToAnyPublisher()
    }

    func sendFailedNotification() {
        localNotifications.sendOfflineSyncFailedNotificationAndWait()
    }
}

private extension Optional where Wrapped == UIWindow {

    func isSyncProgressNotOnScreen() -> Bool {
        !(self?.rootViewController?.topMostViewController() is CoreHostingController<CourseSyncProgressView>)
    }
}
