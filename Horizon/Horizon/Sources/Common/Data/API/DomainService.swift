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
final class DomainService {

    enum Region: String {
        case central1 = "ca-central-1"
        case east1 = "us-east-1"
        case west2 = "us-west-2"
    }

    // MARK: - Dependencies

    private let baseURL: String
    private let horizonApi: API
    private let option: Option
    private let region: Region

    // MARK: - Private

    private var audience: String {
        baseURL.contains("horizon.cd.instructure.com") == true ? horizonCDURL : productionURL
    }

    private var horizonCDURL: String {
        "\(option)-api-dev.domain-svcs.nonprod.inseng.io"
    }

    private var productionURL: String {
        "\(option)-api-production.\(region.rawValue).temp.prod.inseng.io"
    }

    // MARK: - Init

    init(
        _ domainServiceOption: Option,
        baseURL: String = AppEnvironment.shared.currentSession?.baseURL.absoluteString ?? "",
        region: Region? = nil,
        horizonApi: API = AppEnvironment.defaultValue.api
    ) {
        let defaultRegion = AppEnvironment.shared.currentSession?.canvasRegion.map { Region(rawValue: $0) ?? .east1 } ?? .east1
        self.option = domainServiceOption
        self.baseURL = baseURL
        self.region = region ?? defaultRegion
        self.horizonApi = horizonApi
    }

    // MARK: - Public

    // TODO: cache the token and reuse it
    /// Get the API for the domain service
    func api() -> AnyPublisher<API, Error> {
        horizonApi
            .makeRequest(
                JWTTokenRequest(
                    service: option.service
                )
            )
            .tryMap { [weak self] response, urlResponse in
                guard let self else { throw DomainService.Issue.unableToGetToken }
                return try tokenResponseToUtf8String(tokenResponse: response, urlResponse: urlResponse)
            }
            .compactMap { [weak self] jwt in
                guard let self else { return nil }
                guard let url = URL(string: "https://\(self.audience)") else {
                    fatalError("Unable to get the base URL for the domain service")
                }
                return API(
                    LoginSession(
                        accessToken: jwt,
                        baseURL: url,
                        userID: "",
                        userName: ""
                    ),
                    baseURL: url
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

        var service: String {
            rawValue
        }
    }
}

extension DomainService {
    private struct JWTTokenRequest: APIRequestable {
        typealias Response = Result
        let service: String

        var path: String {
            "/api/v1/jwts?canvas_audience=false&workflows[]=\(service)"
        }

        var method: APIMethod { .post }

        struct Result: Codable {
            let token: String
        }
    }
}
