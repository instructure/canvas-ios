//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Combine
import Core
import SwiftUI

class RubricCriteriaViewModel: ObservableObject, Identifiable {

    // MARK: - Inputs

    var controller = WeakViewController() {
        didSet {
            customRatingViewModel.controller = controller
        }
    }
    @Binding var rubricComment: String
    @Binding var rubricCommentID: String?
    @Published var userComment: String?

    // MARK: - Outputs

    var shouldShowLongDescriptionButton: Bool {
        criterion.longDesc.isEmpty == false
    }
    var shouldShowRubricNotUsedForScoringMessage: Bool {
        criterion.ignoreForScoring
    }
    var description: String {
        criterion.desc
    }
    var shouldShowRubricRatings: Bool {
        !isFreeFormCommentsEnabled
    }
    var shouldShowAddFreeFormCommentButton: Bool {
        isFreeFormCommentsEnabled && !interactor.hasAssessmentUserComment(criterionId: criterion.id)
    }
    var addCommentButtonA11yID: String {
        "SpeedGrader.Rubric.\(criterion.id).addCommentButton"
    }
    var criteriaID: String {
        criterion.id
    }
    var ratingViewModels: [RubricRatingViewModel]
    var customRatingViewModel: RubricCustomRatingViewModel

    // MARK: - Private Properties

    private let criterion: Rubric
    private let isFreeFormCommentsEnabled: Bool
    private let router: Router
    private let interactor: RubricGradingInteractor

    init(
        criteria: Rubric,
        isFreeFormCommentsEnabled: Bool,
        interactor: RubricGradingInteractor,
        rubricComment: Binding<String>,
        rubricCommentID: Binding<String?>,
        router: Router = AppEnvironment.shared.router
    ) {
        self.criterion = criteria
        self.isFreeFormCommentsEnabled = isFreeFormCommentsEnabled
        self.interactor = interactor
        self._rubricComment = rubricComment
        self._rubricCommentID = rubricCommentID
        self.router = router
        ratingViewModels = (criteria.ratings ?? [])
            .reversed()
            .map {
                RubricRatingViewModel(
                    rating: $0,
                    criterionId: criteria.id,
                    interactor: interactor
                )
            }
        customRatingViewModel = RubricCustomRatingViewModel(rubric: criteria, interactor: interactor)

        interactor.assessments
            .map { assessments in
                assessments[criteria.id]?.comments
            }
            .assign(to: &$userComment)
    }

    // MARK: - User Actions

    func didTapAddCommentButton() {
        rubricComment = ""
        rubricCommentID = criterion.id
    }

    func didTapShowLongDescriptionButton() {
        let web = CoreWebViewController()
        web.title = criterion.desc
        web.webView.loadHTMLString(criterion.longDesc)
        web.addDoneButton(side: .right)
        router.show(web, from: controller, options: .modal(embedInNav: true))
    }
}
