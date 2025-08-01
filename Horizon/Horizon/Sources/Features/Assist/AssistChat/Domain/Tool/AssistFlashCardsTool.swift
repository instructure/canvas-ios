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

struct AssistFlashCardsTool: AssistTool {

    // MARK: - Dependencies
    private let pine: DomainService
    private let state: AssistState

    // MARK: - Init
    init(state: AssistState, pine: DomainService = DomainService(.pine)) {
        self.state = state
        self.pine = pine
    }

    // swiftlint:disable line_length
    var description: String {
        """
            generate exactly 20 questions and answers based on the provided content for the front and back of flashcards, respectively. If the content contains only an iframe dont try to generate an answer. Flashcards are best suited for definitions and terminology, key concepts and theories, language learning, historical events and dates, and other content that might benefit from active recall and repetition. Prioritize this type of content within the flashcards.
                        Return the flashcards as a valid JSON array in the following format:
                        [
                          {
                            "question": "What is the title of the video?",
                            "answer": "What Is Accountability?"
                          }
                        ]
            without any further description or text. Please keep the questions and answers concise (under 35 words). Each question and answer will be shown on a flashcard, so no need to repeat the question in the answer. Make sure the JSON is valid.
        """
    }
    // swiftlint:enable line_length

    var isRequested: Bool {
        state.courseID.value != nil && (
            state.fileID.value != nil ||
            state.pageURL.value != nil ||
            state.
        )
    }

    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        let sourceType: AssistChatInteractor.AssetType = state.fileID.value != nil ? .attachment : .wiki_page
        guard let courseID = state.courseID.value,
              let sourceID = state.fileID.value ?? state.pageURL.value else {
            return Just<AssistChatMessage?>(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return pine.askARAGQuestion(
            question: description,
            courseID: courseID,
            sourceID: sourceID,
            sourceType: sourceType.rawValue
        )
    }
}
