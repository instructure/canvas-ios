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

class AssistCourseActionTool: AssistTool {
    private var suggestions: [AssistChipOption]?

    // MARK: - Dependencies
    private let state: AssistState
    private let pine: DomainService
    private var userID: String

    var description: String = ""

    var name: String { "Ask a question" }

    // MARK: - Init
    init(
        state: AssistState,
        userID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        pine: DomainService = DomainService(.pine)
    ) {
        self.state = state
        self.userID = userID
        self.pine = pine
    }

    // MARK: - Inputs
    var isAvailable: Bool {
        state.courseID.value != nil
    }

    func execute(response: String?, history: [AssistChatMessage] = []) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let courseID = state.courseID.value else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        guard let response = response, response.isNotEmpty else {
            return initialPrompt(history: history, courseID: courseID)
        }
        return pine.askARAGQuestion(
            question: response,
            history: history,
            courseID: courseID
        )
    }

    // MARK: - Private Methods
    private var courseName: AnyPublisher<String?, any Error> {
        ReactiveStore(
            useCase: GetHCoursesProgressionUseCase(userId: userID)
        )
        .getEntities()
        .map { [weak self] courses in
            courses.first { $0.courseID == self?.state.courseID.value }?.course.name ?? ""
        }
        .eraseToAnyPublisher()
    }

    private func initialPrompt(history: [AssistChatMessage], courseID: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        if let suggestions {
            return courseName.map { courseName in
                AssistChatMessage(
                    botResponse: courseName.map { .initialPrompt(with: $0) } ?? .initialPrompt(),
                    chipOptions: suggestions
                )
            }
            .eraseToAnyPublisher()
        }
        return pine.askARAGSingleQuestion(question: .generateSuggestionsPrompt, courseID: courseID)
            .flatMap { [weak self] suggestionsJSON in
                guard let self = self else {
                    return Just<AssistChatMessage?>(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                self.suggestions = suggestionsJSON.map { self.parseChipOptions(from: $0) } ?? []
                return courseName.map { courseName in
                    AssistChatMessage(
                        botResponse: courseName.map { .initialPrompt(with: $0) } ?? .initialPrompt(),
                        chipOptions: self.suggestions ?? []
                    )
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func parseChipOptions(from json: String) -> [AssistChipOption] {
        guard let data = json.data(using: .utf8) else { return [] }
        do {
            let suggestions = try JSONDecoder().decode([AssistChipOption].self, from: data)
            return suggestions
        } catch {
            print("Failed to decode suggestions JSON: \(error)")
            return []
        }
    }
}

// swiftlint:disable line_length
private extension String {
    static var generateSuggestionsPrompt: String {
        "Generate up to 5 suggestions for questions the user might ask about the course content. The response will be returned in JSON format. Each entry will have the JSON format {\"chip\": \"\", \"prompt\": \"\"}. \"chip\" is a 1-3 word abbreviation for each suggestion. \"prompt\" is a full sentence that the user can ask to get more information about the course content. The response should be in JSON format with no other text."
    }
    static func initialPrompt() -> String {
        String(localized: "What would you like to discuss today?", bundle: .horizon)
    }
    static func initialPrompt(with courseName: String) -> String {
        let format = String(localized: "What would you like to discuss about the course %@?", bundle: .horizon)
        return String(format: format, courseName)
    }
}
// swiftlint:enable line_length

extension Array where Element == AssistChatMessage {
    var domainServiceConversationMessages: [DomainServiceConversationMessage] {
        prependUserMessage()
            .map {
                DomainServiceConversationMessage(
                    text: $0.text ?? $0.prompt ?? "",
                    role: $0.role == .Assistant ? .Assistant : .User
                )
            }
    }

    /// The API requires that the first message is from the user, so we prepend a user message if the first message is not from the user.
    private func prependUserMessage() -> [AssistChatMessage] {
        guard let first = first, first.role != .User else {
            return self
        }
        return [.init(userResponse: "Hello")] + self
    }
}
