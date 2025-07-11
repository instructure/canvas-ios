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

class SelectCourseActionGoal: Goal {

    private let environment: AssistDataEnvironment
    private let pine: DomainService
    private var userID: String

    init(
        environment: AssistDataEnvironment,
        userID: String = AppEnvironment.shared.currentSession?.userID ?? "",
        pine: DomainService = DomainService(.pine)
    ) {
        self.environment = environment
        self.userID = userID
        self.pine = pine
    }

    override
    func isRequested() -> Bool {
        environment.courseID.value != nil
    }

    override
    func execute(response: String?, history: [AssistChatMessage] = []) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let courseID = environment.courseID.value else {
            return Fail(error: NSError(domain: "AssistChat", code: 0, userInfo: [NSLocalizedDescriptionKey: "No course selected"]))
                .eraseToAnyPublisher()
        }
        guard let response = response, response.isNotEmpty else {
            return initialPrompt(history: history)
        }
        return askAQuestion(response: response, history: history, courseID: courseID)
    }

    private func askAQuestion(response: String, history: [AssistChatMessage], courseID: String) -> AnyPublisher<AssistChatMessage?, any Error> {
        pine.api()
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

    private var courseName: AnyPublisher<String?, any Error> {
        ReactiveStore(
            useCase: GetHCoursesProgressionUseCase(userId: userID)
        )
        .getEntities()
        .map { courses in
            courses.first { $0.courseID == self.environment.courseID.value }?.course.name ?? ""
        }
        .eraseToAnyPublisher()
    }

    private func initialPrompt(history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        courseName.map { courseName in
            var prompt = "What would you like to discuss today?"
            if let courseName = courseName {
                prompt = "What would you like to discuss about \(courseName)?"
            }
            return AssistChatMessage(botResponse: prompt)
        }
        .eraseToAnyPublisher()
    }
}
