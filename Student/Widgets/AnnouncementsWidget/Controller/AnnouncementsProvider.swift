//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Core
import WidgetKit

class AnnouncementsProvider {
    let env = AppEnvironment.shared
    var courseContextCodes: [String] = []

    lazy var colors = env.subscribe(GetCustomColors())
    lazy var courses = env.subscribe(GetAllCourses()) { [weak self] in
        self?.updateCourses()
    }
    lazy var announcements = env.subscribe(GetAnnouncements(contextCodes: courseContextCodes))

    private func updateCourses() {
        self.courseContextCodes = self.courses.map {
            Core.Context(.course, id: $0.id).canvasContextID
        }
        announcements.refresh()
    }

    func update(completion: @escaping (AnnouncementsEntry) -> Void) {
        guard let mostRecentKeyChain = LoginSession.mostRecent else { return }
        env.userDidLogin(session: mostRecentKeyChain)

        colors.refresh()
        courses.exhaust()
        announcements.refresh(force: true) { _ in
            if self.announcements.all.count > 0 {
                let announcementsEntry = AnnouncementsEntry(announcements:self.announcements.all)
                completion(announcementsEntry)
            }
        }
    }
}

extension AnnouncementsProvider: TimelineProvider {
    typealias Entry = AnnouncementsEntry

    func placeholder(in context: TimelineProvider.Context) -> Entry {
        AnnouncementsEntry(announcementItems: [])
    }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (Entry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let timeoutSeconds = announcements.useCase.ttl

        update { announcements in
            let timeline = Timeline(entries: [announcements], policy: .after(Date().addingTimeInterval(timeoutSeconds)))
            completion(timeline)
        }
    }
}
