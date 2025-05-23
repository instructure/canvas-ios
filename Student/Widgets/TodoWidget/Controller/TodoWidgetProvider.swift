//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class TodoWidgetProvider: CommonWidgetProvider<TodoModel> {
    private var colors: Store<GetCustomColors>?
    private var plannables: Store<GetPlannables>?
    private var courses: Store<GetCourses>?
    private var favoriteCourses: Store<GetCourses>?

    static let startDate: Date = .now.startOfDay()
    static let endDate: Date = startDate.addDays(28)

    init() {
        super.init(loggedOutModel: TodoModel(isLoggedIn: false), timeout: 2 * 60 * 60)
    }

    override func fetchData() {
        colors = env.subscribe(GetCustomColors())
        colors?.refresh { [weak self] _ in
            guard let self = self, let colors = self.colors, !colors.pending else { return }

            self.courses = self.env.subscribe(GetCourses(showFavorites: false, perPage: 100)) { [weak self] in self?.courseFetchFinished() }
            self.courses?.refresh()

            self.favoriteCourses = self.env.subscribe(GetCourses(showFavorites: true)) { [weak self] in self?.courseFetchFinished() }
            self.favoriteCourses?.refresh()
        }
    }

    private func courseFetchFinished() {
        guard
            let courses = courses, !courses.pending,
            let favoriteCourses = favoriteCourses, !favoriteCourses.pending
        else {
            return
        }

        let coursesToMap = favoriteCourses.all.isNotEmpty ? favoriteCourses.all : courses.all
        var contextCodes = coursesToMap.compactMap(\.id).map { courseId in
            return "course_\(courseId)"
        }
        if let userId = LoginSession.mostRecent?.userID {
            contextCodes.append("user_\(userId)")
        }
        plannables = env.subscribe(
            GetPlannables(
                userID: "self",
                startDate: Self.startDate,
                endDate: Self.endDate,
                contextCodes: contextCodes
            )
        ) { [weak self] in
            self?.plannableFetchFinished()
        }
        self.plannables?.refresh()
    }

    private func plannableFetchFinished() {
        guard let plannables = plannables, !plannables.pending else { return }

        let compactPlannables = plannables.compactMap { $0 }
        let plannableItems: [Plannable] = compactPlannables.filter {
            $0.plannableType != .announcement && $0.plannableType != .assessment_request
        }

        updateWidget(model: TodoModel(items: plannableItems))
    }
}
