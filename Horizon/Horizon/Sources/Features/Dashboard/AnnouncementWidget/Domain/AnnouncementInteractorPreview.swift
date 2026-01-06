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

#if DEBUG
import Combine
import Foundation

class AnnouncementInteractorPreview: AnnouncementInteractor {
    private var announcements: [AnnouncementModel] = [
        .init(
            id: "1",
            title: "Subject 1",
            content: "New Content info",
            date: Date(),
            isRead: true,
            isGlobal: false
        ),
        .init(
            id: "2",
            title: "Subject 3",
            content: "New Content info 3",
            date: nil,
            isRead: false,
            isGlobal: true
        )
    ]
    func getAllAnnouncements(ignoreCache: Bool) -> AnyPublisher<[AnnouncementModel], Never> {
        return Just(announcements)
            .eraseToAnyPublisher()
    }

    func markAnnouncementAsRead(announcement: AnnouncementModel) -> AnyPublisher<[AnnouncementModel], Never> {
        return Just(announcements)
            .eraseToAnyPublisher()
    }
}
#endif
