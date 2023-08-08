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

public struct APIPage: Codable, Equatable {
    let url: String
    let updated_at: Date
    let front_page: Bool
    let page_id: ID
    let title: String
    let html_url: URL
    let published: Bool
    let body: String?
    let editing_roles: String?
}

#if DEBUG
extension APIPage {
    public static func make(
        body: String? = nil,
        editing_roles: String? = nil,
        front_page: Bool = false,
        html_url: URL = URL(string: "/courses/42/pages/answers-page")!,
        page_id: ID = ID("42"),
        published: Bool = false,
        title: String = "Answers Page",
        updated_at: Date = Date(),
        url: String = "answers-page"
	) -> APIPage {
        return APIPage(
            url: url,
            updated_at: updated_at,
            front_page: front_page,
            page_id: page_id,
            title: title,
            html_url: html_url,
            published: published,
            body: body,
            editing_roles: editing_roles
        )
    }
}
#endif

public struct GetPagesRequest: APIRequestable {
    public enum Include: String, CaseIterable {
        case body
    }

    public typealias Response = [APIPage]

    let context: Context

    public var path: String {
        return "\(context.pathComponent)/pages"
    }
    public var query: [APIQueryItem] {
        return [
            .value("sort", "title"),
            .include(Include.allCases.map { $0.rawValue }),
        ]
    }
}

// https://canvas.instructure.com/doc/api/pages.html#method.wiki_pages_api.create
public struct PostPageRequest: APIRequestable {
    public typealias Response = APIPage
    public typealias Body = PutPageRequest.Body

    let context: Context
    public let body: Body?

    public var method: APIMethod { .post }
    public var path: String { "\(context.pathComponent)/pages" }
}

// https://canvas.instructure.com/doc/api/pages.html#method.wiki_pages_api.update
public struct PutPageRequest: APIRequestable {
    public typealias Response = APIPage
    public struct Body: Codable {
        let wiki_page: WikiPage
    }
    public struct WikiPage: Codable {
        let title: String?
        let body: String?
        let editing_roles: String?
        let published: Bool?
        let front_page: Bool?
    }

    let context: Context
    let url: String
    public let body: Body?

    public var method: APIMethod { .put }
    public var path: String { "\(context.pathComponent)/pages/\(url)" }
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
        return "\(context.pathComponent)/pages/\(url)".addingPercentEncoding(withAllowedCharacters: .urlSafe) ?? ""
    }
}

// https://canvas.instructure.com/doc/api/pages.html#method.wiki_pages_api.destroy
public struct DeletePageRequest: APIRequestable {
    public typealias Response = APIPage

    let context: Context
    let url: String

    public let method = APIMethod.delete

    public var path: String {
        return "\(context.pathComponent)/pages/\(url)".addingPercentEncoding(withAllowedCharacters: .urlSafe) ?? ""
    }
}
