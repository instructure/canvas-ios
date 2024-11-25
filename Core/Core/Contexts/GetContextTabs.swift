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
import Foundation

public class GetContextTabs: CollectionUseCase {
    public typealias Model = Tab
    public let context: Context

    public init(context: Context) {
        self.context = context
    }

    public var cacheKey: String? {
        return "get-\(context.canvasContextID)-tabs"
    }

    public var request: GetTabsRequest {
        if AppEnvironment.shared.k5.isK5Enabled {
            return GetTabsRequest(context: context, include: [.course_subject_tabs])
        }
        return GetTabsRequest(context: context)
    }

    public var scope: Scope {
        let sort = NSSortDescriptor(key: #keyPath(Tab.position), ascending: true)
        let pred = NSPredicate(format: "%K == %@", #keyPath(Tab.contextRaw), context.canvasContextID)
        return Scope(predicate: pred, order: [sort])
    }

    public func write(response: [APITab]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }

        for item in response {
            var predicate = NSPredicate(format: "%K == %@", #keyPath(Tab.htmlURL), item.html_url as CVarArg)
            if AppEnvironment.shared.k5.isK5Enabled {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, NSPredicate(format: "%K == %@", #keyPath(Tab.label), item.label)])
            }
            let model: Tab = client.fetch(predicate).first ?? client.insert()
            model.save(item, in: client, context: context)
        }
    }
}
