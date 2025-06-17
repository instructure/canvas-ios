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

final public class GetHSubmissionScoresUseCase: APIUseCase {

    // MARK: - Typealias

    public typealias Model = CDHScoresAssignmentGroup
    public typealias Request = GetHSubmissionScoresRequest

    // MARK: - Properties

    public var cacheKey: String? {
        return "Submission-Scores-\(enrollmentId)"
    }

    let userId: String
    let enrollmentId: String

    public var request: GetHSubmissionScoresRequest {
        .init(userId: userId, enrollmentId: enrollmentId)
    }

    // MARK: - Init

    public init(userId: String, enrollmentId: String) {
        self.userId = userId
        self.enrollmentId = enrollmentId
    }

    // MARK: - Functions
    public func write(
        response: GetHSubmissionScoresResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response else {
            return
        }
        CDHSubmissionScores.save(
            response,
            enrollmentId: enrollmentId,
            in: client
        )
    }

    public var scope: Scope {
        return .where(#keyPath(CDHSubmissionScores.enrollmentID), equals: enrollmentId)
    }
}
