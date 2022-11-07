//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Swifter
import Core

extension HttpResponse {
    static func json<E: Encodable>(_ encodable: E?) -> HttpResponse {
        let data: Data
        do {
            data = try APIJSONEncoder().encode(encodable)
        } catch let e {
            print("internal server error: encoding \(E.self) failed: \(e)")
            return .internalServerError(nil)
        }
        return .json(data: data)
    }

    static func json(object: Any) throws -> HttpResponse {
        try .json(data: JSONSerialization.data(withJSONObject: object))
    }

    static func json(data: Data) -> HttpResponse {
        .data(data, headers: [HttpHeader.contentType: "application/json"])
    }

    static func data(_ data: Data, headers: [String: String] = [:]) -> HttpResponse {
        .raw(200, "OK", headers) { writer in
            try writer.write(data)
        }
    }
}
