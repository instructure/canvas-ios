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

import Foundation

enum AIInteractorError: Error {
    case failedToDecodeToken
    case unableToGetCedarToken(httpStatusCode: Int)
    case invalidUrl
    case unknownError
}

// TODO:
// Make the model an enumeration
// Check to see where the token endpoint and base URLs should be configured from.
class AIInteractor {
    private static let tokenEndpoint = "/api/v1/jwts?audience=cedar-api-dev.domain-svcs.nonprod.inseng.io&workflows[]=cedar"
    private static let graphqlEndpoint = "/graphql"
    private static let model = "anthropic.claude-3-sonnet-20240229-v1:0"

    private let cedarBaseUrl: String
    private let canvasBaseUrl: String

    init(
        baseUrl: String = "https://cedar-api-dev.domain-svcs.nonprod.inseng.io",
        canvasBaseUrl: String = "https://horizon.cd.instructure.com"
    ) {
        self.cedarBaseUrl = baseUrl
        self.canvasBaseUrl = canvasBaseUrl
    }

    func sendPrompt(token: String, prompt: String) async -> Result<String, Error> {
        do {
            let cedarTokenResult = try await fetchBase64DecodedCedarToken(canvasToken: token)
            guard let cedarToken = cedarTokenResult.value else {
                return .failure(cedarTokenResult.error ?? AIInteractorError.unknownError)
            }
            let result = try await fetchCedarAIResponse(cedarApiToken: cedarToken, prompt: prompt)

            guard let response = result.value else {
                return .failure(result.error ?? AIInteractorError.unknownError)
            }

            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    private func fetchBase64DecodedCedarToken(canvasToken: String) async throws -> Result<String, Error> {
        guard let tokenUrl = URL(string: canvasBaseUrl + AIInteractor.tokenEndpoint) else {
            return .failure(AIInteractorError.invalidUrl)
        }

        var tokenRequest = URLRequest(url: tokenUrl)
        tokenRequest.httpMethod = "POST"
        tokenRequest.setValue("Bearer \(canvasToken)", forHTTPHeaderField: "Authorization")

        let tokenResponseResult: Result<TokenResponse, Error> = try await decodeUrlRequest(urlRequest: tokenRequest)

        guard let tokenResponse = tokenResponseResult.value else {
            return .failure(tokenResponseResult.error ?? AIInteractorError.unknownError)
        }

        guard let decodedToken = Data(base64Encoded: tokenResponse.token) else {
            return .failure(AIInteractorError.failedToDecodeToken)
        }

        let token = String(data: decodedToken, encoding: .utf8) ?? ""

        return .success(token)
    }

    private func fetchCedarAIResponse(
        cedarApiToken: String,
        prompt: String
    ) async throws -> Result<String, Error> {
        guard let graphqlUrl = URL(string: self.cedarBaseUrl + AIInteractor.graphqlEndpoint) else {
            return .failure(AIInteractorError.invalidUrl)
        }

        var graphqlRequest = URLRequest(url: graphqlUrl)
        graphqlRequest.httpMethod = "POST"
        graphqlRequest.setValue("Bearer \(cedarApiToken)", forHTTPHeaderField: "Authorization")
        graphqlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        graphqlRequest.setValue("AnswerPrompt", forHTTPHeaderField: "x-apollo-operation-name")

        let graphqlBody = GraphQLBody(
            query: """
                mutation AnswerPrompt($model: String!, $prompt: String!) {
                    answerPrompt(input: { model: $model, prompt: $prompt })
                }
            """,
            variables: GraphQLVariables(model: AIInteractor.model, prompt: prompt)
        )

        let jsonData = try JSONEncoder().encode(graphqlBody)
        graphqlRequest.httpBody = jsonData

        let response: Result<GraphQLResponse, Error> = try await decodeUrlRequest(urlRequest: graphqlRequest)

        guard let responseData = response.value else {
            return .failure(response.error ?? AIInteractorError.unknownError)
        }

        return .success(responseData.data.answerPrompt)
    }

    private func decodeUrlRequest<T>(urlRequest: URLRequest) async throws -> Result<T, Error> where T: Codable {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? 0

        if statusCode != 200 {
            return .failure(AIInteractorError.unableToGetCedarToken(httpStatusCode: statusCode))
        }

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(T.self, from: data)
        return .success(decoded)
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

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }.resume()
        }
    }
}
