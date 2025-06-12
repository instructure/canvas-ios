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

protocol GradeStatusesInteractor {
    func fetchCustomGradeStatuses(courseID: String) -> AnyPublisher<[GradeStatus], Error>
    func updateSubmissionGradeStatus(
        submissionId: String,
        customGradeStatusId: String?,
        latePolicyStatus: String?
    ) -> AnyPublisher<Void, Error>
}

final class GradeStatusesInteractorLive: GradeStatusesInteractor {
    private let api: API

    init(api: API) {
        self.api = api
    }

    func fetchCustomGradeStatuses(
        courseID: String
    ) -> AnyPublisher<[GradeStatus], Error> {
        let request = GetGradeStatusesRequest(courseID: courseID)
        return api.makeRequest(request)
            .map { $0.body }
            .map { response in
                let defaults = response.defaultGradeStatuses.map { GradeStatus(defaultName: $0) }
                let custom = response.customGradeStatuses.map { GradeStatus(custom: $0) }
                return defaults + custom
            }
            .eraseToAnyPublisher()
    }

    func updateSubmissionGradeStatus(
        submissionId: String,
        customGradeStatusId: String?,
        latePolicyStatus: String?
    ) -> AnyPublisher<Void, Error> {
        let request = UpdateSubmissionGradeStatusRequest(
            submissionId: submissionId,
            customGradeStatusId: customGradeStatusId,
            latePolicyStatus: latePolicyStatus
        )
        return api.makeRequest(request)
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
