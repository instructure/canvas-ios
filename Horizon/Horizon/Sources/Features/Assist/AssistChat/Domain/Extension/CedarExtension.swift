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

extension DomainService {
    struct ChooseOption {
        let name: String
        let description: String
    }
    func choose(
        from options: [ChooseOption],
        with userResponse: String,
        using cedar: DomainService
    ) -> AnyPublisher<AssistGoalOption?, any Error> {
        guard let prompt: String = .optionSelection(from: options) else {
            return Just<AssistGoalOption?>(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return cedar.api().flatMap { cedarAPI in
            cedarAPI.makeRequest(
                CedarConversationMutation(
                    systemPrompt: prompt,
                    messages: [
                        .init(text: userResponse, role: .User)
                    ]
                )
            )
        }
        .tryMap { (response, _) in
            let result = response.data.conversation.response.replacing(/\"\"/, with: "")
            guard let option = options.first(where: { result.contains($0.name) }),
                  result.isNotEmpty else {
                return nil
            }
            return option
        }
        .eraseToAnyPublisher()
    }
}
