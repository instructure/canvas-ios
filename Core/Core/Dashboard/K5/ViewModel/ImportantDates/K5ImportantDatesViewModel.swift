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

public class K5ImportantDatesViewModel: ObservableObject {

    @Published public private(set) var importantDates: [K5ImportantDate] = []

    private let env = AppEnvironment.shared
    private var contexts: [Context] = []

    private lazy var courses = env.subscribe(GetUserCourses(userID: env.currentSession?.userID ?? "")) { [weak self] in
        self?.coursesUpdated()
    }

    private lazy var events = env.subscribe(GetCalendarEvents(contexts: contexts, type: .event, importantDates: true)) { [weak self] in
        self?.eventsUpdated()
    }

    private lazy var assignments = env.subscribe(GetCalendarEvents(contexts: contexts, type: .assignment, importantDates: true)) { [weak self] in
        self?.assignmentsUpdated()
    }

    // MARK: Refresh
    private var refreshCompletion: (() -> Void)?
    private var forceRefresh = false

    init() {
        courses.refresh()
    }
    private func coursesUpdated() {
        contexts.removeAll()
        courses.forEach { course in
            contexts.append(Context(.course, id: course.id))
        }
        assignments.exhaust(force: true)
    }

    private func assignmentsUpdated() {
        assignments.forEach { assignment in

            addImportantDate(from: assignment)
        }
        events.exhaust(force: true)
    }

    private func eventsUpdated() {
        events.forEach { event in
            addImportantDate(from: event)
        }
        finishRefresh()
    }

    func addImportantDate(from event: CalendarEvent) {
        let formattedDateTitle = event.startAt?.dateOnlyString
        if let existingDate = importantDates.first(where: { $0.title == formattedDateTitle }) {
            existingDate.addEvent(event)
        } else {
            importantDates.append(K5ImportantDate(with: event))
        }
    }

    private func finishRefresh() {
        forceRefresh = false
        performUIUpdate {
            self.refreshCompletion?()
            self.refreshCompletion = nil
        }
    }
}

extension K5ImportantDatesViewModel: Refreshable {

    public func refresh(completion: @escaping () -> Void) {
        forceRefresh = true
        refreshCompletion = completion
        reloadData()
    }

    func reloadData() {
        courses.exhaust(force: true)
    }
}
