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

class AnnouncementsProvider: CommonWidgetProvider<AnnouncementsEntry> {
    private var colors: Store<GetCustomColors>?
    private var courses: Store<GetAllCourses>?
    private var announcements: Store<GetAllAnnouncements>?

    init() {
        super.init(loggedOutModel: AnnouncementsEntry(isLoggedIn: false), timeout: 15 * 60)
    }

    override func fetchData() {
        colors = env.subscribe(GetCustomColors())
        colors?.refresh { [weak self] _ in
            guard let self = self, let colors = self.colors, !colors.pending else { return }
            self.fetchCourses()
        }
    }

    private func fetchCourses() {
        courses = env.subscribe(GetAllCourses())
        courses?.refresh { [weak self] _ in
            guard let self = self, let courses = self.courses, !courses.pending else { return }
            let courseContextCodes = courses.map { Core.Context(.course, id: $0.id).canvasContextID }
            self.fetchAnnouncements(courseContextCodes: courseContextCodes)
        }
    }

    private func fetchAnnouncements(courseContextCodes: [String]) {
        announcements = env.subscribe(GetAllAnnouncements(contextCodes: courseContextCodes))
        // We always force refresh since the widget's timeout is lower than the cache's TTL
        announcements?.refresh(force: true) { [weak self] _ in
            guard let self = self, let announcements = self.announcements, !announcements.pending else { return }

            let announcementItems: [AnnouncementItem] = announcements.compactMap { announcement in
                guard let course = (self.courses?.first { $0.id == announcement.courseID }) else { return nil }
                let image = self.getImage(url: announcement.author?.avatarURL)
                return AnnouncementItem(discussionTopic: announcement, course: course, avatarImage: image)
            }

            let announcementsEntry = AnnouncementsEntry(announcementItems: announcementItems)
            self.updateWidget(model: announcementsEntry)
            self.announcements = nil
        }
    }

    private func getImage(url: URL?) -> UIImage? {
        guard let url = url, let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}
