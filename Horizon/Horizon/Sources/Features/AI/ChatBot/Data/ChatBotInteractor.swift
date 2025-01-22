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
import Foundation

enum ChatBotInteractorError: Error {
    case failedToDecodeToken
    case unableToGetCedarToken(httpStatusCode: Int)
    case invalidUrl
    case unknownError
}

enum AIModel: String {
    case claude3Sonnet20240229V10 = "anthropic.claude-3-sonnet-20240229-v1:0"
}

class ChatBotInteractor {

    // MARK: - Constants

    private static let canvasJwtEndpoint = "/api/v1/jwts?audience=cedar-api-dev.domain-svcs.nonprod.inseng.io&workflows[]=cedar"
    private static let graphqlEndpoint = "/graphql"

    // MARK: - Dependencies

    private let canvasAccessToken: String
    private let canvasBaseUrl: String
    private let cedarBaseUrl: String
    private let dataTaskProtocol: DataTaskProtocol
    private let model: AIModel

    /// canvasBaseUrl: The base URL for the Canvas API. We fetch a JWT from this endpoint using a canvas token that is later used to authenticate with the Cedar API
    /// cedarBaseUrl: The base URL for the Cedar API. This has the GraphQl endpoint that we use to send prompts to the AI model
    /// model: The AI model to use for generating responses. Currently only one model is supported
    /// cavnasAccessToken: The access token for the Canvas API. Normally this will come from the shared AppEnvironment, but can be overridden (primarily for unit tests)
    /// dataTaskProtocol: The protocol used to fetch data. This is primarily used for unit tests
    init(
        canvasBaseUrl: String = "https://horizon.cd.instructure.com",
        cedarBaseUrl: String = "https://cedar-api-dev.domain-svcs.nonprod.inseng.io",
        model: AIModel = .claude3Sonnet20240229V10,
        canvasAccessToken: String = AppEnvironment.shared.currentSession?.accessToken ?? "",
        dataTaskProtocol: DataTaskProtocol = URLSession.shared
    ) {
        self.canvasAccessToken = canvasAccessToken
        self.cedarBaseUrl = cedarBaseUrl
        self.canvasBaseUrl = canvasBaseUrl
        self.model = model
        self.dataTaskProtocol = dataTaskProtocol
    }

    // MARK: - Inputs

    /// Send a generic prompt to the AI model and get a response
    func send(message: ChatBotMessage) async -> Result<String, Error> {
        do {
            let cedarTokenResult = try await fetchBase64DecodedCedarToken(canvasToken: canvasAccessToken)
            guard let cedarToken = cedarTokenResult.value else {
                return .failure(cedarTokenResult.error ?? ChatBotInteractorError.unknownError)
            }

            let result = try await fetchCedarAIResponse(cedarApiToken: cedarToken, message: message)

            guard let response = result.value else {
                return .failure(result.error ?? ChatBotInteractorError.unknownError)
            }

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Private Methods

    /// Fetch a base64 decoded Cedar token from the Canvas API
    private func fetchBase64DecodedCedarToken(canvasToken: String) async throws -> Result<String, Error> {
        guard let tokenUrl = URL(string: canvasBaseUrl + ChatBotInteractor.canvasJwtEndpoint) else {
            return .failure(ChatBotInteractorError.invalidUrl)
        }

        var tokenRequest = URLRequest(url: tokenUrl)
        tokenRequest.httpMethod = "POST"
        tokenRequest.setValue("Bearer \(canvasToken)", forHTTPHeaderField: "Authorization")

        let tokenResponseResult: Result<TokenResponse, Error> = try await decodeUrlRequest(urlRequest: tokenRequest)

        guard let tokenResponse = tokenResponseResult.value else {
            return .failure(tokenResponseResult.error ?? ChatBotInteractorError.unknownError)
        }

        guard let decodedToken = Data(base64Encoded: tokenResponse.token) else {
            return .failure(ChatBotInteractorError.failedToDecodeToken)
        }

        let token = String(data: decodedToken, encoding: .utf8) ?? ""

        return .success(token)
    }

    /// Fetch a response from the Cedar AI model
    private func fetchCedarAIResponse(
        cedarApiToken: String,
        message: ChatBotMessage
    ) async throws -> Result<String, Error> {
        guard let graphqlUrl = URL(string: self.cedarBaseUrl + ChatBotInteractor.graphqlEndpoint) else {
            return .failure(ChatBotInteractorError.invalidUrl)
        }

        var graphqlRequest = URLRequest(url: graphqlUrl)
        graphqlRequest.httpMethod = "POST"
        graphqlRequest.setValue("Bearer \(cedarApiToken)", forHTTPHeaderField: "Authorization")
        graphqlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        graphqlRequest.setValue("AnswerPrompt", forHTTPHeaderField: "x-apollo-operation-name")

        let prompt = message.serialize()

        let graphqlBody = GraphQLBody(
            query: """
                mutation AnswerPrompt($model: String!, $prompt: String!) {
                    answerPrompt(input: { model: $model, prompt: $prompt })
                }
            """,
            variables: GraphQLVariables(model: model.rawValue, prompt: prompt)
        )

        let jsonData = try JSONEncoder().encode(graphqlBody)
        graphqlRequest.httpBody = jsonData

        let response: Result<GraphQLResponse, Error> = try await decodeUrlRequest(urlRequest: graphqlRequest)

        guard let responseData = response.value else {
            return .failure(response.error ?? ChatBotInteractorError.unknownError)
        }

        return .success(responseData.data.answerPrompt)
    }

    private func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            dataTaskProtocol.data(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
        }
    }

    /// Decode a URL request into a Codable object
    private func decodeUrlRequest<T>(urlRequest: URLRequest) async throws -> Result<T, Error> where T: Codable {
        let (data, response) = try await data(for: urlRequest)

        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? 0

        if statusCode != 200 {
            return .failure(ChatBotInteractorError.unableToGetCedarToken(httpStatusCode: statusCode))
        }

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(T.self, from: data)
        return .success(decoded)
    }

    private func serialize(messages: [ChatBotMessage]) -> String {
        messages.map { $0.serialize() }.joined(separator: ",")
    }
}

// Helper structs for JSON decoding
struct TokenResponse: Codable {
    let token: String
}

struct GraphQLBody: Codable {
    let query: String
    let variables: GraphQLVariables
}

struct GraphQLVariables: Codable {
    let model: String
    let prompt: String
}

struct GraphQLResponse: Codable {
    let data: GraphQLData
}

struct GraphQLData: Codable {
    let answerPrompt: String
}

// abstraction for fetching data from the network. Used for unit tests
protocol DataTaskProtocol {
    func data(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void)
}

extension URLSession: DataTaskProtocol {
    func data(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void) {
        dataTask(with: request, completionHandler: completionHandler).resume()
    }
}

extension ChatBotMessage {
    func serialize() -> String {
        text
    }
}
