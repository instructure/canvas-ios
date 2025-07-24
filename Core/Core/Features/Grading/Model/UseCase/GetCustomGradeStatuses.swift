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

import CoreData
import Foundation

public struct GetCustomGradeStatuses: CollectionUseCase {
    public typealias Model = CDCustomGradeStatus

    public let courseID: String

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var cacheKey: String? {
        "\(Context(.course, id: courseID).pathComponent)/custom-grade-statuses"
    }

    public var request: GetCustomGradeStatusesRequest {
        GetCustomGradeStatusesRequest(courseID: courseID)
    }

    public var scope: Scope {
        .where(#keyPath(CDCustomGradeStatus.courseID), equals: courseID)
    }

    public func write(response: GetCustomGradeStatusesRequest.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else { return }

        response.data.course.customGradeStatusesConnection.nodes.forEach { customStatus in
            CDCustomGradeStatus.save(customStatus, courseID: courseID, in: client)
        }
    }
}
