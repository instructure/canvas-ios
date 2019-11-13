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
public struct GetPagesRequest: APIRequestable {
    public typealias Response = [APIPage]

    let context: Context

    public var path: String {
        return "\(context.pathComponent)/pages"
    }
    public var query: [APIQueryItem] {
        return [.value("sort", "title")]
    }
}

public struct GetFrontPageRequest: APIRequestable {
    public typealias Response = APIPage

    let context: Context

    public var path: String {
        return "\(context.pathComponent)/front_page"
    }
}

// https://canvas.instructure.com/doc/api/pages.html#method.wiki_pages_api.show
public struct GetPageRequest: APIRequestable {
    public typealias Response = APIPage

    let context: Context
    let url: String

    public var path: String {
        return "\(context.pathComponent)/pages/\(url)"
    }
}

// https://canvas.instructure.com/doc/api/pages.html#method.wiki_pages_api.destroy
public struct DeletePageRequest: APIRequestable {
    public typealias Response = APIPage

    let context: Context
    let url: String

    public let method = APIMethod.delete

    public var path: String {
        return "\(context.pathComponent)/pages/\(url)"
    }
}
