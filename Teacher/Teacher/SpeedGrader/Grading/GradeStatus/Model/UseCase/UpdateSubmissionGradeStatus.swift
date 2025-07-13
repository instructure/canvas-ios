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
import CoreData
import Core

/// UseCase for updating a submission's grade status via GraphQL,
/// then fetching the updated submission via REST API to be persisted in CoreData.
public final class UpdateSubmissionGradeStatus: UseCase {
    public typealias Model = Submission
    public typealias Response = APISubmission

    public let cacheKey: String? = nil
    public let scope: Scope

    private let updateRequest: UpdateSubmissionGradeStatusRequest
    private let refreshSubmissionRequest: GetSubmissionRequest
    private var subscriptions = Set<AnyCancellable>()

    public init(
        courseId: String,
        submissionId: String,
        assignmentId: String,
        userId: String,
        customGradeStatusId: String?,
        latePolicyStatus: String?
    ) {
        updateRequest = UpdateSubmissionGradeStatusRequest(
            submissionId: submissionId,
            customGradeStatusId: customGradeStatusId,
            latePolicyStatus: latePolicyStatus
        )
        refreshSubmissionRequest = GetSubmissionRequest(
            context: .course(courseId),
            assignmentID: assignmentId,
            userID: userId
        )
        scope = Scope(
            predicate: NSPredicate(
                format: "%K == %@ AND %K == %@",
                #keyPath(Submission.assignmentID), assignmentId,
                #keyPath(Submission.userID), userId
            ),
            orderBy: #keyPath(Submission.attempt),
            ascending: false
        )
    }

    public func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping (APISubmission?, URLResponse?, Error?) -> Void
    ) {
        environment.api.makeRequest(updateRequest)
            .flatMap { [refreshSubmissionRequest] _ in
                environment.api.makeRequest(refreshSubmissionRequest)
            }
            .sinkFailureOrValue { error in
                completionHandler(nil, nil, error)
            } receiveValue: { (submission, _) in
                completionHandler(submission, nil, nil)
            }
            .store(in: &subscriptions)
    }
}
