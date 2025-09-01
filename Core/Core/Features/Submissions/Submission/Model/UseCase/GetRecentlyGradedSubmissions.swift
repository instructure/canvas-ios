//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public struct GetRecentlyGradedSubmissions: CollectionUseCase {
    public typealias Model = SubmissionList

    public let cacheKey: String? = "recently-graded-submissions"
    public let request: GetRecentlyGradedSubmissionsRequest
    public let scope: Scope

    public init (userID: String) {
        request = GetRecentlyGradedSubmissionsRequest(userID: userID)
        scope = Scope.where(#keyPath(SubmissionList.id), equals: "recently-graded")
    }

    public func write(response: [APISubmission]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        let list: SubmissionList = client.fetch(scope: scope).first ?? client.insert()
        list.id = "recently-graded"
        list.submissions.append(contentsOf: Submission.save(response ?? [], in: client))
    }
}
