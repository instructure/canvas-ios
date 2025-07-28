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

class RedesignedRubricRatingViewModel: ObservableObject, Identifiable {

    // MARK: - Outputs

    @Published var isSelected: Bool = false {
        didSet {
            if isSelected {
                interactor.selectRating(
                    criterionId: criterionId,
                    points: rating.points,
                    ratingId: rating.id
                )
            } else {
                interactor.clearRating(criterionId: criterionId)
            }
        }
    }

    var value: String {
        rating.points.formatted()
    }

    var accessibilityLabel: String {
        rating.shortDescription.nilIfEmpty ?? value
    }

    var bubble: RubricRatingBubble {
        RubricRatingBubble(
            title: rating.shortDescription,
            subtitle: rating.longDescription
        )
    }

    // MARK: - Private Properties

    let rating: CDRubricRating
    let ratingPointsLowerBound: Double?
    private let criterionId: String
    private let interactor: RubricGradingInteractor

    init(
        rating: CDRubricRating,
        ratingPointsLowerBound: Double? = nil,
        criterionId: String,
        interactor: RubricGradingInteractor
    ) {
        self.rating = rating
        self.ratingPointsLowerBound = ratingPointsLowerBound
        self.criterionId = criterionId
        self.interactor = interactor

        interactor.assessments
            .map { [weak self] in
                let assessmentForRubric = $0[criterionId]
                guard let assessment = assessmentForRubric else { return false }

                if assessment.rating_id == rating.id {
                    return true
                }

                if let points = assessment.points {
                    return self?.matchPoints(points, strict: true) ?? false
                }

                return false
            }
            .removeDuplicates()
            .assign(to: &$isSelected)
    }

    func matchPoints(_ points: Double, strict: Bool = false) -> Bool {
        if let ratingPointsLowerBound, !strict {
            return points > ratingPointsLowerBound && points <= rating.points
        }
        return points == rating.points
    }
}
