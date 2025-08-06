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
import CombineExt
import Core
import Foundation

struct AssistAnswerPromptTool: AssistTool {

    // MARK: - Properties
    let description: String

    let name: String

    var isAvailable: Bool {
        state.courseID.value != nil &&
            (
                state.fileID.value != nil ||
                state.pageURL.value != nil ||
                state.textSelection.value != nil
            )
    }
    private let unableToAnswer = String(localized: "Sorry, I can't answer that question right now. Please try again later", bundle: .horizon)

    // MARK: - Dependencies
    private let cedar: DomainService
    private let pine: DomainService
    private let state: AssistState

    // MARK: - Init
    init(
        prompt: Prompt,
        name: String,
        state: AssistState,
        pine: DomainService = DomainService(.pine),
        cedar: DomainService = DomainService(.cedar)
    ) {
        self.description = prompt.rawValue
        self.name = name
        self.state = state
        self.pine = pine
        self.cedar = cedar
    }

    // MARK: - Inputs
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let courseID = state.courseID.value else {
            return AssistChatMessage.nilResponse
        }

        if let pageURL = state.pageURL.value {
            return answer(from: courseID, pageURL: pageURL)
        }

        if let fileID = state.fileID.value {
            return answer(from: courseID, fileID: fileID)
        }

        if let textSelection = state.textSelection.value {
            return answer(using: textSelection)
        }
        return AssistChatMessage.nilResponse
    }

    // MARK: - Private Methods
    private func answer(from courseID: String, pageURL: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageURL))
            .getEntities()
            .map { $0.first?.id }
            .flatMap { pageID in
                self.answer(from: courseID, sourceID: pageID, sourceType: .wiki_page)
            }
            .eraseToAnyPublisher()
    }

    private func answer(from courseID: String, fileID: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        answer(from: courseID, sourceID: fileID, sourceType: .attachment)
    }

    private func answer(from courseID: String, sourceID: String?, sourceType: AssistChatInteractor.AssetType) -> AnyPublisher<AssistChatMessage?, any Error> {
        pine.askARAGQuestion(
            question: description,
            courseID: courseID,
            sourceID: sourceID,
            sourceType: sourceType.rawValue
        )
    }

    private func answer(using body: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        cedar.api()
            .flatMap { api in
                api.makeRequest(CedarAnswerPromptMutation(prompt: body))
            }
            .map { (response, _) in
                AssistChatMessage(
                    botResponse: response.data.answerPrompt
                )
            }
            .eraseToAnyPublisher()
    }

    // swiftlint:disable line_length
    enum Prompt: String {
        case KeyTakeaways =
            "You are a teaching assistant creating key takeaways for a student. Give me 3 key takeaways based on the included document contents. Ignore any HTML. Return the result in paragraph form. Each key takeaway is a single sentence bulletpoint. You should not refer to the format of the content, but rather the content itself."

        case RephraseContent =
            "You are a teaching assistant rephrasing content. Rephrase the provided content in a more concise and clear manner. Ignore any HTML. Return the result in paragraph form."

        case TellMeMore =
            "You are a teaching assistant providing more information about the content. Give me more details based on the included document contents. Ignore any HTML. Return the result in paragraph form."
    }
    // swiftlint:enable line_length

}
