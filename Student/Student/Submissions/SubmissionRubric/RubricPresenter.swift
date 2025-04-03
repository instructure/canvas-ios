//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Core
import UIKit

protocol RubricViewProtocol: ErrorViewController {
    func update(_ rubric: [RubricViewModel])
    func showEmptyState(_ show: Bool)
}

struct RubricViewModel: Hashable, Equatable {
    var id: String
    let title: String
    let longDescription: String
    let selectedDesc: String
    let selectedIndex: Int?
    let ratings: [Double]
    let descriptions: [String]
    let comment: String?
    let rubricRatings: [CDRubricRating]
    var isCustomAssessment: Bool = false
    var hideRubricPoints: Bool
    var freeFormCriterionComments: Bool

    func ratingBlurb(_ atIndex: Int) -> (header: String, subHeader: String) {
        let isCustom = isCustomAssessment && atIndex >= rubricRatings.count
        let header = isCustom ? String(localized: "Custom Grade", bundle: .student) : rubricRatings[atIndex].desc
        let subHeader = isCustom ? "" : rubricRatings[atIndex].longDesc
        return (header, subHeader)
    }

    var onlyShowComments: Bool { hideRubricPoints && freeFormCriterionComments }
}

class RubricPresenter {
    lazy var assignments = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [.submission])) { [weak self] in
        self?.update()
    }

    lazy var submissions = env.subscribe(GetSubmission(context: .course(courseID), assignmentID: assignmentID, userID: userID)) { [weak self] in
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
        courses.refresh()
        colors.refresh()
    }

    func update() {
        if let assignment = assignments.first, let rubrics = assignment.rubric, !rubrics.isEmpty, courses.first?.color != nil {
            let assessments = submissions.first?.rubricAssessments
            let models = transformRubricsToViewModels(
                rubrics,
                assessments: assessments,
                hideRubricPoints: assignment.hideRubricPoints,
                freeFormCriterionComments: assignment.freeFormCriterionCommentsOnRubric
            )
            view?.update(models)
        } else {
            view?.showEmptyState(true)
        }
    }

    func transformRubricsToViewModels(_ rubrics: [CDRubricCriterion], assessments: RubricAssessments?, hideRubricPoints: Bool, freeFormCriterionComments: Bool) -> [RubricViewModel] {
        var models = [RubricViewModel]()
        for rubric in rubrics {
            guard var ratings = rubric.ratings.flatMap(Array.init) else { continue }
            let assessment = assessments?[rubric.id]
            ratings = ratings.sorted { $0.points < $1.points }
            var selected: CDRubricRating?
            var selectedIndex: Int?
            let comments = assessment?.comments
            var description = ""
            var isCustomAssessment = false

            if let index = ratings.firstIndex(where: { rating in assessment?.ratingID == rating.id && rating.points == assessment?.points }) {
                selected = ratings[index]
                selectedIndex = index
                description = selected?.desc ?? ""
            }
            var allRatings: [Double] = ratings.map { $0.points }
            var allDescriptions: [String] = ratings.map { $0.desc }
            if selected == nil, let assessment = assessment, let points = assessment.points {
                //  this is a custom assesment
                allRatings.append(points)
                selectedIndex = allRatings.count - 1
                description = String(localized: "Custom Grade", bundle: .student)
                allDescriptions.append(description)
                isCustomAssessment = true
            }

            let m = RubricViewModel(
                id: rubric.id,
                title: rubric.desc,
                longDescription: rubric.longDesc,
                selectedDesc: description,
                selectedIndex: selectedIndex,
                ratings: allRatings,
                descriptions: allDescriptions,
                comment: comments,
                rubricRatings: ratings,
                isCustomAssessment: isCustomAssessment,
                hideRubricPoints: hideRubricPoints,
                freeFormCriterionComments: freeFormCriterionComments
            )
            models.append(m)
        }
        return models
    }

    func show(_ url: URL, from viewController: UIViewController) {
        env.router.route(to: url, from: viewController)
    }
}
