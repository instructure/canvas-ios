//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Core
import CoreData
import Foundation

protocol GlobalAnnouncementsWidgetInteractor {
    func getAnnouncements(ignoreCache: Bool) -> AnyPublisher<[GlobalAnnouncementsWidgetItem], Error>
    func deleteAnnouncement(id: String) -> AnyPublisher<Void, Never>
}

extension GlobalAnnouncementsWidgetInteractor where Self == GlobalAnnouncementsWidgetInteractorLive {
    static func live(env: AppEnvironment) -> GlobalAnnouncementsWidgetInteractorLive {
        .init(env: env)
    }
}

final class GlobalAnnouncementsWidgetInteractorLive: GlobalAnnouncementsWidgetInteractor {
    private let moContext: NSManagedObjectContext
    private let env: AppEnvironment
    private let announcementsStore: ReactiveStore<GetAccountNotifications>

    init(env: AppEnvironment) {
        self.moContext = env.database.viewContext
        self.env = env

        self.announcementsStore = ReactiveStore(
            context: moContext,
            useCase: GetAccountNotifications(),
            environment: env
        )
    }

    func getAnnouncements(ignoreCache: Bool) -> AnyPublisher<[GlobalAnnouncementsWidgetItem], Error> {
        announcementsStore
            .getEntities(ignoreCache: ignoreCache, keepObservingDatabaseChanges: true)
            .map { (announcements: [AccountNotification]) -> [GlobalAnnouncementsWidgetItem] in
                announcements
                    .filter {
                        // Return only Announcements which had not been dismissed before.
                        // Past Announcements (regardless of `closed` state) are not even received.
                        !$0.closed
                    }
                    .map { announcement in
                        GlobalAnnouncementsWidgetItem(
                            id: announcement.id,
                            title: announcement.subject,
                            icon: announcement.icon,
                            startDate: announcement.startAt,
                            message: announcement.message
                        )
                    }
            }
            .eraseToAnyPublisher()
    }

    func deleteAnnouncement(id: String) -> AnyPublisher<Void, Never> {
        ReactiveStore(
            context: moContext,
            useCase: DeleteAccountNotification(id: id),
            environment: env
        )
        .getEntities(ignoreCache: true)
        .mapToVoid()
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }
}
