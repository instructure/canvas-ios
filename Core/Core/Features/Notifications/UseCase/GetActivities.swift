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

public class GetActivities: CollectionUseCase {

    public typealias Model = Activity
    public typealias Response = Request.Response

    private let context: Context?
    public init(context: Context? = nil) {
        self.context = context
    }

    public var cacheKey: String? {
        return "get-activities"
    }

    public var scope: Scope {
        let pred = NSPredicate(format: "%K != %@ && %K != %@ && %K != %@ && %K != %@",
                               #keyPath(Activity.typeRaw), ActivityType.conference.rawValue,
                               #keyPath(Activity.typeRaw), ActivityType.collaboration.rawValue,
                               #keyPath(Activity.typeRaw), ActivityType.assessmentRequest.rawValue,
                               #keyPath(Activity.typeRaw), ActivityType.conversation.rawValue)
        var contextFilter: NSPredicate {
            guard let contextID = context?.canvasContextID  else {
                return NSPredicate(value: true)
            }
            return NSPredicate(format: "%K == %@", #keyPath(Activity.canvasContextIDRaw), contextID)
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred, contextFilter])
        let order = [ NSSortDescriptor(key: #keyPath(Activity.updatedAt), ascending: false) ]
        return Scope(predicate: predicate, order: order, sectionNameKeyPath: nil)
    }

    public var request: GetActivitiesRequest {
        return GetActivitiesRequest()
    }
}
