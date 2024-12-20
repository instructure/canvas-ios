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

// https://canvas.instructure.com/doc/api/favorites.html#Favorite
public struct APIFavorite: Codable, Equatable {
    public let context_id: ID
    public let context_type: String
}

// https://canvas.instructure.com/doc/api/favorites.html#method.favorites.add_favorite_course
// https://canvas.instructure.com/doc/api/favorites.html#method.favorites.remove_favorite_course
// https://canvas.instructure.com/doc/api/favorites.html#method.favorites.add_favorite_groups
// https://canvas.instructure.com/doc/api/favorites.html#method.favorites.remove_favorite_groups
public struct MarkFavoriteRequest: APIRequestable {
    public typealias Response = APIFavorite

    public let context: Context
    public let markAsFavorite: Bool

    public var method: APIMethod { markAsFavorite ? .post : .delete }
    public var path: String {
        return "users/self/favorites/\(context.pathComponent)"
    }
}
