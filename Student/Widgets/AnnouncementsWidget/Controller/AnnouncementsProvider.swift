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
    }

    private func setupLastLoginCredentials() {
        guard let mostRecentKeyChain = LoginSession.mostRecent else { return }
        env.userDidLogin(session: mostRecentKeyChain)
    }

    func update(completion: @escaping (AnnouncementsEntry) -> Void) {
        setupLastLoginCredentials()

        colors.refresh { [weak self] _ in
            self?.courses.refresh { _ in
                self?.announcements.refresh(force: true) { _ in
                    guard let self = self else { return }
                    let announcementItems: [AnnouncementItem] = self.announcements.compactMap { announcement in
                        guard let course = (self.courses.first { $0.id == announcement.courseID }) else { return nil }
                        return AnnouncementItem(discussionTopic: announcement, course: course)
                    }
                    let announcementsEntry = AnnouncementsEntry(announcementItems:announcementItems)
                    completion(announcementsEntry)
                }
            }
        }
    }
}

extension AnnouncementsProvider: TimelineProvider {
    typealias Entry = AnnouncementsEntry

    func placeholder(in context: TimelineProvider.Context) -> Entry {
        AnnouncementsEntry.makePreview()
    }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (Entry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping (Timeline<Entry>) -> Void) {
        update { announcementsEntry in
            let timeline = Timeline(entries: [announcementsEntry], policy: .after(Date().addMinutes(5)))
            completion(timeline)
        }
    }
}
