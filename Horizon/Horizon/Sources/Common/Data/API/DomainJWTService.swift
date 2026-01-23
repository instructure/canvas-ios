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

import Core
import Combine
import Foundation

final public class DomainJWTService {
    public static let shared = DomainJWTService()
    private var horizonApi: API

    init(horizonApi: API = AppEnvironment.defaultValue.api) {
        self.horizonApi = horizonApi
    }

    private struct CachedToken {
        let token: String
        let expirationDate: Date
        private static let expirationBuffer: TimeInterval = 300 // 5 minutes

        var isValid: Bool {
            // Token is valid if it has at least 5 minutes before expiration
            expirationDate.timeIntervalSinceNow > Self.expirationBuffer
        }
    }

    private var tokenCache: [DomainServiceOption: CachedToken] = [:]
    private var refreshSubjects: [DomainServiceOption: AnyPublisher<String, Error>] = [:]

    // Constants
    private static let tokenLifetime: TimeInterval = 3600 // 1 hour
    private let queue = DispatchQueue(
        label: "com.instructure.career.domainJWTService",
        attributes: .concurrent
    )

    // MARK: - Public API

    func getToken(option: DomainServiceOption) -> AnyPublisher<String, Error> {
        return queue.sync(flags: .barrier) { [weak self] () -> AnyPublisher<String, Error> in
            guard let self else {
                return Fail(error: Issue.unableToGetToken)
                    .eraseToAnyPublisher()
            }

            if let cached = self.tokenCache[option], cached.isValid {
                return Just(cached.token)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            if let existing = self.refreshSubjects[option] {
                return existing
            }

            let api = self.horizonApi
            let publisher = api.makeRequest(JWTTokenRequest())
                .tryMap { [weak self] response, urlResponse -> String in
                    guard let self else {
                        throw Issue.unableToGetToken
                    }
                    let token = try self.tokenResponseToUtf8String(
                        tokenResponse: response,
                        urlResponse: urlResponse
                    )

                    guard !token.isEmpty else {
                        throw Issue.unableToGetToken
                    }

                    return token
                }
                .handleEvents(receiveOutput: { [weak self] newToken in
                    self?.setToken(newToken, for: option)
                }, receiveCompletion: { [weak self] completion in
                    self?.clearRefreshSubject(for: option, after: completion)
                })
                .share()
                .eraseToAnyPublisher()

            self.refreshSubjects[option] = publisher
            return publisher
        }
    }

    private func setToken(_ token: String, for option: DomainServiceOption) {
        queue.async(flags: .barrier) { [weak self] in
            self?.tokenCache[option] = CachedToken(
                token: token,
                expirationDate: Date().addingTimeInterval(Self.tokenLifetime)
            )
        }
    }

    private func clearRefreshSubject(
        for option: DomainServiceOption,
        after completion: Subscribers.Completion<Error>
    ) {
        queue.async(flags: .barrier) { [weak self] in
            self?.refreshSubjects[option] = nil
            if case .failure = completion {
                self?.tokenCache[option] = nil
            }
        }
    }

    private func tokenResponseToUtf8String(
        tokenResponse: JWTTokenRequest.Result,
        urlResponse _: HTTPURLResponse?
    ) throws -> String {
        guard let decodedToken = Data(base64Encoded: tokenResponse.token),
              let utf8EncodedToken = String(data: decodedToken, encoding: .utf8)
        else {
            throw Issue.unableToGetToken
        }
        return utf8EncodedToken
    }

    func clear() {
        queue.sync(flags: .barrier) { [weak self] in
            self?.tokenCache = [:]
            self?.refreshSubjects = [:]
        }
    }

    public func setAPIAfterLogin(_ api: API) {
        queue.async(flags: .barrier) { [weak self] in
            self?.horizonApi = api
        }
    }
}
extension DomainJWTService {
    enum Issue: Error {
        case unableToGetToken
        case serviceConfigurationNotFound
    }
}

// https://canvas.instructure.com/doc/api/jw_ts.html
extension DomainJWTService {
    struct JWTTokenRequest: APIRequestable {
        typealias Response = Result
        var shouldAddNoVerifierQuery: Bool = false
        var body: Body? { Body()}
        var path: String {
            return "/api/v1/jwts?canvas_audience=false"
        }

        var method: APIMethod { .post }

        struct Result: Codable {
            let token: String
        }
    }

    struct Body: Codable {
        var workflows: [String] = DomainServiceWorkflow.allCases.map { $0.rawValue }
    }
}
