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
    var assignments: Store<GetAssignmentsForGrades>?
    var courses: Store<GetCourse>?
    var selectedGradingPeriodID: String?
    var selectedGradingPeriodTitle: String?
    lazy var initSelectedGradingPeriodOnce: () -> Void = {
        selectedGradingPeriodID = courses?.first?.enrollments?.filter({ $0.isStudent }).first?.currentGradingPeriodID
        return {}
    }()

    lazy var color = env.subscribe(GetCustomColors()) { [weak self] in
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

    func refresh(force: Bool = false) {
        didGetAssignmentGroups = false
        color.refresh(force: force)
        refreshCourses(force: force)
        gradingPeriods.refresh(force: force)
    }

    func update() {
        guard
            let assignmentGroups = assignmentGroups,
            let assignments = assignments,
            let courses = courses
            else { return }
        let loading = assignments.pending || assignmentGroups.pending || gradingPeriods.pending || courses.pending || color.pending

        selectedGradingPeriodTitle = gradingPeriods.filter { $0.id == selectedGradingPeriodID }.first?.title

        view?.update(loading: loading)
    }

    func updateNavbar() {
        guard let course = courses?.first else { return }
        view?.updateNavBar(subtitle: course.name, color: course.color)
    }

    func select(_ assignment: Assignment, from: UIViewController) {
        env.router.route(to: assignment.htmlURL, from: from, options: nil)
    }

    func refreshCourses(force: Bool) {
        let u = GetCourse(courseID: courseID)
        courses = env.subscribe( u ) { [weak self] in
            if let u = self?.courses, !u.pending {
                self?.refreshAssignments(force: force)
            }
            self?.update()
            self?.updateNavbar()
        }
        courses?.refresh(force: force)
    }

    func refreshAssignments(force: Bool) {
        //  on first load, we want to show the course.enrollment["student"].currentGradingPeriodID
        //  as the default, but after first load, respect whatever user selects in filter
        if !(courses?.pending ?? false), courses?.first != nil { initSelectedGradingPeriodOnce() }

        let u = GetAssignmentsForGrades(courseID: courseID,
                                              gradingPeriodID: selectedGradingPeriodID,
                                              groupBy: .assignmentGroup,
                                              requestQuerySize: 99,
                                              clearsBeforeWrite: true,
                                              include: [.all_dates])
        assignments = env.subscribe( u ) { [weak self] in
            guard let useCase = self?.assignments, let didGetAssignmentGroups = self?.didGetAssignmentGroups else { return }
            if !useCase.pending && !didGetAssignmentGroups {
                self?.refreshAssignmentGroups(force: true)
            } else {
                self?.update()
            }
        }
        assignments?.exhaust(while: { _ in true })
    }

    func refreshAssignmentGroups(force: Bool) {
        didGetAssignmentGroups = true
        let useCase = GetAssignmentGroups(courseID: courseID, gradingPeriodID: selectedGradingPeriodID, include: [.assignments])
        assignmentGroups = env.subscribe( useCase ) { [weak self] in
            self?.update()
        }
        assignmentGroups?.refresh(force: force)
    }

    func filterByGradingPeriod(_ period: GradingPeriod?) {
        selectedGradingPeriodID = period?.id
        selectedGradingPeriodTitle = period?.title
        didGetAssignmentGroups = false
        refreshAssignments(force: true)
    }

    var filterButtonTitle: String? {
        if selectedGradingPeriodID != nil {
            return NSLocalizedString("Clear filter", comment: "")
        } else {
            return NSLocalizedString("Filter", comment: "")
        }
    }

    var gradingPeriodTitle: String? {
        return selectedGradingPeriodTitle ?? NSLocalizedString("All Grading Periods", comment: "")
    }

    func title(forSection section: Int) -> String? {
        guard let ag = assignmentGroups, section < ag.count else { return nil }
        return ag[section]?.name
    }
}
