//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import SwiftUI

public class DashboardConferencesViewModel: ObservableObject {
    // MARK: - Public Properties
    @Published public private(set) var conferences: [(entity: Conference, contextName: String)] = []

    // MARK: - Private Properties
    private lazy var conferencesStore: Store<GetLiveConferences> = AppEnvironment.shared.subscribe(GetLiveConferences()) { [weak self] in
        self?.update()
    }
    private lazy var coursesStore = AppEnvironment.shared.subscribe(GetCourses(enrollmentState: nil)) { [weak self] in
        self?.update()
    }
    private lazy var groupsStore = AppEnvironment.shared.subscribe(GetDashboardGroups()) { [weak self] in
        self?.update()
    }
    private var isRefreshFinished: Bool {
        conferencesStore.requested && !conferencesStore.pending &&
        coursesStore.requested && !coursesStore.pending &&
        groupsStore.requested && !groupsStore.pending
    }

    // MARK: - Public Methods

    public func refresh(force: Bool = false) {
        conferencesStore.refresh(force: force)
        coursesStore.exhaust(force: force)
        groupsStore.exhaust(force: force)
    }

    // MARK: - Private Methods

    private func update() {
        guard isRefreshFinished else { return }

        var newConferences: [(Conference, String)] = []

        for conference in conferencesStore.all {
            guard let contextName = contextName(for: conference) else { continue }
            newConferences.append((conference, contextName))
        }

        self.conferences = newConferences
    }

    private func contextName(for conference: Conference) -> String? {
        if conference.context.contextType == .group {
            return groupsStore.first { $0.id == conference.context.id }?.name
        } else {
            return coursesStore.first { $0.id == conference.context.id }?.name
        }
    }
}
