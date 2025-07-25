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
    func askARAGQuestion(
        question: String,
        courseID: String? = nil,
        sourceID: String? = nil,
        sourceType: String? = nil

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
        courseID: String? = nil,
        sourceID: String? = nil,
        sourceType: String? = nil
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
                ragData.data.query
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func askARAGQuestion(
        history: [AssistChatMessage],
        courseID: String? = nil,
        sourceID: String? = nil,
        sourceType: String? = nil
    ) -> AnyPublisher<AssistChatMessage?, any Error> {
        askARAGQuestion(
            messages: history.domainServiceConversationMessages,
            courseID: courseID,
            sourceID: sourceID,
            sourceType: sourceType
        )
        .map {
            $0.map {
                AssistChatMessage(
                    botResponse: $0.response,
                    citations: $0.chatMessageCitations
                )
            }
        }
        .eraseToAnyPublisher()
    }
}
