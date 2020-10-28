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

class GradesWidgetController {
    private let env = AppEnvironment.shared
    private lazy var colorStore = env.subscribe(GetCustomColors())
    private lazy var submissionStore = env.subscribe(GetRecentlyGradedSubmissions(userID: "self"))
    private lazy var courseStore = env.subscribe(GetCourses(showFavorites: false, perPage: 100))
    private lazy var favoriteCoursesStore = env.subscribe(GetCourses(showFavorites: true))
    private var dispatchGroup: DispatchGroup?
    private var isReadyToFetch: Bool { dispatchGroup == nil }

    private func update(completion: @escaping (_ assignmentGrades: [GradeItem], _ courseGrades: [GradeItem]) -> Void) {
        guard isReadyToFetch else { return }

        setupLastLoginCredentials()
        colorStore.refresh { [weak self] _ in
            self?.updateGrades(completion: completion)
        }
    }

    private func updateGrades(completion: @escaping (_ assignmentGrades: [GradeItem], _ courseGrades: [GradeItem]) -> Void) {
        var submissions: [Submission] = []
        var courses: [Course] = []
        var favoriteCourses: [Course] = []

        let dispatchGroup = DispatchGroup()
        self.dispatchGroup = dispatchGroup
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()

        submissionStore.refresh { [weak self] _ in
            submissions = self?.submissionStore.first?.submissions ?? []
            dispatchGroup.leave()
        }

        courseStore.refresh { [weak self] _ in
            courses = self?.courseStore.all ?? []
            dispatchGroup.leave()
        }

        favoriteCoursesStore.refresh { [weak self] _ in
            favoriteCourses = self?.favoriteCoursesStore.all ?? []
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            let assignmentGrades: [GradeItem] = submissions.compactMap { $0.assignment }.map { assignment in
                let courseColor = courses.first { $0.id == assignment.courseID }?.color ?? .textDarkest
                return GradeItem(assignment: assignment, color: courseColor)
            }
            let courseGrades = favoriteCourses.map { GradeItem(course: $0) }
            completion(assignmentGrades, courseGrades)
            self?.dispatchGroup = nil
        }
    }

    private func setupLastLoginCredentials() {
        guard let mostRecentKeyChain = LoginSession.mostRecent else { return }
        env.userDidLogin(session: mostRecentKeyChain)
    }
}

extension GradesWidgetController: TimelineProvider {
    typealias Entry = GradeModel

    func placeholder(in context: TimelineProvider.Context) -> GradeModel {
        GradeModel.make()
    }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (GradeModel) -> ()) {
        completion(GradeModel.make())
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping (Timeline<GradeModel>) -> ()) {
        let timeoutSeconds = courseStore.useCase.ttl
        update { assignmentGrades, courseGrades in
            let timeline = Timeline(entries: [GradeModel(assignmentGrades: assignmentGrades, courseGrades: courseGrades)], policy: .after(Date().addingTimeInterval(timeoutSeconds)))
            completion(timeline)
        }
    }
}
