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

class AnnouncementsProvider: TimelineProvider {
    typealias Entry = AnnouncementsEntry
    private let env = AppEnvironment.shared
    private var colors: Store<GetCustomColors>?
    private var courses: Store<GetAllCourses>?
    private var announcements: Store<GetWidgetAnnouncements>?

    // MARK: - TimelineProvider Protocol

    func placeholder(in context: TimelineProvider.Context) -> Entry { .publicPreview }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (AnnouncementsEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping @Sendable (Timeline<AnnouncementsEntry>) -> Void) {

        if context.isPreview {
            let timeline = Timeline(entries: [placeholder(in: context)], policy: .never)
            completion(timeline)
            return
        }

        guard let session = LoginSession.mostRecent else {
            let refreshDate = Clock.now.addingTimeInterval(.widgetRefresh)
            completion(Timeline(entries: [.loggedOutModel], policy: .after(refreshDate)))
            return
        }

        setupEnvironment(with: session)
        fetchColors(completion)
    }

    // MARK: - Private

    private func setupEnvironment(with session: LoginSession) {
        env.app = .student
        guard let session = LoginSession.mostRecent else {
            env.widgetUserDidLogout()
            return
        }
        if let current = env.currentSession, current == session { return }
        env.userDidLogin(session: session, isSilent: true)
    }

    func fetchColors(_ completion: @escaping @Sendable (Timeline<AnnouncementsEntry>) -> Void) {
        colors = env.subscribe(GetCustomColors())
        colors?.refresh { [weak self] _ in
            self?.fetchCourses(completion)
        }
    }

    func fetchCourses(_ completion: @escaping @Sendable (Timeline<AnnouncementsEntry>) -> Void) {
        guard let colors = self.colors, !colors.pending else { return }
        courses = env.subscribe(GetAllCourses())
        courses?.refresh { [weak self] _ in
            self?.fetchAnnouncements(completion)
        }
    }

    func fetchAnnouncements(_ completion: @escaping @Sendable (Timeline<AnnouncementsEntry>) -> Void) {
        guard let courses = self.courses, !courses.pending else { return }
        let courseContextCodes = courses.map { Core.Context(.course, id: $0.id).canvasContextID }
        announcements = env.subscribe(GetWidgetAnnouncements(courseContextCodes: courseContextCodes))
        announcements?.refresh { [weak self] _ in
            self?.handleFetchFinished(completion)
        }
    }

    func handleFetchFinished(_ completion: @escaping (Timeline<AnnouncementsEntry>) -> Void) {
        guard let announcements = self.announcements, !announcements.pending else { return }
        let announcementItems = announcements.all.map { AnnouncementItem(dbEntity: $0) }
        let announcementsEntry = AnnouncementsEntry(announcements: announcementItems, date: .now)
        let refreshDate = Clock.now.addingTimeInterval(.widgetRefresh)
        let timeline = Timeline(entries: [announcementsEntry], policy: .after(refreshDate))
        completion(timeline)
    }
}
