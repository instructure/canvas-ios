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
    func showEmptyState(_ show: Bool)
}

struct RubricViewModel: Hashable, Equatable {
    var id: String
    let title: String
    let longDescription: String
    let selectedDesc: String
    let selectedIndex: Int
    let ratings: [Double]
    let descriptions: [String]
    let comment: String?
    let rubricRatings: [RubricRating]
    var isCustomAssessment: Bool = false

    func ratingBlurb(_ atIndex: Int) -> (header: String, subHeader: String) {
        let isCustom = isCustomAssessment && atIndex >= rubricRatings.count
        let header = isCustom ? NSLocalizedString("Custom Grade", comment: "") : rubricRatings[atIndex].desc
        let subHeader = isCustom ? "" : rubricRatings[atIndex].longDesc
        return (header, subHeader)
    }
}

class RubricPresenter {

    lazy var assignments = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [.submission])) { [weak self] in
        self?.update()
    }

    lazy var submissions = env.subscribe(GetSubmission(context: ContextModel(.course, id: courseID), assignmentID: assignmentID, userID: userID)) { [weak self] in
        self?.update()
    }

    lazy var rubrics: Store<LocalUseCase<Rubric>> = env.subscribe(scope: Rubric.scope(assignmentID: assignmentID)) { [weak self] in
        self?.update()
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

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
        rubrics.refresh(force: true)
        courses.refresh()
        colors.refresh()
    }

    func update() {
        if rubrics.count > 0, let rubrics = rubrics.all, let assessments = submissions.first?.rubricAssessments, courses.first?.color != nil {
            let models = transformRubricsToViewModels(rubrics, assessments: assessments)
            view?.update(models)
        } else {
            view?.showEmptyState(true)
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
            var comments: String?
            var description = ""
            var isCustomAssessment = false

            if let index = sorted.firstIndex(where: { rr in assessment.ratingID == rr.id }) {
                selected = sorted[index]
                selectedIndex = index
                comments = assessment.comments
                description = selected?.desc ?? ""
            }
            var allRatings: [Double] = sorted.map { $0.points }
            var allDescriptions: [String] = sorted.map { $0.desc }
            if selected == nil {
                //  this is a custom assesment
                allRatings.append(assessment.points)
                selectedIndex = allRatings.count - 1
                description = NSLocalizedString("Custom Grade", comment: "")
                allDescriptions.append(description)
                comments = assessment.comments
                isCustomAssessment = true
            }

            let m = RubricViewModel(
                id: r.id,
                title: r.desc,
                longDescription: r.longDesc,
                selectedDesc: description,
                selectedIndex: selectedIndex,
                ratings: allRatings,
                descriptions: allDescriptions,
                comment: comments,
                rubricRatings: sorted,
                isCustomAssessment: isCustomAssessment
            )
            models.append(m)
        }
        return models
    }
}
