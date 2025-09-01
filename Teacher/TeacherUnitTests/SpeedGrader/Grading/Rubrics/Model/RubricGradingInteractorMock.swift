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
@testable import Core
@testable import Teacher

class RubricGradingInteractorMock: RubricGradingInteractor {
    let assessments: AnyPublisher<APIRubricAssessmentMap, Never>
    let isSaving = CurrentValueSubject<Bool, Never>(false)
    let showSaveError = PassthroughSubject<Error, Never>()
    let totalRubricScore = CurrentValueSubject<Double, Never>(0)
    let isRubricScoreAvailable = CurrentValueSubject<Bool, Never>(false)

    let assessmentsSubject = CurrentValueSubject<APIRubricAssessmentMap, Never>([:])

    init() {
        self.assessments = assessmentsSubject.eraseToAnyPublisher()
    }

    private(set) var clearedCriterion: String?
    func clearRating(criterionId: String) {
        self.clearedCriterion = criterionId
    }

    private(set) var selectedRating: SelectedRating?
    func selectRating(criterionId: String, points: Double, ratingId: String) {
        selectedRating = SelectedRating(criterionId: criterionId, points: points, ratingId: ratingId)
    }

    var assessmentUserCommentMockMap: [String: Bool] = [:]
    func hasAssessmentUserComment(criterionId: String) -> Bool { assessmentUserCommentMockMap[criterionId] ?? false }

    private(set) var updatedComment: UpdatedComment?
    func updateComment(criterionId: String, comment: String?) {
        updatedComment = UpdatedComment(criterionId: criterionId, comment: comment)
    }

    struct UpdatedComment {
        let criterionId: String
        let comment: String?
    }

    struct SelectedRating {
        let criterionId: String
        let points: Double
        let ratingId: String
    }
}
