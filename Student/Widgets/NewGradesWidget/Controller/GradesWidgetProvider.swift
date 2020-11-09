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

class GradesWidgetProvider: CommonWidgetController {
    private lazy var submissions = env.subscribe(GetRecentlyGradedSubmissions(userID: "self")) { [weak self] in self?.handleFetchFinished() }
    private lazy var courses = env.subscribe(GetCourses(showFavorites: false, perPage: 100)) { [weak self] in self?.handleFetchFinished() }
    private lazy var favoriteCourses = env.subscribe(GetCourses(showFavorites: true)) { [weak self] in self?.handleFetchFinished() }
    private var completion: ((Timeline<GradeModel>) -> Void)?

    private func update() {
        guard isLoggedIn else {
            updateWidget(model: GradeModel(isLoggedIn: false))
            return
        }

        setupLastLoginCredentials()
        colors.refresh { [weak self] _ in
            guard let self = self, !self.colors.pending else { return }

            self.submissions.refresh()
            self.courses.refresh()
            self.favoriteCourses.refresh()
        }
    }

    private func handleFetchFinished() {
        guard completion != nil, !submissions.pending, !courses.pending, !favoriteCourses.pending else { return }

        let assignmentGrades: [GradeItem] = (submissions.first?.submissions ?? []).compactMap { $0.assignment }.map { assignment in
            let courseColor = courses.all.first { $0.id == assignment.courseID }?.color ?? .textDarkest
            return GradeItem(assignment: assignment, color: courseColor)
        }
        let courseGrades = favoriteCourses.all.map { GradeItem(course: $0) }

        updateWidget(model: GradeModel(assignmentGrades: assignmentGrades, courseGrades: courseGrades))
    }

    private func updateWidget(model: GradeModel) {
        let timeoutSeconds = submissions.useCase.ttl
        completion?(Timeline(entries: [model], policy: .after(Date().addingTimeInterval(timeoutSeconds))))
        self.completion = nil
    }
}

extension GradesWidgetProvider: TimelineProvider {
    typealias Entry = GradeModel

    func placeholder(in context: TimelineProvider.Context) -> GradeModel {
        GradeModel.make()
    }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (GradeModel) -> Void) {
        completion(GradeModel.make())
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping (Timeline<GradeModel>) -> Void) {
        if context.isPreview {
            completion(Timeline(entries: [GradeModel(assignmentGrades: [], courseGrades: [])], policy: .after(Date())))
            return
        }

        self.completion = completion
        update()
    }
}
