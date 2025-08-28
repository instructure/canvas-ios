//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import CoreData
import Foundation

public struct GetSubmissionSummary: APIUseCase {
    public typealias Model = SubmissionSummary

    let context: Context
    let assignmentID: String

    public init(context: Context, assignmentID: String) {
        self.context = context
        self.assignmentID = assignmentID
    }

    public var cacheKey: String? { "\(context.pathComponent)/assignments/\(assignmentID)/submission_summary" }
    public var request: GetSubmissionSummaryRequest {
        GetSubmissionSummaryRequest(context: context, assignmentID: assignmentID)
    }
    public var scope: Scope {
        .where(#keyPath(SubmissionSummary.assignmentID), equals: assignmentID)
    }

    public func write(response: APISubmissionSummary?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        SubmissionSummary.save(item, assignmentID: assignmentID, in: client)
    }
}
