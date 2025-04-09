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

class RubricCriterionViewModel: ObservableObject, Identifiable {

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
        criterion.longDescription.isEmpty == false
    }
    var shouldShowRubricNotUsedForScoringMessage: Bool {
        criterion.ignoreForScoring
    }
    var description: String {
        criterion.shortDescription
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
    var criterionId: String {
        criterion.id
    }
    var ratingViewModels: [RubricRatingViewModel]
    var customRatingViewModel: RubricCustomRatingViewModel

    // MARK: - Private Properties

    private let criterion: CDRubricCriterion
    private let isFreeFormCommentsEnabled: Bool
    private let router: Router
    private let interactor: RubricGradingInteractor

    init(
        criterion: CDRubricCriterion,
        isFreeFormCommentsEnabled: Bool,
        interactor: RubricGradingInteractor,
        rubricComment: Binding<String>,
        rubricCommentID: Binding<String?>,
        router: Router = AppEnvironment.shared.router
    ) {
        self.criterion = criterion
        self.isFreeFormCommentsEnabled = isFreeFormCommentsEnabled
        self.interactor = interactor
        self._rubricComment = rubricComment
        self._rubricCommentID = rubricCommentID
        self.router = router
        ratingViewModels = (criterion.ratings ?? [])
            .reversed()
            .map {
                RubricRatingViewModel(
                    rating: $0,
                    criterionId: criterion.id,
                    interactor: interactor
                )
            }
        customRatingViewModel = RubricCustomRatingViewModel(criterion: criterion, interactor: interactor)

        interactor.assessments
            .map { assessments in
                assessments[criterion.id]?.comments
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
        web.title = criterion.shortDescription
        web.webView.loadHTMLString(criterion.longDescription)
        web.addDoneButton(side: .right)
        router.show(web, from: controller, options: .modal(embedInNav: true))
    }
}
