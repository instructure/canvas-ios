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
    let env = AppEnvironment.shared
    lazy var activities = env.subscribe(GetActivities())

    func placeholder(in context: TimelineProvider.Context) -> Entry {
        AnnouncementsEntry(announcementItems: [])
    }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (Entry) -> Void) {
        let entry = AnnouncementsEntry(announcementItems: [])
        completion(entry)
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping (Timeline<Entry>) -> Void) {
        guard let mostRecentKeyChain = LoginSession.mostRecent else {
            return
        }
        env.userDidLogin(session: mostRecentKeyChain)

        activities.refresh(force: true) { [weak self] result in
            guard let self = self else { return }

            let announcementsEntry = AnnouncementsEntry(activities: self.activities.all)
            let timeline = Timeline(entries: [announcementsEntry], policy: .after(Date().addMinutes(5)))
            completion(timeline)
        }
    }
}
