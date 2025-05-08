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

public struct GetPage: UseCase {
    public typealias Model = Page

    public let context: Context
    public var url: String

    var isFrontPage: Bool { url == "front_page" }

    public init(context: Context, url: String) {
        self.context = context
        self.url = url.removingPercentEncoding ?? ""
    }

    public var cacheKey: String? {
        return "get-\(context.canvasContextID)-page-\(url)"
    }

    public func reset(context: NSManagedObjectContext) {
        guard isFrontPage else { return }
        // Unset previous flags to ensure we get the new front page
        let frontPages: [Page] = context.fetch(NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(Page.contextID), equals: self.context.canvasContextID),
            NSPredicate(format: "%K == true", #keyPath(Page.isFrontPage))
        ]))
        for front in frontPages {
            front.isFrontPage = false
        }
    }

    public var scope: Scope {
        if isFrontPage {
            let contextID = NSPredicate(format: "%K == %@", #keyPath(Page.contextID), context.canvasContextID)
            let isFrontPage = NSPredicate(format: "%K == true", #keyPath(Page.isFrontPage))
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [contextID, isFrontPage])
            let order = NSSortDescriptor(key: #keyPath(Page.title), ascending: true)
            return Scope(predicate: predicate, order: [order])
        }
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(Page.contextID), context.canvasContextID, #keyPath(Page.url), url)
        return Scope(predicate: predicate, order: [])
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APIPage?, URLResponse?, Error?) -> Void) {
        if isFrontPage {
            environment.api.makeRequest(GetFrontPageRequest(context: context), callback: completionHandler)
        } else {
            environment.api.makeRequest(GetPageRequest(context: context, url: url), callback: completionHandler)
        }
    }

    public func write(response: APIPage?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else { return }
        // If a page is renamed its url changes as well. When we request the old url the API will return
        // a page object with the new url and the CoreData predicate won't find the entity. To work around this
        // we save the page object with the originally requested url.
        let modifiedResponse = APIPage(url: url,
                                       updated_at: response.updated_at,
                                       front_page: response.front_page,
                                       page_id: response.page_id,
                                       title: response.title,
                                       html_url: response.html_url,
                                       published: response.published,
                                       body: response.body,
                                       editing_roles: response.editing_roles)
        Page.save(modifiedResponse, in: client)
    }
}

struct UpdatePage: UseCase {
    typealias Model = Page

    let context: Context
    let url: String?
    let body: PutPageRequest.Body

    init(
        context: Context,
        url: String?,
        title: String? = nil,
        body: String? = nil,
        editing_roles: String? = nil,
        published: Bool? = nil,
        front_page: Bool? = nil
    ) {
        self.context = context
        self.url = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        self.body = PutPageRequest.Body(wiki_page: PutPageRequest.WikiPage(
            title: title, body: body, editing_roles: editing_roles, published: published, front_page: front_page
        ))
    }

    let cacheKey: String? = nil

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APIPage?, URLResponse?, Error?) -> Void) {
        if let url = url {
            environment.api.makeRequest(PutPageRequest(context: context, url: url, body: body), callback: completionHandler)
        } else {
            environment.api.makeRequest(PostPageRequest(context: context, body: body), callback: completionHandler)
        }
    }
}
