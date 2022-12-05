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

// https://canvas.instructure.com/doc/api/tabs.html#method.tabs.update
public struct CreateDSTabsRequest: APIRequestable {
    public typealias Response = APINoContent

    public let method = APIMethod.put
    public let path: String
    public let body: Body?

    public init(courseID: String, tabId: String, body: Body) {
        self.path = "courses/\(courseID)/tabs/\(tabId)"
        self.body = body
    }
}

extension CreateDSTabsRequest {
    public struct RequestedTabs: Encodable {
        let tab_id: String
        let body: String

        public init(tabId: String, body: String) {
            self.tab_id = tabId
            self.body = body
        }
    }

    public struct Body: Encodable {
        let requestedTab: RequestedTabs
    }
}
