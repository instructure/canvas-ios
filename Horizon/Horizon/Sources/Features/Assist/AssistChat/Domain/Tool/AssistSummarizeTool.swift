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
    var description: String { "Summarize this page" }

    var isAvailable: Bool {
        state.courseID.value != nil &&
            (
                state.fileID.value != nil ||
                state.pageURL.value != nil ||
                state.textSelection.value != nil
            )
    }

    let isAvailableAsChip = true

    let prompt = "Summarize this page"

    private let unableToSummarize = String(localized: "Sorry, I can't summarize that content right now. Please try again later", bundle: .horizon)

    // MARK: - Dependencies
    private let cedar: DomainService
    private let downloadFileInteractor: DownloadFileInteractor
    private let state: AssistState

    // MARK: - Init
    init(
        state: AssistState,
        downloadFileInteractor: DownloadFileInteractor,
        cedar: DomainService = DomainService(.cedar),
    ) {
        self.state = state
        self.downloadFileInteractor = downloadFileInteractor
        self.cedar = cedar
    }

    // MARK: - Inputs
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let courseID = state.courseID.value else {
            return AssistChatMessage.nilResponse
        }

        if let textSelection = state.textSelection.value {
            return summarize(using: textSelection)
        }

        if let pageURL = state.pageURL.value {
            return summarize(from: courseID, pageURL: pageURL)
        }

        if let fileID = state.fileID.value {
            return summarize(from: courseID, fileID: fileID)
        }
        return AssistChatMessage.nilResponse
    }

    // MARK: - Private Methods
    private func answerPrompt(base64Source: String, format: AssistChatDocumentType) -> AnyPublisher<AssistChatMessage?, any Error> {
        cedar.api()
            .flatMap { api in
                api.makeRequest(
                    CedarAnswerPromptMutation(
                        prompt: prompt,
                        document: .init(format: format, base64Source: base64Source)
                    )
                )
            }
            .map { response, _ in
                AssistChatMessage(
                    botResponse: response.data.answerPrompt
                )
            }
            .eraseToAnyPublisher()
    }

    private func summarize(from courseID: String, pageURL: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageURL))
            .getEntities()
            .map { $0.first?.body }
            .flatMap { body in
                self.summarize(using: body ?? "")
            }
            .eraseToAnyPublisher()
    }

    private func summarize(from courseID: String, fileID: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        document(
            downloadFileInteractor: downloadFileInteractor,
            courseID: courseID,
            fileID: fileID
        )
        .compactMap { $0 }
        .flatMap {
            answerPrompt(base64Source: $0.0, format: $0.1)
        }
        .eraseToAnyPublisher()
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
