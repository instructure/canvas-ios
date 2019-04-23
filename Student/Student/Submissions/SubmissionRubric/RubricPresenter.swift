//
// Copyright (C) 2019-present Instructure, Inc.
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

protocol RubricViewProtocol: ErrorViewController {
    func update(_ rubric: [RubricViewModel])
    func showEmptyState()
}

struct RubricViewModel {
    let title: String
    let selectedDesc: String
    let selectedIndex: Int
    let ratings: [Double]
}

class RubricPresenter {

    lazy var assignments = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [.submission])) { [weak self] in
        self?.update()
    }

    lazy var submissions = env.subscribe(GetSubmission(context: ContextModel(.course, id: courseID), assignmentID: assignmentID, userID: userID)) { [weak self] in
        self?.update()
    }

    lazy var frc: FetchedResultsController<Rubric>? = {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Rubric.assignmentID), assignmentID)
        let sort1 = NSSortDescriptor(key: #keyPath(Rubric.position), ascending: true)
        let controller: FetchedResultsController<Rubric>? = env.database.fetchedResultsController(predicate: predicate,
                                                                                                  sortDescriptors: [sort1],

                                                                                                  sectionNameKeyPath: nil)
        controller?.performFetch()
        return controller
    }()

    let env: AppEnvironment
    weak var view: RubricViewProtocol?
    let courseID: String
    let assignmentID: String
    let userID: String

    init(env: AppEnvironment = .shared, view: RubricViewProtocol, courseID: String, assignmentID: String, userID: String) {
        self.env = env
        self.view = view
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userID = userID
    }

    func viewIsReady() {
        assignments.refresh(force: true)
        submissions.refresh(force: true)
    }

    func update() {
        if let rubrics = frc?.fetchedObjects, let assessments = submissions.first?.rubricAssessments {
            let models = transformRubricsToViewModels(rubrics, assessments: assessments)
            view?.update(models)
        } else {
            view?.showEmptyState()
        }
    }

    func transformRubricsToViewModels(_ rubric: [Rubric], assessments: RubricAssessments) -> [RubricViewModel] {
        var models = [RubricViewModel]()
        for r in rubric {
            guard let ratings = r.ratings else { continue }
            guard let assessment = assessments[r.id] else { continue }

            let sorted = Array(ratings).sorted { $0.points < $1.points }
            var selected: RubricRating?
            var selectedIndex = 0

            if let index = sorted.firstIndex(where: { rr in assessment.points == rr.points }) {
                selected = sorted[index]
                selectedIndex = index
            }
            let allRatings: [Double] = sorted.map { $0.points }
            let m = RubricViewModel(title: r.desc, selectedDesc: selected?.desc ?? "", selectedIndex: selectedIndex, ratings: allRatings)
            models.append(m)
        }
        return models
    }
}
