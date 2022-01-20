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

public let loginSession = LoginSession(accessToken: "",
                                       baseURL: URL(string: "https://mobileqa.beta.instructure.com")!,
                                       userID: "",
                                       userName: "")

public class DataSeeder {
    private let api: API

    public init(_ loginSession: LoginSession = loginSession) {
        self.api = API(loginSession)
    }

    @discardableResult
    public func makeRequest<Request: APIRequestable>(_ requestable: Request) throws -> Request.Response {
        let result = request(requestable)

        if Request.Response.self is APINoContent.Type {
            return APINoContent() as! Request.Response
        }

        guard let dsUser = result.entity else { throw NSError.instructureError("API call failed") }

        return dsUser
    }

    private func request<Request: APIRequestable>(_ requestable: Request) -> (entity: Request.Response?, urlResponse: URLResponse?, Error?) {
        var result: (entity: Request.Response?, urlResponse: URLResponse?, Error?) = (nil, nil, nil)

        let serializer = DispatchSemaphore(value: 0)
        api.makeRequest(requestable, refreshToken: false) { apiEntity, urlResponse, error in
            result = (apiEntity, urlResponse, error)
            serializer.signal()
        }
        serializer.wait()

        return result
    }
}
