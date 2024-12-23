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
        forceRefresh = true
        courses.refresh()
    }

#if DEBUG
    init(with dates: [K5ImportantDate]) {
        self.importantDates = dates
    }
#endif

    private func coursesUpdated() {
        guard courses.requested, !courses.pending, courses.count > 0 else { return }
        contexts = courses.map { Context(.course, id: $0.id) }
        assignments.exhaust(force: forceRefresh)
    }

    private func assignmentsUpdated() {
        importantDates.removeAll()
        assignments.forEach { assignment in
            addImportantDate(from: assignment)
        }
        events.exhaust(force: forceRefresh)
    }

    private func eventsUpdated() {
        events.forEach { event in
            addImportantDate(from: event)
        }
        finishRefresh()
    }

    func addImportantDate(from event: CalendarEvent) {
        guard let startDate = event.startAt, startDate >= Clock.now.startOfDay(), let course = courses.filter({ $0.id == event.context.id }).first else { return }
        let courseColor = Color(course.color)
        if let existingDate = importantDates.first(where: { $0.date.dateOnlyString == startDate.dateOnlyString }) {
            existingDate.addEvent(event, color: courseColor)
        } else {
            guard let importantDate = K5ImportantDate(with: event, color: courseColor) else { return }
            importantDates.append(importantDate)
        }
    }

    private func finishRefresh() {
        importantDates = importantDates.sorted(by: { $0.date < $1.date })
        forceRefresh = false
        performUIUpdate {
            self.refreshCompletion?()
            self.refreshCompletion = nil
        }
    }
}

extension K5ImportantDatesViewModel: Refreshable {

    @available(*, renamed: "refresh()")
    public func refresh(completion: @escaping () -> Void) {
        Task {
            await refresh()
            completion()
        }
    }

    public func refresh() async {
        forceRefresh = true
        return await withCheckedContinuation { continuation in
            refreshCompletion = {
                continuation.resume()
            }
            reloadData()
        }
    }

    private func reloadData() {
        courses.exhaust(force: true)
    }
}
