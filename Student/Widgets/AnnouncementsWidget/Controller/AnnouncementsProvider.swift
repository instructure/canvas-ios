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

class AnnouncementsProvider: CommonWidgetController {
    private lazy var courses = env.subscribe(GetAllCourses())
    private var announcements: Store<GetAnnouncements>?

    private func getImage(url: URL?) -> UIImage? {
        guard let url = url, let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }

    private func update(completion: @escaping (AnnouncementsEntry) -> Void) {
        guard isLoggedIn else {
            completion(AnnouncementsEntry(isLoggedIn: false))
            return
        }

        setupLastLoginCredentials()

        colors.refresh { [weak self] _ in
            guard let self = self, !self.colors.pending else { return }
            self.fetchCourses(completion: completion)
        }
    }

    private func fetchCourses(completion: @escaping (AnnouncementsEntry) -> Void) {
        courses.refresh { [weak self] _ in
            guard let self = self, !self.courses.pending else { return }
            let courseContextCodes = self.courses.map { Core.Context(.course, id: $0.id).canvasContextID }
            self.fetchAnnouncements(courseContextCodes: courseContextCodes, completion: completion)
        }
    }

    private func fetchAnnouncements(courseContextCodes: [String], completion: @escaping (AnnouncementsEntry) -> Void) {
        announcements = env.subscribe(GetAnnouncements(contextCodes: courseContextCodes))
        announcements?.refresh(force: true) { [weak self] _ in
            guard let self = self, let announcements = self.announcements, !announcements.pending else { return }

            let announcementItems: [AnnouncementItem] = announcements.compactMap { announcement in
                guard let course = (self.courses.first { $0.id == announcement.courseID }) else { return nil }
                let image = self.getImage(url: announcement.author?.avatarURL)
                return AnnouncementItem(discussionTopic: announcement, course: course, avatarImage: image)
            }

            let announcementsEntry = AnnouncementsEntry(announcementItems: announcementItems)
            completion(announcementsEntry)
            self.announcements = nil
        }
    }
}

extension AnnouncementsProvider: TimelineProvider {
    typealias Entry = AnnouncementsEntry

    func placeholder(in context: TimelineProvider.Context) -> Entry {
        AnnouncementsEntry.publicPreview
    }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (Entry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping (Timeline<Entry>) -> Void) {
        if context.isPreview {
            let timeline = Timeline(entries: [placeholder(in: context)], policy: .after(Date()))
            completion(timeline)
            return
        }

        update { announcementsEntry in
            let timeline = Timeline(entries: [announcementsEntry], policy: .after(Date().addMinutes(5)))
            completion(timeline)
        }
    }
}
