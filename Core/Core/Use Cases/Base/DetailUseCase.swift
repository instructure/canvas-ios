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

public class DetailUseCase<Request, Model>: RequestUseCase<Request> where Request: APIRequestable {
    override init(api: API, database: Persistence, request: Request) {
        super.init(api: api, database: database, request: request)
        addSaveOperation { [weak self] response, urlResponse, client in
            try self?.save(response: response, urlResponse: urlResponse, client: client)
        }
    }

    var predicate: NSPredicate {
        fatalError("unimplemented \(#function)")
    }

    func updateModel(_ model: Model, using item: Request.Response, in client: PersistenceClient) throws {
        fatalError("unimplemented \(#function)")
    }

    func save(response: Request.Response?, urlResponse: URLResponse?, client: PersistenceClient) throws {
        guard let response = response else {
            return
        }
        let model: Model = client.fetch(predicate: predicate, sortDescriptors: nil).first ?? client.insert()
        try updateModel(model, using: response, in: client)
    }
}
