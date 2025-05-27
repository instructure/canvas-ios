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

final public class GetSubmissionScoresUseCase: APIUseCase {

    // MARK: - Typealias

    public typealias Model = CDScoresAssignmentGroup
    public typealias Request = GetSubmissionScoresRequest

    // MARK: - Properties

    public var cacheKey: String? {
        return "Submission-Scores-\(enrollmentId)"
    }

    private let userId: String
    private let enrollmentId: String

    public var request: GetSubmissionScoresRequest {
        .init(userId: userId, enrollmentId: enrollmentId)
    }

    // MARK: - Init

    public init(userId: String, enrollmentId: String) {
        self.userId = userId
        self.enrollmentId = enrollmentId
    }

    // MARK: - Functions
    public func write(
        response: GetSubmissionScoresResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response else {
            return
        }
        CDSubmissionScores.save(
            response,
            enrollmentId: enrollmentId,
            in: client
        )
    }

    public var scope: Scope {
        return .where(#keyPath(CDSubmissionScores.enrollmentID), equals: enrollmentId)
    }
}
