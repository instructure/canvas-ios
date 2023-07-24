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

public struct GetBookmarks: CollectionUseCase {
    public typealias Model = BookmarkItem

    public var cacheKey: String? { "get-user-self-bookmarks" }
    public var request: GetBookmarksRequest { GetBookmarksRequest() }
    public var scope: Scope {
        Scope(predicate: .all,
              order: [NSSortDescriptor(key: #keyPath(BookmarkItem.position), ascending: true)])
    }

    public init () {}

    public func write(response: [APIBookmark]?,
                      urlResponse: URLResponse?,
                      to client: NSManagedObjectContext) {
        guard let bookmarks = response else { return }

        for item in bookmarks {
            BookmarkItem.save(item, in: client)
        }
    }
}
