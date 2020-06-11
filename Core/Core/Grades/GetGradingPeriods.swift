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

import CoreData

public class GetGradingPeriods: CollectionUseCase {
    public typealias Model = GradingPeriod

    public let courseID: String

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var cacheKey: String? {
        return "get-gradingPeriods-\(courseID)"
    }

    public var scope: Scope {
        return .where(#keyPath(GradingPeriod.courseID), equals: courseID, orderBy: #keyPath(GradingPeriod.startDate))
    }

    public var request: GetGradingPeriodsRequest {
        return GetGradingPeriodsRequest(courseID: courseID)
    }

    public func write(response: [APIGradingPeriod]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let gradingPeriods = response else { return }

        for item in gradingPeriods {
            GradingPeriod.save(item, courseID: courseID, in: client)
        }
    }
}
