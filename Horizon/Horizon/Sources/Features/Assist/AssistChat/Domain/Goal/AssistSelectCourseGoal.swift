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

class AssistSelectCourseGoal: AssistGoal {
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

    override
    func isRequested() -> Bool {
        environment.courseID.value == nil
    }

    override
    func execute(response: String? = nil, history: [AssistChatMessage] = []) -> AnyPublisher<AssistChatMessage?, any Error> {
        guard let response = response, response.isNotEmpty else {
            return initialPrompt(history: history)
        }

        return selectCourseFrom(response: response, history: history)
    }

    private func selectCourseFrom(response: String, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        weak var weakSelf = self
        return courses.flatMap { courseOptions in
            guard let weakSelf = weakSelf else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            let courseNames = courseOptions.compactMap { $0.course.name }
            return weakSelf.choose(from: courseNames, with: response, using: weakSelf.cedar)
                .map { courseSelected in
                    if  let courseSelected = courseSelected,
                        let courseID = courseOptions.first(where: { courseSelected.contains($0.course.name ?? "") == true })?.courseID {
                        weakSelf.environment.courseID.accept(courseID)
                    }
                    return nil
                }
                .eraseToAnyPublisher()
        }
        .map { _ in nil }
        .eraseToAnyPublisher()
    }

    private func initialPrompt(history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        let promptFirstTime = String(localized: "Hello! Which course you'd like to discuss today?", bundle: .horizon)
        let promptAgain = String(localized: "Sorry, can we try that again? Which course is it you'd like to discuss?", bundle: .horizon)
        let didIJustAskThis = history.count > 1 && history[history.count - 2].text?.contains(promptFirstTime) == true
        let prompt = didIJustAskThis ? promptAgain : promptFirstTime
        return courses.flatMap { courses in
            Just(
                .init(
                    botResponse: prompt,
                    chipOptions: courses
                        .prefix(5)
                        .compactMap { $0.course.name }
                        .map { .init(chip: $0, prompt: $0) }
                )
            )
            .setFailureType(to: Error.self)
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
