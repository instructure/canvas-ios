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

class AssignmentDetailsPresenter {
    typealias PresenterFactory = (String, String) -> PresenterUseCase

    var frc: FetchedResultsController<Assignment>?
    weak var view: AssignmentDetailsViewProtocol?
    var useCase: PresenterUseCase?
    let queue = OperationQueue()
    let courseID: String
    let assignmentID: String
    let useCaseFactory: PresenterFactory
    static var factory: PresenterFactory  = { (courseID: String, assignmentID: String) in
        return AssignmentDetailsUseCase(courseID: courseID, assignmentID: assignmentID)
    }

    init(env: AppEnvironment = .shared, view: AssignmentDetailsViewProtocol, courseID: String, assignmentID: String, useCaseFactory: @escaping PresenterFactory = factory) {
        self.view = view
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.useCaseFactory = useCaseFactory
        let predicate = NSPredicate.id(assignmentID)
        frc = env.database.fetchedResultsController(predicate: predicate, sortDescriptors: nil, sectionNameKeyPath: nil)
        frc?.delegate = self
    }

    func loadAssignment() {
        do {
            try frc?.performFetch()
            guard let assignment = frc?.fetchedObjects?.first else { return }
            view?.update(assignment: AssignmentDetailsViewModel(
                name: assignment.name,
                pointsPossible: assignment.pointsPossible,
                dueAt: assignment.dueAt,
                submissionTypes: assignment.submissionTypes
            ))
        } catch {
            view?.showError(error)
        }
    }

    func loadDataFromServer() {
        let useCase = useCaseFactory(courseID, assignmentID)
        queue.addOperation(useCase)
    }

    func viewIsReady() {
        loadDataFromServer()
        loadAssignment()
    }

    func pageViewStarted() {
        // Mock
        view?.updateNavBar(subtitle: "Course 1234", backgroundColor: .green)
        // log page view
    }

    func pageViewEnded() {
        // log page view
    }
}

extension AssignmentDetailsPresenter: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        loadAssignment()
    }
}
