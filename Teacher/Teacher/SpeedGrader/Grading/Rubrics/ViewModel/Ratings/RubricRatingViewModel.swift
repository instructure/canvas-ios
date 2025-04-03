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

class RubricRatingViewModel: ObservableObject, Identifiable {
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
    let tooltip: String
    let value: String
    let accessibilityLabel: String

    // MARK: - Private Properties

    private let rating: RubricRating
    private let criterionId: String
    private let interactor: RubricGradingInteractor

    init(
        rating: RubricRating,
        criterionId: String,
        interactor: RubricGradingInteractor
    ) {
        self.rating = rating
        self.criterionId = criterionId
        self.interactor = interactor

        tooltip = rating.desc + (rating.longDesc.isEmpty ? "" : "\n" + rating.longDesc)
        value = "\(rating.points.formatted())"
        accessibilityLabel = rating.desc.isEmpty ? value : rating.desc
        interactor.assessments
            .map {
                let assessmentForRubric = $0[criterionId]
                let isThisRatingSelected = assessmentForRubric?.rating_id == rating.id
                return isThisRatingSelected
            }
            .removeDuplicates()
            .assign(to: &$isSelected)
    }
}
