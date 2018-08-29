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

public class RequestUseCase<Request>: GroupOperation, UseCase where Request: APIRequestable {
    let api: API
    let database: DatabaseStore
    let request: Request
    var errors: [Error] = []
    var next: GetNextRequest<Request.Response>? {
        return fetch.next
    }

    lazy var fetch: APIOperation = {
        return APIOperation(api: api, request: request)
    }()

    lazy var persist: DatabaseOperation = {
        return DatabaseOperation(database: database) { [weak self] client in
            try self?.save(client: client)
        }
    }()

    lazy var finish: Operation = {
        return BlockOperation { [weak self] in
            self?.addError(self?.fetch.error)
            self?.addError(self?.persist.error)
        }
    }()

    init(api: API, database: DatabaseStore, request: Request) {
        self.api = api
        self.database = database
        self.request = request
        super.init()
        persist.addDependency(fetch)
        finish.addDependency(persist)
        addOperations([fetch, persist, finish])
    }

    func save(client: DatabaseClient) throws {
        fatalError("unimplemented")
    }
}
