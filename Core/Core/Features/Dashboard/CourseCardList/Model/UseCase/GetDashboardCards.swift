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

public class GetDashboardCards: CollectionUseCase {
    public typealias Model = DashboardCard

    public var cacheKey: String? { "get-dashboard-cards" }
    public var request: GetDashboardCardsRequest { GetDashboardCardsRequest() }
    public var scope: Scope

    public init(showOnlyTeacherEnrollment: Bool = false) {
        if showOnlyTeacherEnrollment {
            let order = [NSSortDescriptor(key: #keyPath(DashboardCard.position), ascending: true)]
            let predicate = NSPredicate(format: "enrollmentType CONTAINS[cd] %@ OR enrollmentType CONTAINS[cd] %@", "teacher", "ta")
            scope = Scope(predicate: predicate, order: order)
        } else {
            scope = Scope.all(orderBy: #keyPath(DashboardCard.position))
        }
    }

    public func reset(context _: NSManagedObjectContext) {
        // We don't want the default implementation to delete everything, we'll delete what's no longer needed in the write method
    }

    public func write(response: [APIDashboardCard]?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        let idsToKeep = (response ?? []).map { $0.id.value }
        let objectsManagedByUseCase: [Model] = client.fetch(scope: scope)
        let objectsToDelete = objectsManagedByUseCase.filter { !idsToKeep.contains($0.id) }
        client.delete(objectsToDelete)

        response?.enumerated().forEach {
            Model.save($0.element, position: $0.offset, in: client)
        }
    }
}
