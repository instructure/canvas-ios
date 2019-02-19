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

public class RequestUseCase<Request>: OperationSet where Request: APIRequestable {
    let api: API
    let database: Persistence
    let request: Request
    var next: GetNextRequest<Request.Response>? {
        return fetch.next
    }

    lazy var fetch: APIOperation = {
        return APIOperation(api: self.api, request: self.request)
    }()

    init(api: API, database: Persistence, request: Request) {
        self.api = api
        self.database = database
        self.request = request
        super.init()
        addOperation(fetch)
    }

    func addSaveOperation(block: @escaping (Request.Response?, URLResponse?, PersistenceClient) throws -> Void) {
        let save = DatabaseOperation(database: database) { [weak self] client in
            try block(self?.fetch.response, self?.fetch.urlResponse, client)
        }
        save.addDependency(fetch)
        addOperation(save)
    }
}
