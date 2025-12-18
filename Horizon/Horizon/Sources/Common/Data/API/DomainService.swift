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

protocol DomainServiceProtocol {
    func api() -> AnyPublisher<API, Error>
}

final class DomainService: DomainServiceProtocol {
    // MARK: - Dependencies

    private let baseURL: String
    private let domainJWTService: DomainJWTService
    let option: DomainServiceOption
    private let region: String

    // MARK: - Private

    private var audience: String {
        return baseURL.contains("horizon.cd.instructure.com") == true ? horizonCDURL : productionURL
    }

    private var horizonCDURL: String {
        if( option == .journey) {
            return "journey-server-edge.journey.nonprod.inseng.io"
        }
        return "\(option)-api-dev.us-east-1.core.inseng.io"
    }

    private var productionURL: String {
        if option == .journey {
            return "journey-server-prod.\(region).temp.prod.inseng.io"
        }
        return "\(option)-api.\(region).core.inseng.io"
    }

    // MARK: - Init

    init(
        _ domainServiceOption: DomainServiceOption,
        baseURL: String = AppEnvironment.shared.currentSession?.baseURL.absoluteString ?? "",
        region: String? = AppEnvironment.shared.currentSession?.canvasRegion,
        domainJWTService: DomainJWTService = DomainJWTService.shared,
    ) {
        self.option = domainServiceOption
        self.baseURL = baseURL
        self.region = region ?? "us-east-1"
        self.domainJWTService = domainJWTService
    }

    // MARK: - Public

    /// Get the API for the domain service
    func api() -> AnyPublisher<API, Error> {
        domainJWTService
            .getToken(option: option)
            .tryMap { [weak self] jwt -> API in
                guard let self, let url = URL(string: "https://\(self.audience)") else {
                    throw DomainJWTService.Issue.unableToGetToken
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
}

enum DomainServiceOption: String {
    case cedar
    case journey
    case pine
    case redwood
    var service: String {
        rawValue
    }

    var workflows: [DomainServiceOption] {
        self == .journey ?
        [self, .pine] :
        [self]
    }
}
