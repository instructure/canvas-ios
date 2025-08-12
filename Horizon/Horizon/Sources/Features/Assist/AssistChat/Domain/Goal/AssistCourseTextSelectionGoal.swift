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

class AssistCourseTextSelectionGoal: AssistCoursePageGoal {
    // MARK: - Init
    init(environment: AssistDataEnvironment) {
        super.init(environment: environment)
    }

    override
    func execute(response: String?, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let textSelection = environment.textSelection.value else {
            return AssistChatMessage.nilResponse
        }
        let goalOptions: [AssistGoalOption] = [
            .init(
                name: String(localized: "Explain this", bundle: .horizon),
                description: AssistCourseTextSelectionGoal.explainThisPrompt(textSelection: textSelection)
            )
        ]
        guard let response = response else {
            return Just(
                .init(
                    botResponse: AssistCourseTextSelectionGoal.initialPrompt(textSelection: textSelection),
                    chipOptions: goalOptions.chipOptions
                )
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
        return choose(
            from: goalOptions,
            with: response,
            using: cedar
        ).flatMap { [weak self] goalOption in
            guard let self = self else {
                return AssistChatMessage.nilResponse
            }
            guard let goalOption = goalOption else {
                return self.cedarAnswerPrompt(
                    prompt: AssistCourseTextSelectionGoal.askAQuestionPrompt(
                        textSelection: textSelection,
                        response: response
                    )
                )
            }
            return self.cedarAnswerPrompt(prompt: goalOption.description)
        }
        .eraseToAnyPublisher()
    }

    override
    func isRequested() -> Bool {
        environment.courseID.value != nil &&
            environment.pageURL.value != nil &&
            environment.textSelection.value != nil
    }

    // swiftlint:disable line_length
    private static let askAQuestionPrompt: String =
        "You are a teaching assist helping a student who is reading a course page or document. The student has selected some text, and you need to help them with that selection. They've asked you to further explain the text."

    private static func explainThisPrompt(textSelection: String) -> String {
        "You are a teaching assist helping a student who is reading a course page or document. The student has selected some text, and you need to help them with that selection. They've asked you to further explain the text. Here is the text that was selected: \"\(textSelection)\"."
    }

    private static func askAQuestionPrompt(textSelection: String, response: String) -> String {
        "You are a teaching assist helping a student who is reading a course page or document. The student has selected some text, and you need to help them with that selection. They've asked you to answer a question about the text. Here is the text that was selected: \"\(textSelection)\". And here is the question that was asked: \"\(response)\""
    }

    private static func initialPrompt(textSelection: String) -> String {
        "\"\(textSelection)\"" + String(localized: "\n\nHow can I help with this?", bundle: .horizon)
    }
    // swiftlint:enable line_length
}
