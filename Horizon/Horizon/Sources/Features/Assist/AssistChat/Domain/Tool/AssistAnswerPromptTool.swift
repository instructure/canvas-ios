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
    var description: String { promptType?.description ?? "The user is asking a question about some text. This should be selected only if no other options match" }

    var name: String { promptType?.name ?? "Answer a question" }

    var isAvailable: Bool {
        state.courseID.value != nil &&
            (
                state.fileID.value != nil ||
                state.pageURL.value != nil ||
                state.textSelection.value != nil
            )
    }

    var isAvailableAsChip: Bool {
        promptType != nil
    }

    var prompt: String { promptType?.prompt ?? "The user is asking a question about this document. Answer the question in 3 - 5 sentences." }

    private let unableToAnswer = String(localized: "Sorry, I can't answer that question right now. Please try again later", bundle: .horizon)

    // MARK: - Dependencies
    private let cedar: DomainService
    private let downloadFileInteractor: DownloadFileInteractor
    private let promptType: PromptType?
    private let state: AssistState

    // MARK: - Init
    init(
        state: AssistState,
        promptType: PromptType? = nil,
        downloadFileInteractor: DownloadFileInteractor,
        cedar: DomainService = DomainService(.cedar)
    ) {
        self.state = state
        self.promptType = promptType
        self.downloadFileInteractor = downloadFileInteractor
        self.cedar = cedar
    }

    // MARK: - Inputs
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let courseID = state.courseID.value,
              let question = promptType != nil ? description : response else {
            return AssistChatMessage.nilResponse
        }

        if let pageURL = state.pageURL.value {
            return answer(question: question, from: courseID, pageURL: pageURL)
        }

        if let fileID = state.fileID.value {
            return answer(question: question, from: courseID, fileID: fileID)
        }

        if let textSelection = state.textSelection.value {
            return answer(question: question, using: textSelection)
        }

        return AssistChatMessage.nilResponse
    }

    // MARK: - Private Methods
    private func answer(
        question: String,
        from courseID: String,
        pageURL: String
    ) -> AnyPublisher<AssistChatMessage?, any Error> {
        ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageURL))
            .getEntities()
            .compactMap { $0.first?.body }
            .flatMap { body in
                self.answer(question: question, using: body)
            }
            .eraseToAnyPublisher()
    }

    private func answer(
        question: String,
        from courseID: String,
        fileID: String
    ) -> AnyPublisher<AssistChatMessage?, any Error> {
        document(
            downloadFileInteractor: downloadFileInteractor,
            courseID: courseID,
            fileID: fileID
        )
        .compactMap { $0 }
        .flatMap {
            answer(question: question, base64Source: $0.0, format: $0.1)
        }
        .eraseToAnyPublisher()
    }

    private func answer(question: String, using: String, format: AssistChatDocumentType = .txt) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let data = using.data(using: .utf8) else {
            return Just<AssistChatMessage?>(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return answer(question: question, base64Source: data.base64EncodedString(), format: format)
    }

    private func answer(question: String, base64Source: String, format: AssistChatDocumentType) -> AnyPublisher<AssistChatMessage?, any Error> {
        let prompt = "The user is asking a question about some text. Answer the question in 3 - 5 sentences. Here's the question: \"\(question)\""
        return cedar.api()
            .flatMap { api in
                api.makeRequest(
                    CedarAnswerPromptMutation(
                        prompt: prompt,
                        document: .init(format: format, base64Source: base64Source)
                    )
                )
            }
            .map { (response, _) in
                AssistChatMessage(
                    botResponse: response.data.answerPrompt
                )
            }
            .eraseToAnyPublisher()
    }

    enum PromptType: String {
        case KeyTakeaways
        case RephraseContent
        case TellMeMore
    }
}

private extension AssistAnswerPromptTool.PromptType {
    var name: String {
        [
            .KeyTakeaways: String(localized: "Give me key takeaways", bundle: .horizon),
            .RephraseContent: String(localized: "Rephrase this material", bundle: .horizon),
            .TellMeMore: String(localized: "Tell me more about this topic", bundle: .horizon)
        ][self] ?? ""
    }
    var description: String {
        [
            .KeyTakeaways: String(localized: "Give me key takeaways", bundle: .horizon),
            .RephraseContent: String(localized: "Rephrase this material", bundle: .horizon),
            .TellMeMore: String(localized: "Tell me more about this topic", bundle: .horizon)
        ][self] ?? ""
    }
    var prompt: String {
        [
            .KeyTakeaways:
            "You are a teaching assistant creating key takeaways for a student. Give me a bulleted list of 3 key takeaways based on the included document contents. Ignore any HTML. Return the result as a bulleted list. Each key takeaway is a single sentence bulletpoint. You should not refer to the format of the content, but rather the content itself.",
            .RephraseContent:
            "You are a teaching assistant rephrasing content. Rephrase the provided content in a more concise and clear manner. Ignore any HTML. Return the result in paragraph form.",
            .TellMeMore:
            "You are a teaching assistant providing more information about the content. Give me more details based on the included document contents. Ignore any HTML. Return the result in paragraph form."
        ][self] ?? ""
    }
}
