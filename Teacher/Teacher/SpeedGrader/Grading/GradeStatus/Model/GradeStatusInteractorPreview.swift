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

#if DEBUG

import Foundation
import Combine
import Core

class GradeStatusInteractorPreview: GradeStatusInteractor {
    let gradeStatuses: [GradeStatus]
    var refreshSubmission: ((String) -> Void)?

    var previewStatus: GradeStatus?
    var previewDaysLate: Int?
    var previewDueDate: Date?

    init(gradeStatuses: [GradeStatus] = []) {
        self.gradeStatuses = gradeStatuses
    }

    func fetchGradeStatuses() -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func updateSubmissionGradeStatus(
        submissionId: String,
        userId: String,
        customGradeStatusId: String?,
        latePolicyStatus: String?
    ) -> AnyPublisher<Void, Error> {
        Just(())
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func gradeStatusFor(
        customGradeStatusId: String?,
        latePolicyStatus: Core.LatePolicyStatus?,
        isExcused: Bool?,
        isLate: Bool?
    ) -> GradeStatus {
        .none
    }

    func observeGradeStatusChanges(submissionId: String, attempt: Int) -> AnyPublisher<(GradeStatus, daysLate: Int, dueDate: Date?), Never> {
        if let status = previewStatus, let daysLate = previewDaysLate {
            return Just((status, daysLate, previewDueDate)).eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    func updateLateDays(
        submissionId: String,
        userId: String,
        daysLate: Int
    ) -> AnyPublisher<Void, Error> {
        Just(())
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
#endif
