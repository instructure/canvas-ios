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
}

class GradesPresenter {
    var sort: GetAssignments.Sort
    let courseID: String
    let env: AppEnvironment
    weak var view: GradesViewProtocol?
    var didFetchGroups = false

    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    lazy var assignments = env.subscribe(GetAssignmentsForGrades(courseID: self.courseID, requestQuerySize: 99)) { [weak self] in
        self?.update()
    }

    init(env: AppEnvironment = .shared, view: GradesViewProtocol, courseID: String, sort: GetAssignments.Sort = GetAssignments.Sort.dueAt) {
        self.courseID = courseID
        self.env = env
        self.view = view
        self.sort = sort
    }

    func viewIsReady() {
        assignments.refresh()
        course.refresh()
    }

    func update() {
        view?.update(isLoading: assignments.pending)
        if let error = course.error ?? assignments.error {
            view?.showError(error)
        }
    }

    func select(_ assignment: Assignment, from: UIViewController) {
        env.router.route(to: assignment.htmlURL, from: from, options: nil)
    }
}

extension Assignment {
    public var gradesListGradeText: String? {
        let totalPointsPossible: String = formattedGradeNumber(pointsPossible) ?? ""
        let emptyPoints = "- / \(totalPointsPossible)"
        guard let submission = submission else {
            return emptyPoints
        }

        if submission.excused ?? false {
            return NSLocalizedString("Excused", comment: "")
        }

        if submission.score == nil {
            return "- / \(totalPointsPossible)"
        }

        let score = formattedGradeNumber(submission.score) ?? ""

        switch gradingType {
        case .pass_fail:
            var status = "-"
            status = submission.grade == "incomplete"
                ? NSLocalizedString("Incomplete", bundle: .core, comment: "")
                : NSLocalizedString("Complete", bundle: .core, comment: "")
            return "\(status) / \(totalPointsPossible)"
        case .points:
            return "\(score) / \(totalPointsPossible)"

        case .letter_grade, .percent, .gpa_scale:
            return "\(score) / \(totalPointsPossible) (\(submission.grade ?? ""))"
        case .not_graded:
            return ""
        }
    }

    public var submissionStatus: String {
        guard let s = submission else { return NSLocalizedString("Not Submitted", comment: "") }

        if !submissionTypes.isOnline { return "" }
        if s.excused ?? false { return "" }
        if s.late { return NSLocalizedString("Late", comment: "") }
        if s.missing { return NSLocalizedString("Missing", comment: "") }
        if s.submittedAt != nil { return NSLocalizedString("Submitted", comment: "") }

        return ""
    }

    func formattedGradeNumber(_ number: Double?) -> String? {
        guard let number = number else { return nil }
        return NumberFormatter.localizedString(from: NSNumber(value: (number * 100) / 100), number: .decimal)
    }
}
