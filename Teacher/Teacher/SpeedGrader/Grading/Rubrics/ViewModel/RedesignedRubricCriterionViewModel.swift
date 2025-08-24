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

class RedesignedRubricCriterionViewModel: ObservableObject, Identifiable {

    // MARK: - Published

    @Published var userComment: String?
    @Published var userPoints: Double?
    @Published var userRatingId: String?
    @Published var userRatingBubble: RubricRatingBubble?

    // MARK: - Outputs

    let criterion: CDRubricCriterion
    let isFreeFormCommentsEnabled: Bool
    let hideRubricPoints: Bool
    let ratingViewModels: [RedesignedRubricRatingViewModel]

    var shouldShowRubricNotUsedForScoringMessage: Bool {
        criterion.ignoreForScoring
    }

    var isSaving: CurrentValueSubject<Bool, Never> {
        interactor.isSaving
    }

    var shouldShowRubricRatings: Bool {
        !isFreeFormCommentsEnabled
    }

    var title: String {
        criterion.shortDescription
    }

    var longDescription: String {
        criterion.longDescription
    }

    // MARK: - Private Properties

    private let interactor: RubricGradingInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(
        criterion: CDRubricCriterion,
        isFreeFormCommentsEnabled: Bool,
        hideRubricPoints: Bool,
        interactor: RubricGradingInteractor
    ) {
        self.criterion = criterion
        self.isFreeFormCommentsEnabled = isFreeFormCommentsEnabled
        self.hideRubricPoints = hideRubricPoints
        self.interactor = interactor

        let ratings = (criterion.ratings ?? [])
            .sorted(by: { $0.points < $1.points })

        if criterion.criterionUseRange {

            var ratingModels = [RedesignedRubricRatingViewModel]()
            var lowerPoints: Double = 0

            for rating in ratings {
                ratingModels.append(
                    RedesignedRubricRatingViewModel(
                        rating: rating,
                        ratingPointsLowerBound: lowerPoints,
                        criterionId: criterion.id,
                        interactor: interactor
                    )
                )
                lowerPoints = rating.points
            }

            ratingViewModels = ratingModels

        } else {

            ratingViewModels = ratings
                .map {
                    RedesignedRubricRatingViewModel(
                        rating: $0,
                        criterionId: criterion.id,
                        interactor: interactor
                    )
                }
        }

        interactor
            .assessments
            .sink { [weak self] assessments in
                self?.updateUserValues(assessments)
            }
            .store(in: &subscriptions)
    }

    func updateUserValues(_ assessments: APIRubricAssessmentMap) {
        let assessment = assessments[criterion.id]

        userComment = assessment?.comments
        userPoints = assessment?.points
        userRatingId = assessment?.rating_id?.nilIfEmpty

        let ratingModel = userRatingId
            .flatMap { ratingId in ratingViewModels.first { $0.rating.id == ratingId } }
        ?? userPoints
            .flatMap({ points in ratingViewModels.first { $0.matchPoints(points) } })

        userRatingBubble = ratingModel.flatMap({ $0.bubble })
    }

    // MARK: - User Actions

    func updateComment(_ newComment: String) {
        userComment = newComment
        interactor.updateComment(criterionId: criterion.id, comment: newComment)
    }

    func updateCustomRating(_ newPoints: Double) {
        interactor.selectRating(criterionId: criterion.id, points: newPoints, ratingId: APIRubricAssessment.customRatingId)
    }

    // MARK: - Rubric Score input

    var pointsPossibleText: String {
        String.format(pts: criterion.points)
    }

    var pointsPossibleAccessibilityText: String {
        String.format(points: criterion.points)
    }
}

struct RubricRatingBubble {
    let title: String
    let subtitle: String
}
