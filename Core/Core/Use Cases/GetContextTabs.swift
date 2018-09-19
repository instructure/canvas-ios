//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class GetPaginatedContextTabs: PaginatedUseCase<GetTabsRequest, Tab> {
    let context: Context

    init(context: Context, api: API = URLSessionAPI(), database: Persistence, force: Bool = false) {
        self.context = context
        let request = GetTabsRequest(context: context)
        super.init(api: api, database: database, request: request)
    }

    override var predicate: NSPredicate {
        return .context(self.context)
    }

    override func predicate(forItem item: APITab) -> NSPredicate {
        return .id(item.id.value)
    }

    override func updateModel(_ model: Tab, using item: APITab, in client: Persistence) throws {
        if model.id.isEmpty { model.id = item.id.value }
        model.htmlUrl = item.html_url
        model.fullUrl = item.html_url
        model.label = item.label
        model.position = item.position
        model.contextID = self.context.canvasContextID
    }
}

public class GetContextTabs: OperationSet {
    public init(context: Context, api: API = URLSessionAPI(), database: Persistence, force: Bool = false) {
        let paginated = GetPaginatedContextTabs(context: context, api: api, database: database)
        let ttl = TTLOperation(key: "get-\(context.canvasContextID)-tabs", database: database, operation: paginated, force: force)
        super.init(operations: [ttl])
    }
}
