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
import Core

protocol AssignmentListViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func update(loading: Bool)
}

class AssignmentListPresenter {

    var sort: GetAssignments.Sort
    let courseID: String
    let env: AppEnvironment
    weak var view: AssignmentListViewProtocol?
    var didGetAssignmentGroups = false
    var assignmentGroups: Store<GetAssignmentGroups>?
    var assignments: Store<GetAssignmentsForGrades>!
    var selectedGradingPeriod: GradingPeriod?

    lazy var color = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavbar()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
        self?.updateNavbar()
    }

    lazy var gradingPeriods = env.subscribe(GetGradingPeriods(courseID: courseID)) { [weak self] in
        self?.update()
    }

    init(env: AppEnvironment = .shared, view: AssignmentListViewProtocol, courseID: String, sort: GetAssignments.Sort = .position) {
        self.courseID = courseID
        self.env = env
        self.view = view
        self.sort = sort
    }

    func viewIsReady() {
//        assignments.exhaust(while: { _ in true })
//        color.refresh()
        refresh(force: true)
    }

    func refresh(force: Bool = false) {
        didGetAssignmentGroups = false
        color.refresh(force: force)
        courses.refresh(force: force)
        refreshAssignments(force: force)
        gradingPeriods.refresh(force: force)
    }

    func update() {
        guard
            let assignmentGroups = assignmentGroups,
            let assignments = assignments
            else { return }
        let loading = assignments.pending || assignmentGroups.pending || gradingPeriods.pending || courses.pending || color.pending
        view?.update(loading: loading)
    }

    func updateNavbar() {
        guard let course = courses.first else { return }
        view?.updateNavBar(subtitle: course.name, color: course.color)
    }

    func select(_ assignment: Assignment, from: UIViewController) {
        env.router.route(to: assignment.htmlURL, from: from, options: nil)
    }

    func refreshAssignments(force: Bool) {
        let useCase = GetAssignmentsForGrades(courseID: courseID, gradingPeriodID: selectedGradingPeriod?.id, groupBy: .assignmentGroup, requestQuerySize: 99, clearsBeforeWrite: true, include: [.all_dates])
        assignments = env.subscribe( useCase ) { [weak self] in
            guard let useCase = self?.assignments, let didGetAssignmentGroups = self?.didGetAssignmentGroups else { return }
            if !useCase.pending && !didGetAssignmentGroups {
                self?.refreshAssignmentGroups(force: force)
            } else {
                self?.update()
            }
        }
        assignments?.refresh(force: force)
    }

    func refreshAssignmentGroups(force: Bool) {
        didGetAssignmentGroups = true
        assignmentGroups = env.subscribe(  GetAssignmentGroups(courseID: courseID, gradingPeriodID: selectedGradingPeriod?.id, include: [.assignments])  ) { [weak self] in
                self?.update()
        }
        assignmentGroups?.refresh(force: force)
    }

    func filterByGradingPeriod(_ period: GradingPeriod?) {
        selectedGradingPeriod = period
        didGetAssignmentGroups = false
        refreshAssignments(force: selectedGradingPeriod != nil)
    }

    var filterButtonTitle: String? {
        if selectedGradingPeriod != nil {
            return NSLocalizedString("Clear filter", comment: "")
        } else {
            return NSLocalizedString("Filter", comment: "")
        }
    }

    var gradingPeriodTitle: String? {
        if let p = selectedGradingPeriod {
            return p.title
        } else {
            return NSLocalizedString("All Grading Periods", comment: "")
        }
    }
}
