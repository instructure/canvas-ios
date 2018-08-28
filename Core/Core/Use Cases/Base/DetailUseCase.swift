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
    var predicate: NSPredicate {
        fatalError("unimplemented \(#function)")
    }

    func updateModel(_ model: Model, using item: Request.Response, in client: DatabaseClient) throws {
        fatalError("unimplemented \(#function)")
    }

    override func save(client: DatabaseClient) throws {
        guard let response = fetch.response else {
            return
        }
        let model: Model = client.fetch(predicate).first ?? client.insert()
        try updateModel(model, using: response, in: client)
        try client.save()
    }
}
