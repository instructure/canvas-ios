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
import Foundation

struct AssistGoalOption: Codable, Hashable {
    let name: String
    let description: String

    init(name: String, description: String? = nil) {
        self.name = name
        self.description = description ?? name
    }
}

/// The purpose of the AssistGoal is to provide a base class for goals that can be executed within the Assist chat system.
/// The "Goal"s are used to define specific tasks or objectives that the Assist system can help the user achieve.
protocol AssistGoal {
    /// After a choice of options is made, we execute
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error>

    /// Whether or not this goal should be selected in this list of goals
    func isRequested() -> Bool

    func choose(
        from options: [AssistGoalOption],
        with userResponse: String,
        using cedar: DomainService
    ) -> AnyPublisher<String?, any Error>
}

extension AssistGoal {

    func choose(
        from options: [AssistGoalOption],
        with userResponse: String,
        using cedar: DomainService
    ) -> AnyPublisher<String?, any Error> {
        guard let prompt: String = .optionSelection(from: options) else {
            return Just<String?>(nil)
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
            return result.isEmpty == true ? nil : result
        }
        .eraseToAnyPublisher()
    }
}

extension String {
    // swiftlint:disable line_length
    static func optionSelection(from options: [AssistGoalOption]) -> String? {
        guard let jsonData = try? JSONEncoder().encode(options),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return "The user has been asked to select from a list of options. Given the users response, return the JSON {name: \"\", description:\"\"} of the option they've selected based off of the JSON description of the option. Their response needs to match one of the options closely. For instance, if one of the options is \"Nursing Fundamentals\" and the user responds, \"Tell me about the nursing fundamentals course.\", this would not be a match. But if they indicate they want to talk about the course, such as, \"Let's talk about nursing fundamentals\" or \"Nursing fundamentals\", that would be a match. If it appears to match none of the options or the user is asking an unrelated question, return an empty JSON object {} with no other explanation. For instance, do not say \"I will return an empty JSON object:\"; Just return {}. The response MUST be valid JSON. Here are the names and descriptions of the options as JSON:\n\n\(jsonString)"
    }
    // swiftlint:enable line_length
}
