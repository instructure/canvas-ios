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

/// A representation of our domain services
/// These are configured the the .xcconfig files and in the target info build settings
struct DomainService {

    // MARK: - Dependencies

    private let option: Option
    private let horizonApi: API

    // MARK: - Private

    var baseURL: URL {
        guard let baseUrl = try? option.audience(),
              let url = URL(string: "https://\(baseUrl)") else {
            fatalError("Unable to get the base URL for the domain service")
        }
        return url
    }

    // MARK: - Init

    init(
        _ domainServiceOption: Option,
        horizonApi: API = AppEnvironment.defaultValue.api
    ) {
        self.option = domainServiceOption
        self.horizonApi = horizonApi
    }

    // MARK: - Public

    // TODO: cache the token and reuse it
    /// Get the API for the domain service
    func api() -> AnyPublisher<API, Error> {
        guard let audience = try? option.audience() else {
            return Fail(error: DomainService.Issue.serviceConfigurationNotFound).eraseToAnyPublisher()
        }
        return horizonApi
            .makeRequest(
                JWTTokenRequest(
                    audience: audience,
                    service: option.service
                )
            )
            .tryMap(tokenResponseToUtf8String)
            .map { jwt in
                API(
                    LoginSession(
                        accessToken: jwt,
                        baseURL: baseURL,
                        userID: "",
                        userName: ""
                    ),
                    baseURL: baseURL
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func tokenResponseToUtf8String(
        tokenResponse: JWTTokenRequest.Result,
        urlResponse _: HTTPURLResponse?
    ) throws -> String {
        guard let decodedToken = Data(base64Encoded: tokenResponse.token) else {
            throw DomainService.Issue.unableToGetToken
        }

        let utf8EncodedToken = String(data: decodedToken, encoding: .utf8)

        guard let utf8EncodedToken else {
            throw DomainService.Issue.unableToGetToken
        }

        return utf8EncodedToken
    }
}

extension DomainService {
    enum Issue: Error {
        case unableToGetToken
        case serviceConfigurationNotFound
    }
}

extension DomainService {
    enum Option: String {

        case cedar
        case pine
        case redwood

        func audience() throws -> String {
            // configured in the .xcconfig files and in the target info build settings
            guard let dict = Bundle.main.object(forInfoDictionaryKey: "Domain Service URLs") as? NSDictionary,
                  let audience = dict[rawValue] as? String else {
                    throw(DomainService.Issue.serviceConfigurationNotFound)
                  }
            return audience
        }

        var service: String {
            rawValue
        }
    }
}

extension DomainService {
    private struct JWTTokenRequest: APIRequestable {
        typealias Response = Result

        let audience: String
        let service: String

        var path: String {
            "/api/v1/jwts?audience=\(audience)&workflows[]=\(service)"
        }

        var method: APIMethod { .post }

        struct Result: Codable {
            let token: String
        }
    }
}
