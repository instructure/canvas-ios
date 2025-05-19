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

public struct GetSubmissionCommentsUseCase: APIUseCase {

    // MARK: - Typealias

    public typealias Model = CDSubmission
    public typealias Request = GetSubmissionCommentsRequest

    // MARK: - Properties

    public var cacheKey: String? {
        return "Submission-\(assignmentId)-\(userId)-Comments"
    }

    private let userId: String
    private let assignmentId: String

    public var request: GetSubmissionCommentsRequest {
        .init(
            assignmentId: assignmentId,
            userId: userId
        )
    }

    // MARK: - Init

    public init(
        userId: String,
        assignmentId: String
    ) {
        self.userId = userId
        self.assignmentId = assignmentId
    }

    // MARK: - Functions

    public func write(
        response: GetSubmissionCommentsResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response else {
            return
        }
        CDSubmission.save(
            response,
            assignmentID: assignmentId,
            in: client
        )
    }

    public var scope: Scope {
        return .where(#keyPath(CDSubmission.assignmentID), equals: assignmentId)
    }
}
