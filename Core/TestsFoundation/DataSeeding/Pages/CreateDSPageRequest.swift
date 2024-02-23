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

import Core

// https://canvas.instructure.com/doc/api/pages.html#method.wiki_pages_api.create
public struct CreateDSPageRequest: APIRequestable {
    public typealias Response = DSPage

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body, courseId: String) {
        self.body = body
        self.path = "courses/\(courseId)/pages"
    }
}

extension CreateDSPageRequest {
    public struct RequestedDSPage: Encodable {
        let title: String
        let body: String?
        let published: Bool
        let front_page: Bool

        public init(title: String = "Page Title", body: String? = nil, front_page: Bool = false, published: Bool = false) {
            self.title = title
            self.body = body
            self.published = published
            self.front_page = front_page
        }
    }

    public struct Body: Encodable {
        let wiki_page: RequestedDSPage
    }
}
