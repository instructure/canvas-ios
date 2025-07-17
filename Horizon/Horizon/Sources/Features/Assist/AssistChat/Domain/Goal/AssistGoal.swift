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
        return "The user has been asked to select from a list of options. Given the users response, tell me the name of which option they've selected based off of the description of the option. If it appears to match none of the options, return an empty string; just the empty string without any other explanation. If you find a match, return only the name of the option selected without any additional information. Here are the names and descriptions of the options as JSON:\n\n\(jsonString)"
    }
    // swiftlint:enable line_length
}
