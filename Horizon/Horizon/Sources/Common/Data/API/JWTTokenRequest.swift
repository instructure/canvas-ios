//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Combine
import Core
import Foundation

struct JWTTokenRequest: APIRequestable {
    typealias Response = JWTTokenResponse

    let service: HorizonService

    init(_ service: HorizonService) {
        self.service = service
    }

    var path: String {
        "/api/v1/jwts?audience=\(service.audience)&workflows[]=\(service)"
    }

    var method: APIMethod { .post }
}

enum JWTTokenRequestError: Error {
    case unableToGetToken
}

/// Extension for fetching a JWT token or a configured API instance ready to use
extension JWTTokenRequest {
    // MARK: - Public

    func get(from api: API) -> AnyPublisher<String, Error> {
        api
            .makeRequest(JWTTokenRequest(service))
            .tryMap(tokenResponseToUtf8String)
            .eraseToAnyPublisher()
    }

    func api(from api: API) -> AnyPublisher<API, Error> {
        get(from: api)
            .map { jwt in
                API(
                    LoginSession(
                        accessToken: jwt,
                        baseURL: service.baseURL,
                        userID: "",
                        userName: ""
                    ),
                    baseURL: service.baseURL
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func tokenResponseToUtf8String(tokenResponse: JWTTokenResponse, urlResponse _: HTTPURLResponse?) throws -> String {
        guard let decodedToken = Data(base64Encoded: tokenResponse.token) else {
            throw JWTTokenRequestError.unableToGetToken
        }

        let utf8EncodedToken = String(data: decodedToken, encoding: .utf8)

        guard let utf8EncodedToken else {
            throw JWTTokenRequestError.unableToGetToken
        }

        return utf8EncodedToken
    }
}

struct JWTTokenResponse: Codable {
    let token: String
}
