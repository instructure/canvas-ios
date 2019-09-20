//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
import CoreData

protocol GradesViewProtocol: ErrorViewController {
    func update(isLoading: Bool)
    func updateScore(_ score: String?)
}

class GradesPresenter {
    var sort: GetAssignments.Sort
    let courseID: String
    let studentID: String
    let env: AppEnvironment
    weak var view: GradesViewProtocol?
    var didFetchGroups = false

    private let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.multiplier = 1.0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        return formatter
    }()

    lazy var courses = env.subscribe(GetCourse(courseID: courseID, include: [.observedUsers, .totalScores])) { [weak self] in
        self?.update()
    }

    lazy var assignments = env.subscribe(GetAssignmentsForGrades(courseID: courseID, requestQuerySize: 99)) { [weak self] in
        self?.update()
    }

    lazy var gradingPeriods = env.subscribe(GetGradingPeriods(courseID: courseID)) { [weak self] in
        self?.update()
    }

    init(env: AppEnvironment = .shared, view: GradesViewProtocol, courseID: String, studentID: String, sort: GetAssignments.Sort = GetAssignments.Sort.dueAt) {
        self.courseID = courseID
        self.env = env
        self.view = view
        self.sort = sort
        self.studentID = studentID
    }

    func refresh(force: Bool = false) {
        assignments.refresh(force: force)
        courses.refresh(force: force)
        gradingPeriods.refresh(force: force)
    }

    func update() {
        if let course = courses.first,
            let enrollments = course.enrollments?.filter({ $0.userID == studentID }) {
            let score = percentageFormatter.string(for: enrollments.first?.computedCurrentScore)
            view?.updateScore(score)
        }

        view?.update(isLoading: courses.pending || assignments.pending || gradingPeriods.pending)
        if let error = courses.error ?? assignments.error {
            view?.showError(error)
        }
    }

    func select(_ assignment: Assignment, from: UIViewController) {
        env.router.route(to: assignment.htmlURL, from: from, options: nil)
    }
}
