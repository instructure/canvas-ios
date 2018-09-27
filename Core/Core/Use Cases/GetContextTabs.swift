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

class GetPaginatedContextTabs: PaginatedUseCase<GetTabsRequest, Tab> {
    let context: Context

    init(context: Context, env: AppEnvironment, force: Bool = false) {
        self.context = context
        let request = GetTabsRequest(context: context)
        super.init(api: env.api, database: env.database, request: request)
    }

    override var predicate: NSPredicate {
        return .context(self.context)
    }

    override func predicate(forItem item: APITab) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Tab.fullUrl), item.full_url)
    }

    override func updateModel(_ model: Tab, using item: APITab, in client: Persistence) throws {
        if model.fullUrl.isEmpty { model.fullUrl = item.full_url }
        model.htmlUrl = item.html_url
        model.label = item.label
        model.position = item.position
        model.contextID = self.context.canvasContextID
    }
}

public class GetContextTabs: OperationSet {
    public init(context: Context, env: AppEnvironment, force: Bool = false) {
        let paginated = GetPaginatedContextTabs(context: context, env: env)
        let ttl = TTLOperation(key: "get-\(context.canvasContextID)-tabs", database: env.database, operation: paginated, force: force)
        super.init(operations: [ttl])
    }
}
