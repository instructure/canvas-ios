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

struct AssistSummarizeTool: AssistTool {

    var name: String { String(localized: "Summarize this material", bundle: .horizon) }

    // MARK: - Properties
    var description: String { "Summarize this page or file contents" }

    var isAvailable: Bool {
        state.courseID.value != nil &&
            (
                state.fileID.value != nil ||
                state.pageURL.value != nil ||
                state.textSelection.value != nil
            )
    }

    var prompt: String {
        "Summarize this page or file contents"
    }
    private let unableToSummarize = String(localized: "Sorry, I can't summarize that content right now. Please try again later", bundle: .horizon)

    // MARK: - Dependencies
    private let cedar: DomainService
    private let pine: DomainService
    private let state: AssistState

    // MARK: - Init
    init(
        state: AssistState,
        pine: DomainService = DomainService(.pine),
        cedar: DomainService = DomainService(.cedar)
    ) {
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
            return summarize(from: courseID, pageURL: pageURL)
        }

        if let fileID = state.fileID.value {
            return summarize(from: courseID, fileID: fileID)
        }

        if let textSelection = state.textSelection.value {
            return summarize(using: textSelection)
        }
        return AssistChatMessage.nilResponse
    }

    // MARK: - Private Methods
    private func summarize(from courseID: String, pageURL: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageURL))
            .getEntities()
            .map { $0.first?.id }
            .flatMap { pageID in
                self.summarize(from: courseID, sourceID: pageID, sourceType: .Page)
            }
            .eraseToAnyPublisher()
    }

    private func summarize(from courseID: String, fileID: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        summarize(from: courseID, sourceID: fileID, sourceType: .File)
    }

    private func summarize(from courseID: String, sourceID: String?, sourceType: AssistChatInteractor.AssetType) -> AnyPublisher<AssistChatMessage?, any Error> {
        pine.askARAGQuestion(
            question: description,
            courseID: courseID,
            sourceID: sourceID,
            sourceType: sourceType.learningObjectFilterType
        )
    }

    private func summarize(using body: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        cedar.api()
            .flatMap { api in
                api.makeRequest(CedarSummarizeContentMutation(content: body))
            }
            .map { (response, _) in
                AssistChatMessage(
                    botResponse: response.data.summarizeContent.summarization.joined(separator: "\n")
                )
            }
            .eraseToAnyPublisher()
    }
}
