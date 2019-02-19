//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Core

protocol AssignmentListViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func update(list: [Assignment])
}

class AssignmentListPresenter {
    let courseID: String
    let env: AppEnvironment
    weak var view: AssignmentListViewProtocol?
    let frc: FetchedResultsController<Assignment>
    let frcCourse: FetchedResultsController<Course>
    let useCaseFactory: UseCaseFactory

    init(env: AppEnvironment = .shared, view: AssignmentListViewProtocol, courseID: String) {
        self.courseID = courseID
        self.env = env
        self.view = view
        frc = env.subscribe(Assignment.self, .courseList(courseID))
        frcCourse = env.subscribe(Course.self, .details(courseID))
        useCaseFactory = { force in return AssignmentListUseCase(courseID: courseID, force: force) }
        frc.delegate = self
    }

    func loadDataForView() {
        loadAssignments()
        loadColor()
    }

    func loadAssignments() {
        frc.performFetch()
        guard let assignments = frc.fetchedObjects else { return }
        view?.update(list: assignments)
    }

    func loadColor() {
        frcCourse.performFetch()
        guard let course = frcCourse.fetchedObjects?.first else { return }
        view?.updateNavBar(subtitle: course.name, color: course.color)
    }

    func loadDataFromServer(force: Bool = false) {
        let useCase = AssignmentListUseCase(courseID: courseID, force: force)
        let reload = BlockOperation { DispatchQueue.main.async {[weak self] in self?.loadDataForView() } }
        reload.addDependency(useCase)
        env.queue.addOperation(reload)
        env.queue.addOperationWithErrorHandling(useCase, sendErrorsTo: view)
    }

    func select(_ assignment: Assignment, from: UIViewController) {
        env.router.route(to: assignment.htmlURL, from: from, options: nil)
    }
}

extension AssignmentListPresenter: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        loadDataForView()
    }
}
