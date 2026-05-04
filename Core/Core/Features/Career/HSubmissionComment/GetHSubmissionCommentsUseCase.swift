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
import CoreData

public struct GetHSubmissionCommentsUseCase: CollectionUseCase {

    // MARK: - Typealias

    public typealias Model = CDHSubmission
    public typealias Request = GetHSubmissionCommentsRequest
    public typealias Response = [GetHSubmissionCommentsResponse]

    // MARK: - Properties

    public var cacheKey: String? {
        return "Submission-\(assignmentId)"
    }

    private let userId: String
    private let assignmentId: String
    private let forAttempt: Int
    private let beforeCursor: String?

    public var request: GetHSubmissionCommentsRequest {
        .init(
            assignmentId: assignmentId,
            userId: userId,
            forAttempt: forAttempt,
            beforeCursor: beforeCursor
        )
    }

    // MARK: - Init

    public init(
        userId: String,
        assignmentId: String,
        forAttempt: Int,
        beforeCursor: String? = nil
    ) {
        self.userId = userId
        self.assignmentId = assignmentId
        self.forAttempt = forAttempt
        self.beforeCursor = beforeCursor
    }

    // MARK: - Functions

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        environment.api.exhaust(request, callback: completionHandler)
    }

    public func write(
        response: [GetHSubmissionCommentsResponse]?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let responses = response else { return }
        var pageID: String? = beforeCursor
        for pageResponse in responses {
            CDHSubmission.save(
                pageResponse,
                assignmentID: assignmentId,
                attempt: forAttempt,
                pageID: pageID,
                in: client
            )
            pageID = pageResponse.data?.submission?.commentsConnection?.pageInfo?.startCursor
        }
    }

    public var scope: Scope {
        let predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(format: "%K == %@", #keyPath(CDHSubmission.assignmentID), assignmentId),
                NSPredicate(format: "%K == %@", #keyPath(CDHSubmission.attempt), forAttempt as NSNumber)
            ]
        )
        return Scope(predicate: predicate, order: [])
    }
}
