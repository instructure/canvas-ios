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
    private let model: AIModel
    private let horizonService: HorizonService

    // MARK: - init

    init(
        canvasApi: API = AppEnvironment.shared.api,
        horizonService: HorizonService = .cedar,
        model: AIModel = .claude3Sonnet20240229V10
    ) {
        self.canvasApi = canvasApi
        self.horizonService = horizonService
        self.model = model
    }

    // MARK: - Public

    func send(message: ChatBotMessage) -> AnyPublisher<String, Error> {
        JWTTokenRequest(.cedar)
            .api(from: canvasApi)
            .flatMap { api in
                self.getAnswer(api: api, prompt: message.serialize())
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func getAnswer(api: API, prompt: String) -> AnyPublisher<String, Error> {
        return api
            .makeRequest(CedarAnswerPromptMutation(cedarJwtToken: api.loginSession?.accessToken ?? "", prompt: prompt))
            .map { graphQlResponse, _ in graphQlResponse.data.answerPrompt }
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

// MARK: - Extensions

extension ChatBotMessage {
    func serialize() -> String {
        text
    }
}
