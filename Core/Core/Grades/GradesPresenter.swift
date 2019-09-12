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

protocol GradesViewProtocol: ErrorViewController {
    func update(groups: [String], assignmentsByGroup: [[GradesPresenter.CellViewModel]])
}

class GradesPresenter {

    struct CellViewModel: Equatable {
        var name: String
        var grade: String?
        var status: String?
        var icon: UIImage?
    }

    var sort: GetAssignments.Sort
    let courseID: String
    let env: AppEnvironment
    weak var view: GradesViewProtocol?
    var didRefreshAssignments = false

    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    lazy var assignmentGroups = env.subscribe(GetAssignmentGroups(courseID: courseID)) { [weak self] in
        self?.update()
    }

    lazy var assignments = env.subscribe(GetAssignments(courseID: self.courseID, sort: sort, include: [.submission, .observed_users])) { [weak self] in
        self?.update()
    }

    init(env: AppEnvironment = .shared, view: GradesViewProtocol, courseID: String, sort: GetAssignments.Sort = GetAssignments.Sort.dueAt) {
        self.courseID = courseID
        self.env = env
        self.view = view
        self.sort = sort
    }

    func viewIsReady() {
        assignments.refresh(force: true) // does this need to exhaust?
        course.refresh()
    }

    func update() {
        if !assignments.pending && !didRefreshAssignments {
            didRefreshAssignments = true
            assignmentGroups.refresh(force: true)   // does this need to exhaust?
        }

        if didRefreshAssignments && assignments.count > 0 && !assignments.pending && assignmentGroups.count > 0 {
            var groups: [String] = []
            var assignmentsByGroup = [[CellViewModel]]()
            assignmentGroups.forEach {
                groups.append($0.name)
                let models = Array($0.assignments).map { viewModel(from: $0) }
                assignmentsByGroup.append( models )
            }

            view?.update(groups: groups, assignmentsByGroup: assignmentsByGroup)
        }
    }

    func viewModel(from: Assignment) -> CellViewModel {
        return CellViewModel(name: from.name, grade: from.gradeText, status: from.submissionStatusText, icon: from.icon)
    }

    func select(_ assignment: Assignment, from: UIViewController) {
        env.router.route(to: assignment.htmlURL, from: from, options: nil)
    }
}
