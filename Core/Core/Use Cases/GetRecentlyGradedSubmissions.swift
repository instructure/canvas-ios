//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public struct GetRecentlyGradedSubmissions: CollectionUseCase {
    public typealias Model = Submission

    let userID: String

    public init (userID: String) {
        self.userID = userID
    }

    public var request: GetRecentlyGradedSubmissionsRequest {
        return GetRecentlyGradedSubmissionsRequest(userID: userID)
    }

    public var scope: Scope {
        return .all(orderBy: #keyPath(Submission.gradedAt), ascending: false, naturally: false)
    }

    public var cacheKey: String? = "recently-graded-submissions"
}
