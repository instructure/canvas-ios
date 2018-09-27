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
    weak var view: AssignmentDetailsViewProtocol?
//    var frc: FetchedResultsController<Assignment>?

    var useCase: PresenterUseCase?
    let queue = OperationQueue()

    init(env: AppEnvironment = .shared, view: AssignmentDetailsViewProtocol, courseID: String, assignmentID: String) {
        self.view = view
//        frc = env.database.fetchedResultsController(predicate: pred, sortDescriptors: [sort], sectionNameKeyPath: nil)
//        frc?.delegate = self
    }

    func loadAssignment() {
//        do {
//            try frc?.performFetch()
//            view?.showAssignment()
//        } catch {
//            view?.showError(error)
//        }
    }

    func loadDataFromServer() {
        // Mock
        view?.update(assignment: AssignmentDetailsViewModel(
            name: "Essay #1: The Rocky Planets",
            pointsPossible: 10.5,
            dueAt: Date(),
            submissionTypes: [ "File Upload", "Text Entry", "Website URL" ]
        ))

        guard let useCase = useCase else { return }
        queue.addOperation(useCase)
    }

    func viewIsReady() {
        loadDataFromServer()
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
