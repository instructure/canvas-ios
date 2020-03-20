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

public class GetPlannables: CollectionUseCase {
    public typealias Model = Plannable

    var userID: String?
    var startDate: Date
    var endDate: Date
    var contextCodes: [String] = []
    var filter: String = ""

    public let syncContext: NSManagedObjectContext?

    public init(userID: String? = nil, startDate: Date, endDate: Date, contextCodes: [String] = [], filter: String = "", syncContext: NSManagedObjectContext? = nil) {
        self.userID = userID
        self.startDate = startDate
        self.endDate = endDate
        self.contextCodes = contextCodes
        self.filter = filter
        self.syncContext = syncContext
    }

    public var cacheKey: String? {
        "get-plannables-\(userID ?? "")-\(startDate)-\(endDate)-\(filter)-\(contextCodes.joined(separator: ","))"
    }

    public var scope: Scope {
        var predicate = NSPredicate(format: "%@ <= %K AND %K < %@",
            startDate as NSDate, #keyPath(Plannable.date),
            #keyPath(Plannable.date), endDate as NSDate
        )
        if let userID = userID {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(Plannable.userID), equals: userID),
                predicate,
            ])
        }
        let order = [
            NSSortDescriptor(key: #keyPath(Plannable.date), ascending: true),
            NSSortDescriptor(key: #keyPath(Plannable.title), ascending: true),
        ]
        return Scope(predicate: predicate, order: order)
    }

    public var request: GetPlannablesRequest {
        return GetPlannablesRequest(userID: userID, startDate: startDate, endDate: endDate, contextCodes: contextCodes, filter: filter)
    }

    public func write(response: [APIPlannable]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        for p in response ?? [] {
            Plannable.save(p, in: client, userID: userID)
        }
    }
}
