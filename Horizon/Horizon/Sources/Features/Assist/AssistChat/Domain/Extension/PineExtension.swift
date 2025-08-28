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

extension DomainService {
    /// For when you want to ask Pine a single question that isn't meant to be part of the overall conversation
    func askARAGSingleQuestion(
        question: String,
        courseID: String,
        sourceID: String? = nil,
        sourceType: PineQueryMutation.LearningObjectFilterType? = nil
    ) -> AnyPublisher<String?, any Error> {
        askARAGQuestion(
            messages: [.init(text: question, role: .User)],
            courseID: courseID,
            sourceID: sourceID,
            sourceType: sourceType
        )
        .map { $0?.response }
        .eraseToAnyPublisher()
   }

    func askARAGQuestion(
        messages: [DomainServiceConversationMessage],
        courseID: String,
        sourceID: String? = nil,
        sourceType: PineQueryMutation.LearningObjectFilterType? = nil
    ) -> AnyPublisher<PineQueryMutation.RagResponse?, any Error> {
        api().flatMap { pineAPI in
            pineAPI.makeRequest(
                PineQueryMutation(
                    messages: messages,
                    courseID: courseID,
                    sourceID: sourceID,
                    sourceType: sourceType
                )
            )
            .compactMap { (ragData, _) in
                ragData.data.courseQuery
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func askARAGQuestion(
        question: String,
        history: [AssistChatMessage] = [],
        courseID: String,
        sourceID: String? = nil,
        sourceType: PineQueryMutation.LearningObjectFilterType? = nil
    ) -> AnyPublisher<AssistChatMessage?, any Error> {
        let newHistory = [AssistChatMessage(userResponse: question)] + history
        return askARAGQuestion(
            messages: newHistory.domainServiceConversationMessages,
            courseID: courseID,
            sourceID: sourceID,
            sourceType: sourceType
        )
        .map { response in
            guard let response else { return nil }
            return AssistChatMessage(
                botResponse: response.response,
                citations: response.chatMessageCitations
            )
        }
        .eraseToAnyPublisher()
    }
}

extension PineQueryMutation.RagResponse {
    var chatMessageCitations: [AssistChatMessage.Citation] {
        citations.compactMap { ragCitation in
            ragCitation.citation(
                sourceID: ragCitation.sourceId,
                sourceType: ragCitation.sourceType
            )
        }
    }
}

extension PineQueryMutation.RagCitation {
    func citation(
        sourceID: String,
        sourceType: String
    ) -> AssistChatMessage.Citation? {
        guard let title = metadata["title"] ?? metadata["filename"] else {
            return nil
        }
        return AssistChatMessage.Citation(
            title: title,
            courseID: metadata["courseId"],
            sourceID: sourceID,
            sourceType: AssistChatInteractor.CitationType(rawValue: sourceType)
        )
    }
}
