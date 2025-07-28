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

    // MARK: - Inputs

    var controller = WeakViewController()

    @Published var userComment: String?
    @Published var userPoints: Double?
    @Published var userRatingId: String?
    @Published var userRatingBubble: RubricRatingBubble?

    // MARK: - Outputs

    var shouldShowRubricNotUsedForScoringMessage: Bool {
        criterion.ignoreForScoring
    }

    var description: String {
        criterion.shortDescription
    }

    var longDescription: String {
        criterion.longDescription
    }

    var isSaving: CurrentValueSubject<Bool, Never> {
        interactor.isSaving
    }

    var shouldShowRubricRatings: Bool {
        !isFreeFormCommentsEnabled
    }

    var criterionId: String {
        criterion.id
    }

    var criterionPoints: Double {
        criterion.points
    }

    var ratingViewModels: [RedesignedRubricRatingViewModel]

    // MARK: - Private Properties

    let isFreeFormCommentsEnabled: Bool
    let hideRubricPoints: Bool

    private let criterion: CDRubricCriterion
    private let router: Router
    private let interactor: RubricGradingInteractor

    private var subscriptions = Set<AnyCancellable>()

    init(
        criterion: CDRubricCriterion,
        isFreeFormCommentsEnabled: Bool,
        hideRubricPoints: Bool,
        interactor: RubricGradingInteractor,
        router: Router = AppEnvironment.shared.router
    ) {
        self.criterion = criterion
        self.isFreeFormCommentsEnabled = isFreeFormCommentsEnabled
        self.hideRubricPoints = hideRubricPoints
        self.interactor = interactor
        self.router = router

        let ratings = (criterion.ratings ?? []).sorted(by: { $0.points < $1.points })

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
        interactor.updateComment(criterionId: criterionId, comment: newComment)
    }

    func updateCustomRating(_ newPoints: Double) {
        interactor.selectRating(criterionId: criterion.id, points: newPoints, ratingId: APIRubricAssessment.customRatingId)
    }

    var pointsPossibleText: String {
        let format = String(localized: "g_pts", bundle: .core)
        return String.localizedStringWithFormat(format, criterion.points)
    }
}

struct RubricRatingBubble {
    let title: String
    let subtitle: String
}
