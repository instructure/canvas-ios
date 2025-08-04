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

class AssistSelectCourseTool: AssistTool {
    private let cedar: DomainService
    private let state: AssistState
    private let pine: DomainService
    private let userID: String

    var description: String = ""

    init(
        state: AssistState,
        cedar: DomainService = DomainService(.cedar),
        pine: DomainService = DomainService(.pine),
        userID: String = AppEnvironment.shared.currentSession?.userID ?? ""
    ) {
        self.state = state
        self.cedar = cedar
        self.pine = pine
        self.userID = userID
    }

    var isAvailable: Bool {
        state.courseID.value == nil
    }

    func execute(response: String? = nil, history: [AssistChatMessage] = []) -> AnyPublisher<AssistChatMessage?, any Error> {
        return courses.flatMap { [weak self] courseOptions in
            guard let self = self else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            // When not enrolled in any courses
            if courseOptions.isEmpty {
                return Just<AssistChatMessage?>(
                        .init(
                            botResponse: String(
                                localized: "It doesn't look like you have any courses available. Enroll in a course to get started.",
                                bundle: .horizon
                            )
                        )
                    )
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher(
                )
            }

            // When enrolled in only 1 course
            if let courseID = courseOptions.first?.courseID,
               courseOptions.count == 1 {
                self.state.courseID.accept(courseID)
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            // Ask the user to select a course if multiple courses are available
            guard let response = response, response.isNotEmpty else {
                return initialPrompt(history: history)
            }

            // Select the course from the users response
            return selectCourseFrom(response: response, history: history)
        }
        .eraseToAnyPublisher()
    }

    private func selectCourseFrom(response: String, history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        weak var weakSelf = self
        return courses.flatMap { courseOptions in
            guard let weakSelf = weakSelf else {
                return Just<AssistChatMessage?>(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            let courseNames = courseOptions.compactMap {
                $0.course.name.map { AssistGoalOption(name: $0) }
            }

            return weakSelf.choose(from: courseNames, with: response, using: weakSelf.cedar)
                .map { goalOption in
                    if  let courseSelected = goalOption?.name,
                        let courseID = courseOptions.first(where: { courseSelected.contains($0.course.name ?? "") == true })?.courseID {
                        weakSelf.state.courseID.accept(courseID)
                    }
                    return nil
                }
                .eraseToAnyPublisher()
        }
        .map { _ in nil }
        .eraseToAnyPublisher()
    }

    private func initialPrompt(history: [AssistChatMessage]) -> AnyPublisher<AssistChatMessage?, any Error> {
        let promptFirstTime = String(localized: "Hello! Which course would you like to discuss today?", bundle: .horizon)
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
