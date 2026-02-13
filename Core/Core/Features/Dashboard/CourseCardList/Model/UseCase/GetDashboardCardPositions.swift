//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

public class GetDashboardCardPositions: CollectionUseCase {
    public typealias Model = CDDashboardCardPosition

    public var cacheKey: String? { "get-dashboard-card-positions" }
    public var request: GetDashboardCardPositionsRequest { .init() }
    public var scope: Scope {
        .all(orderBy: \CDDashboardCardPosition.position)
    }

    public init() { }

    public func write(response: APIDashboardCardPositions?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else { return }

        for (courseCode, position) in response.dashboard_positions {
            CDDashboardCardPosition.save(courseCode: courseCode, position: position, in: client)
        }
    }
}
