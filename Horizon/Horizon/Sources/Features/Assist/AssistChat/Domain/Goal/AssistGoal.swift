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

/// The purpose of the AssistGoal is to provide a base class for goals that can be executed within the Assist chat system.
/// The "Goal"s are used to define specific tasks or objectives that the Assist system can help the user achieve.
class AssistGoal {
    /// After a choice of options is made, we execute
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /// Whether or not this goal should be selected in this list of goals
    func isRequested() -> Bool { false }

    func choose(
        from options: [String],
        with userResponse: String,
        using cedar: DomainService
    ) -> AnyPublisher<String?, any Error> {
        return cedar.api().flatMap { cedarAPI in
            cedarAPI.makeRequest(
                CedarConversationMutation(
                    systemPrompt: .optionSelection(from: options),
                    messages: [
                        .init(text: userResponse, role: .User)
                    ]
                )
            )
        }
        .tryMap { response in
            let result = response?.data.conversation.response.replacing(/\"\"/, with: "")
            return result?.isEmpty == true ? nil : result
        }
        .eraseToAnyPublisher()
    }
}

extension String {
    // swiftlint:disable line_length
    static func optionSelection(from options: [String]) -> String {
        "The user has been asked to select from a list of options. Here is that list of options comma separated: \(options.joined(separator: ", ")). Given the users response, tell me which option they've selected. Their answer doesn't have to be exact, but it should be close. If it appears to match none of the options, return an empty string; just the empty string without any explanation. If you find a match, return only the option selected without any additional information."
    }
    // swiftlint:enable line_length
}
