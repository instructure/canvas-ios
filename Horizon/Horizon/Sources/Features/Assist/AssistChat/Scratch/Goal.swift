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

protocol Tool {
    /// A description of this tool provided to the AI for selection criteria
    var description: String { get }

    /// When this tool is selected to process the request, it generates the response
    func response() -> AnyPublisher<AssistChatMessage, any Error>
}

struct GoalOption {
    /// What is displayed to the user for this option.
    var text: String
}

protocol Goal {
    /// After a choice of options is made, we execute
    func execute(response: String, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error>

    /// Whether or not this goal should be selected in this list of goals
    func isRequested() -> Bool

    /// the user may select from one of the following options
    var options: AnyPublisher<[GoalOption], any Error> { get }

    /// How the user is prompted for what to do
    /// For example, I'm in a course and have some options what I can do next
    var userPrompt: String { get }
}

struct SelectCourseActionGoal: Goal {

    var userPrompt: String = "What question do you have about this course?"

    private let environment: AssistDataEnvironment
    private let pine: DomainService

    init(
        environment: AssistDataEnvironment,
        pine: DomainService = DomainService(.pine)
    ) {
        self.environment = environment
        self.pine = pine
    }

    func isRequested() -> Bool {
        environment.courseID.value != nil
    }

    var options: AnyPublisher<[GoalOption], any Error> {
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    func execute(response: String, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let courseID = environment.courseID.value else {
            return Fail(error: NSError(domain: "AssistChat", code: 0, userInfo: [NSLocalizedDescriptionKey: "No course selected"]))
                .eraseToAnyPublisher()
        }
        return pine.api()
            .flatMap { pineApi in
                pineApi.makeRequest(
                    PineQueryMutation(
                        messages: history.domainServiceConversationMessages,
                        courseID: courseID
                    )
                )
                .compactMap { ragData in
                    .init(botResponse: ragData.map { $0.data.query.response } ?? "")
                }
            }
            .eraseToAnyPublisher()
    }
}

struct SelectCourseGoal: Goal {
    var userPrompt: String = "Select from one of the following courses"

    private let cedar: DomainService
    private let environment: AssistDataEnvironment
    private let userID: String

    init(
        environment: AssistDataEnvironment,
        cedar: DomainService = DomainService(.cedar),
        userID: String = AppEnvironment.shared.currentSession?.userID ?? ""
    ) {
        self.environment = environment
        self.cedar = cedar
        self.userID = userID
    }

    func isRequested() -> Bool {
        environment.courseID.value == nil
    }

    var options: AnyPublisher<[GoalOption], any Error> {
        courses
        .map { courses in
            courses.map { .init(text: $0.course.name ?? "") }
        }
        .eraseToAnyPublisher()
    }

    func execute(response: String, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        courses.flatMap { courseOptions in
            let jsonEntries = courseOptions.map {
                "{id: \"\($0.courseID)\", name: \"\($0.course.name ?? "")\"}"
            }.joined(separator: ",")
            let json = "[\(jsonEntries)]"
            return cedar.api().flatMap { cedarAPI in
                cedarAPI.makeRequest(
                    CedarConversationMutation(
                        systemPrompt: "The user has been asked to select from a list of courses that will then be set in the software environment. Given the users response, tell me the ID of which course the user has selected. In your response, provide only the ID. If it appears to match none of the options, return an empty string. This is the list of options in JSON format: \(json)",
                        messages: [
                            .init(text: response, role: .User)
                        ]
                    )
                )
            }
        }
        .tryMap { response in
            guard let _ = response else {
                throw NSError(domain: "AssistChat", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response from server"])
            }
            if let courseID = response?.data.conversation.response {
                environment.setCourseID(courseID)
            }
            return nil
        }
        .eraseToAnyPublisher()
    }

    private var courses: AnyPublisher<[CDHCourse], any Error> {
        ReactiveStore(
            useCase: GetHCoursesProgressionUseCase(userId: userID)
        )
        .getEntities()
        .eraseToAnyPublisher()
    }
}
