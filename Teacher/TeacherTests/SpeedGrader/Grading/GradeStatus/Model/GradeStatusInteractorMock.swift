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
import Foundation

final class GradeStatusInteractorMock: GradeStatusInteractor {
    var gradeStatuses: [GradeStatus] = []
    var refreshSubmission: ((_ userId: String) -> Void)?

    var fetchGradeStatusesCalled = false
    func fetchGradeStatuses() -> AnyPublisher<Void, Error> {
        fetchGradeStatusesCalled = true
        return Publishers.typedJust()
    }

    var updateSubmissionGradeStatusCalled = false
    var shouldFailUpdateSubmissionGradeStatus = false
    func updateSubmissionGradeStatus(
        submissionId: String,
        userId: String,
        customGradeStatusId: String?,
        latePolicyStatus: String?
    ) -> AnyPublisher<Void, Error> {
        updateSubmissionGradeStatusCalled = true
        if shouldFailUpdateSubmissionGradeStatus {
            return Fail(error: NSError.internalError()).eraseToAnyPublisher()
        }
        return Publishers.typedJust()
    }

    func gradeStatusFor(
        customGradeStatusId: String?,
        latePolicyStatus: LatePolicyStatus?,
        isExcused: Bool?,
        isLate: Bool?
    ) -> GradeStatus {
        return gradeStatuses.first ?? .none
    }

    var observeGradeStatusChangesCalled = false
    var mockDaysLate = 0
    var mockDueDate: Date?
    func observeGradeStatusChanges(
        submissionId: String,
        attempt: Int
    ) -> AnyPublisher<(GradeStatus, daysLate: Int, dueDate: Date?), Never> {
        observeGradeStatusChangesCalled = true
        if let status = gradeStatuses.first {
            return Just((status, mockDaysLate, mockDueDate)).eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    var updateLateDaysCalled = false
    var updateLateDaysParams: (submissionId: String, userId: String, daysLate: Int)?
    func updateLateDays(
        submissionId: String,
        userId: String,
        daysLate: Int
    ) -> AnyPublisher<Void, Error> {
        updateLateDaysCalled = true
        updateLateDaysParams = (submissionId, userId, daysLate)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
