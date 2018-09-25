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

protocol AssignmentDetailsViewProtocol: class {
//    func showAssignment(_ assignment: AssignmentDetail)
}

typealias AssignmentDetailsViewCompositeDelegate = AssignmentDetailsViewProtocol & ErrorViewController

class AssignmentDetailsPresenter {
    weak var view: AssignmentDetailsViewCompositeDelegate?
//    var frc: FetchedResultsController<Assignment>?

    var useCase: PresenterUseCase?
    let queue = OperationQueue()

    init(env: AppEnvironment) {
//        frc = env.database.fetchedResultsController(predicate: pred, sortDescriptors: [sort], sectionNameKeyPath: nil)
//        frc?.delegate = self

        loadDataFromServer()
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
        guard let useCase = useCase else { return }
        queue.addOperation(useCase)
    }
}
