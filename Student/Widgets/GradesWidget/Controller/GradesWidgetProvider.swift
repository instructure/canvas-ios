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

class GradesWidgetProvider: CommonWidgetProvider<GradeModel> {
    private lazy var submissions = env.subscribe(GetRecentlyGradedSubmissions(userID: "self")) { [weak self] in self?.handleFetchFinished() }
    private lazy var courses = env.subscribe(GetCourses(showFavorites: false, perPage: 100)) { [weak self] in self?.handleFetchFinished() }
    private lazy var favoriteCourses = env.subscribe(GetCourses(showFavorites: true)) { [weak self] in self?.handleFetchFinished() }

    init() {
        super.init(loggedOutModel: GradeModel(isLoggedIn: false), timeout: 2 * 60 * 60)
    }

    override func fetchData() {
        colors.refresh { [weak self] _ in
            guard let self = self, !self.colors.pending else { return }

            self.submissions.refresh()
            self.courses.refresh()
            self.favoriteCourses.refresh()
        }
    }

    private func handleFetchFinished() {
        guard !submissions.pending, !courses.pending, !favoriteCourses.pending else { return }

        let assignmentGrades: [GradeItem] = (submissions.first?.submissions ?? []).compactMap { $0.assignment }.map { assignment in
            let courseColor = courses.all.first { $0.id == assignment.courseID }?.color ?? .textDarkest
            return GradeItem(assignment: assignment, color: courseColor)
        }
        let courseGrades = favoriteCourses.all.map { GradeItem(course: $0) }

        updateWidget(model: GradeModel(assignmentGrades: assignmentGrades, courseGrades: courseGrades))
    }
}
