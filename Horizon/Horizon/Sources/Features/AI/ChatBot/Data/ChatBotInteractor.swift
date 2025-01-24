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

protocol ChatBotInteractor {
    func send(message: ChatBotMessage) -> AnyPublisher<String, Error>
}

class ChatBotInteractorLive: ChatBotInteractor {
    // MARK: - Dependencies

    private let canvasApi: API
    private let cedarBaseUrl: String
    private let model: AIModel

    // MARK: - init

    init(
        canvasApi: API = AppEnvironment.shared.api,
        cedarBaseUrl: String = "https://cedar-api-dev.domain-svcs.nonprod.inseng.io",
        model: AIModel = .claude3Sonnet20240229V10
    ) {
        self.canvasApi = canvasApi
        self.cedarBaseUrl = cedarBaseUrl
        self.model = model
    }

    // MARK: - Public

    func send(message: ChatBotMessage) -> AnyPublisher<String, Error> {
        getCedarJWTToken()
            .flatMap { cedarJwtToken in
                self.getAnswer(cedarJwtToken: cedarJwtToken, prompt: message.serialize())
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func getCedarJWTToken() -> AnyPublisher<String, Error> {
        canvasApi
            .makeRequest(GetCedarJWTToken())
            .tryMap(tokenResponseToUtf8String)
            .eraseToAnyPublisher()
    }

    private func getAnswer(cedarJwtToken: String, prompt: String) -> AnyPublisher<String, Error> {
        guard let baseUrl = URL(string: "https://cedar-api-dev.domain-svcs.nonprod.inseng.io") else {
            return Fail(error: ChatBotInteractorError.invalidUrl).eraseToAnyPublisher()
        }
        return API(
            LoginSession(
                accessToken: cedarJwtToken,
                baseURL: baseUrl,
                userID: "",
                userName: ""
            ),
            baseURL: baseUrl
        )
        .makeRequest(CedarAnswerPromptMutation(cedarJwtToken: cedarJwtToken, prompt: prompt))
        .map { graphQlResponse, _ in graphQlResponse.data.answerPrompt }
        .eraseToAnyPublisher()
    }

    private func tokenResponseToUtf8String(tokenResponse: TokenResponse, urlResponse _: HTTPURLResponse?) throws -> String {
        guard let decodedToken = Data(base64Encoded: tokenResponse.token) else {
            throw ChatBotInteractorError.unableToGetCedarToken
        }

        let utf8EncodedToken = String(data: decodedToken, encoding: .utf8)

        guard let utf8EncodedToken else {
            throw ChatBotInteractorError.unableToGetCedarToken
        }

        return utf8EncodedToken
    }
}

private struct GetCedarJWTToken: APIRequestable {
    typealias Response = TokenResponse

    var path = "/api/v1/jwts?audience=cedar-api-dev.domain-svcs.nonprod.inseng.io&workflows[]=cedar"

    var method: APIMethod { .post }
}

private class CedarAnswerPromptMutation: APIGraphQLRequestable {
    let variables: Input

    private let cedarJwtToken: String

    var path: String {
        "/graphql"
    }

    var headers: [String: String?] {
        [
            "x-apollo-operation-name": "AnswerPrompt",
            HttpHeader.accept: "application/json"
        ]
    }

    public init(
        cedarJwtToken: String,
        prompt: String,
        model: AIModel = .claude3Sonnet20240229V10
    ) {
        self.variables = Variables(model: model.rawValue, prompt: prompt)
        self.cedarJwtToken = cedarJwtToken
    }

    public static let operationName: String = "AnswerPrompt"
    public static var query: String = """
        mutation \(operationName)($model: String!, $prompt: String!) {
            answerPrompt(input: { model: $model, prompt: $prompt })
        }
    """

    typealias Response = GraphQLResponse

    struct Input: Codable, Equatable {
        let model: String
        let prompt: String
    }
}

class ChatBotInteractorPreview: ChatBotInteractor {
    func send(message _: ChatBotMessage) -> AnyPublisher<String, Error> {
        Just("Hello, world!")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Enums

enum ChatBotInteractorError: Error {
    case failedToDecodeToken
    case unableToGetCedarToken
    case invalidUrl
    case unknownError
}

enum AIModel: String {
    case claude3Sonnet20240229V10 = "anthropic.claude-3-sonnet-20240229-v1:0"
}

// MARK: - Codeables

struct TokenResponse: Codable {
    let token: String
}

struct GraphQLResponse: Codable {
    let data: GraphQLData
}

struct GraphQLData: Codable {
    let answerPrompt: String
}

// MARK: - Extensions

extension ChatBotMessage {
    func serialize() -> String {
        text
    }
}
