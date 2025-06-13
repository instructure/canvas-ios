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

import Foundation
import Combine
import Core

protocol GradeStatusInteractor {
    var gradeStatuses: [GradeStatus] { get }

    /// When we update a submission's grade status, we want to refresh the submission in the DB.
    var refreshSubmission: ((_ userId: String) -> Void)? { get set }

    func fetchGradeStatuses() -> AnyPublisher<Void, Error>

    func updateSubmissionGradeStatus(
        submissionId: String,
        userId: String,
        customGradeStatusId: String?,
        latePolicyStatus: String?
    ) -> AnyPublisher<Void, Error>
}

final class GradeStatusInteractorLive: GradeStatusInteractor {
    var refreshSubmission: ((_ userId: String) -> Void)?
    private(set) var gradeStatuses: [GradeStatus] = []

    private let api: API
    private let courseId: String

    init(courseId: String, api: API) {
        self.courseId = courseId
        self.api = api
    }

    func fetchGradeStatuses() -> AnyPublisher<Void, Error> {
        let request = GetGradeStatusesRequest(courseID: courseId)
        return api.makeRequest(request)
            .map { $0.body }
            .map { [weak self] response in
                let defaults = response.defaultGradeStatuses.map { GradeStatus(defaultName: $0) }
                let custom = response.customGradeStatuses.map { GradeStatus(custom: $0) }
                self?.gradeStatuses = defaults + custom
            }
            .eraseToAnyPublisher()
    }

    func updateSubmissionGradeStatus(
        submissionId: String,
        userId: String,
        customGradeStatusId: String?,
        latePolicyStatus: String?
    ) -> AnyPublisher<Void, Error> {
        let request = UpdateSubmissionGradeStatusRequest(
            submissionId: submissionId,
            customGradeStatusId: customGradeStatusId,
            latePolicyStatus: latePolicyStatus
        )
        return api.makeRequest(request)
            .map { [weak self] _ in
                self?.refreshSubmission?(userId)
                return ()
            }
            .eraseToAnyPublisher()
    }
}
