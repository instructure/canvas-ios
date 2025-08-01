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

struct AssistQuizTool: AssistTool {

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
            You are a teaching assistant creating quiz questions based on the provided content. Generate 15 multiple-choice questions with 4 options each, where one option is correct. Each question should be concise and clear, and the correct answer index is zero based. Ignore any HTML. Return the result in JSON format with no additional information. Here is the JSON format to use: [{question: String, options: [String], result: Int}]}]. For instance, if the question is, "What is the capital of France?", the JSON would look like this: [{question: "What is the capital of France?", options: ["Paris", "London", "Berlin", "Madrid"], result: 0}]. Make sure the JSON is valid.
        """
    }
    // swiftlint:enable line_length

    var isRequested: Bool {
        state.courseID.value != nil && (state.fileID.value != nil || state.pageURL.value != nil)
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
