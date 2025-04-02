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
                didSelectRating()
            } else {
                didClearRating()
            }
        }
    }
    let tooltip: String
    let value: String
    let accessibilityLabel: String

    // MARK: - Private Properties

    private var assessment: APIRubricAssessment? {
        assessmentsPublisher.value[rubricId]
    }
    private let rating: RubricRating
    private let rubricId: String
    private let assessmentsPublisher: CurrentValueSubject<APIRubricAssessmentMap, Never>

    init(
        rating: RubricRating,
        rubricId: String,
        assessments: CurrentValueSubject<APIRubricAssessmentMap, Never>
    ) {
        self.rating = rating
        self.rubricId = rubricId
        self.assessmentsPublisher = assessments

        tooltip = rating.desc + (rating.longDesc.isEmpty ? "" : "\n" + rating.longDesc)
        value = "\(rating.points.formatted())"
        accessibilityLabel = rating.desc.isEmpty ? value : rating.desc
        assessments
            .map {
                let assessmentForRubric = $0[rubricId]
                let isThisRatingSelected = assessmentForRubric?.rating_id == rating.id
                return isThisRatingSelected
            }
            .removeDuplicates()
            .assign(to: &$isSelected)
    }

    private func didSelectRating() {
        var assessments = assessmentsPublisher.value
        assessments[rubricId] = APIRubricAssessment(
            comments: assessment?.comments,
            points: rating.points,
            rating_id: rating.id
        )
        assessmentsPublisher.send(assessments)
    }

    private func didClearRating() {
        var assessments = assessmentsPublisher.value
        assessments[rubricId] = APIRubricAssessment(comments: assessment?.comments)
        assessmentsPublisher.send(assessments)
    }
}
