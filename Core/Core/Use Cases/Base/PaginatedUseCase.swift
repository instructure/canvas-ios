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

public class PaginatedUseCase<Request, Model>: OperationSet where Request: APIRequestable, Request.Response: Collection {
    let api: API
    let database: Persistence
    let request: Request

    var predicate: NSPredicate {
        fatalError("unimplemented \(#function)")
    }

    func predicate(forItem item: Request.Response.Element) -> NSPredicate {
        fatalError("unimplemented \(#function)")
    }

    func updateModel(_ model: Model, using item: Request.Response.Element, in client: PersistenceClient) throws {
        fatalError("unimplemented \(#function)")
    }

    init(api: API, database: Persistence, request: Request) {
        self.api = api
        self.database = database
        self.request = request
        super.init()

        let exhaust = BlockOperation { [weak self] in
            self?.exhaust(request)
        }
        addSequence([deleteEverything(), exhaust])
    }

    private func deleteEverything() -> Operation {
        return DatabaseOperation(database: database) { [predicate] client in
            let models: [Model] = client.fetch(predicate)
            for model in models {
                try client.delete(model)
            }
        }
    }

    private func exhaust<R>(_ request: R?) where R: APIRequestable, R.Response == Request.Response {
        guard let request = request else {
            return
        }
        let nextPage = RequestUseCase(api: api, database: database, request: request)
        nextPage.addSaveOperation { [weak self] response, urlResponse, client in
            if let response = response {
                try self?.save(response, in: client)
            }
            if let urlResponse = urlResponse {
                self?.exhaust(request.getNext(from: urlResponse))
            }
        }
        addOperation(nextPage)
    }

    private func save(_ response: Request.Response, in client: PersistenceClient) throws {
        for item in response {
            let predicate = self.predicate(forItem: item)
            let model: Model = client.fetch(predicate).first ?? client.insert()
            try updateModel(model, using: item, in: client)
        }
    }
}
