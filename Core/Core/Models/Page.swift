//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public class Page: NSManagedObject {
    @NSManaged public var url: String
    @NSManaged public var lastUpdated: Date
    @NSManaged public var isFrontPage: Bool
    @NSManaged public var contextID: String
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var htmlURL: String
}

extension Page {
    @discardableResult
    static func save(_ item: APIPage, in context: NSManagedObjectContext) -> Page {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Page.id), item.page_id.value)
        let model: Page = context.fetch(predicate).first ?? context.insert()
        model.url = item.url
        model.lastUpdated = item.updated_at
        model.isFrontPage = item.front_page
        model.id = item.page_id.value
        model.title = item.title
        model.htmlURL = item.html_url

        return model
    }
}
