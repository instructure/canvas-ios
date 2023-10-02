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

public class CourseSyncSuccessNotificationInteractor {
    private let notificationManager: NotificationManager
    private let progressInteractor: CourseSyncProgressObserverInteractor

    init(notificationManager: NotificationManager,
         progressInteractor: CourseSyncProgressObserverInteractor) {
        self.notificationManager = notificationManager
        self.progressInteractor = progressInteractor
    }

    func send(window: UIWindow? = AppEnvironment.shared.window) -> AnyPublisher<Void, Never> {
        progressInteractor
            .observeStateProgress()
            .first()
            .receive(on: RunLoop.main)
            .filter { _ in window.isSyncProgressNotOnScreen() }
            .map { $0.count }
            .handleEvents(receiveOutput: { [notificationManager] in
                notificationManager.sendOfflineSyncCompletedSuccessfullyNotification(syncedItemsCount: $0)
            })
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

private extension Optional where Wrapped == UIWindow {

    func isSyncProgressNotOnScreen() -> Bool {
        !(self?.rootViewController?.topMostViewController() is CoreHostingController<CourseSyncProgressView>)
    }
}
