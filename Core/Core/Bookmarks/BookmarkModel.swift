//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public final class BookmarkModel: NSManagedObject, WriteableModel {
    public typealias JSON = APIBookmark
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var url: String?
    @NSManaged public var position: Int

    public static func save(_ item: APIBookmark, in context: NSManagedObjectContext) -> BookmarkModel {
        let model: BookmarkModel = context.first(where: #keyPath(BookmarkModel.id), equals: Int64(item.id.value)) ?? context.insert()
        model.name = item.name
        model.url = item.url
        model.position = item.position ?? 0
        return model
    }
}

