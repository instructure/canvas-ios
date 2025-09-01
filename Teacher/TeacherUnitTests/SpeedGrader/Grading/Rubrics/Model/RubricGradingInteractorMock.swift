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

    private let assessmentsSubject = CurrentValueSubject<APIRubricAssessmentMap, Never>([:])

    init() {
        self.assessments = assessmentsSubject.eraseToAnyPublisher()
    }

    func clearRating(criterionId: String) {}
    func selectRating(criterionId: String, points: Double, ratingId: String) {}
    func hasAssessmentUserComment(criterionId: String) -> Bool { false }
    func updateComment(criterionId: String, comment: String?) {}
}
