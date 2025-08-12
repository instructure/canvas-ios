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

struct AssistFlashCardsTool: AssistTool {

    // MARK: - Dependencies
    private let cedar: DomainService
    private let downloadFileInteractor: DownloadFileInteractor
    private let state: AssistState

    // MARK: - Init
    init(
        state: AssistState,
        downloadFileInteractor: DownloadFileInteractor,
        cedar: DomainService = DomainService(.cedar)
    ) {
        self.state = state
        self.downloadFileInteractor = downloadFileInteractor
        self.cedar = cedar
    }

    let description: String = "Generate flash cards for the provided content."

    let isAvailableAsChip = true

    // swiftlint:disable line_length
    let prompt: String =
        """
            We are generating flash cards. generate exactly 20 questions and answers based on the provided content for the front and back of flashcards, respectively. If the content contains only an iframe dont try to generate an answer. Flashcards are best suited for definitions and terminology, key concepts and theories, language learning, historical events and dates, and other content that might benefit from active recall and repetition. Prioritize this type of content within the flashcards.
                        Return the flashcards as a valid JSON array in the following format:
                        [
                          {
                            "question": "What is the title of the video?",
                            "answer": "What Is Accountability?"
                          }
                        ]
            without any further description or text. Please keep the questions and answers concise (under 35 words). Each question and answer will be shown on a flashcard, so no need to repeat the question in the answer. Make sure the JSON is valid.
        """

    // swiftlint:enable line_length

    let name = String(localized: "Flash Cards", bundle: .horizon)

    var isAvailable: Bool {
        state.courseID.value != nil && (
            state.fileID.value != nil ||
            state.pageURL.value != nil
        )
    }

    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let courseID = state.courseID.value else {
            return Just<AssistChatMessage?>(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        if let fileID = state.fileID.value {
            return document(
                downloadFileInteractor: downloadFileInteractor,
                courseID: courseID,
                fileID: fileID
            )
            .compactMap { $0 }
            .flatMap {
                generateFlashCards(
                    courseID: courseID,
                    base64Source: $0.0,
                    format: $0.1
                )
            }
            .eraseToAnyPublisher()
        }
        if let pageURL = state.pageURL.value {
            return ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageURL))
                .getEntities()
                .flatMap {
                    guard let data =  $0.first?.body.data(using: .utf8) else {
                        return Just<AssistChatMessage?>(nil)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    return generateFlashCards(
                        courseID: courseID,
                        base64Source: data.base64EncodedString()
                    )
                }
                .eraseToAnyPublisher()
        }
        return AssistChatMessage.nilResponse
    }

    private func generateFlashCards(
        courseID: String,
        base64Source: String,
        format: AssistChatDocumentType = .txt
    ) -> AnyPublisher<AssistChatMessage?, any Error> {
        cedar.api()
            .flatMap { api in
                api.makeRequest(
                    CedarAnswerPromptMutation(
                        prompt: prompt,
                        document: CedarAnswerPromptMutation.DocumentInput(
                            format: format,
                            base64Source: base64Source
                        )
                    )
                )
            }
            .map { (response: CedarAnswerPromptMutationResponse?, _) in
                AssistChatMessage(
                    flashCards: AssistChatFlashCard.build(from: response?.data.answerPrompt ?? "") ?? []
                )
            }
            .eraseToAnyPublisher()
    }
}
