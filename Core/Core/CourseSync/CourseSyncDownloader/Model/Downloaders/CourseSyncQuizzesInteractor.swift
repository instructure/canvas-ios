//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import CombineExt
import Foundation

public protocol CourseSyncQuizzesInteractor: CourseSyncContentInteractor {}
public extension CourseSyncQuizzesInteractor {
    var associatedTabType: TabName { .quizzes }
}

public final class CourseSyncQuizzesInteractorLive: CourseSyncQuizzesInteractor, CourseSyncContentInteractor {
    public init() {}

    public func getContent(courseId: String) -> AnyPublisher<Void, Error> {
        Publishers.Zip(
            getCustomColors(courseId: courseId),
            getQuizzes(courseId: courseId)
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    private func getCustomColors(courseId _: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetCustomColors()
        )
        .getEntities()
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    private func getQuizzes(courseId: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetQuizzes(courseID: courseId)
        )
        .getEntities()
        .flatMap {
            $0.publisher
                .filter { $0.quizType != .quizzes_next }
                .flatMap { Self.getQuiz(courseId: courseId, quizId: $0.id) }
                .collect()
        }
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    private static func getQuiz(courseId: String, quizId: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetQuiz(courseID: courseId, quizID: quizId)
        )
        .getEntities()
        .mapToVoid()
        .eraseToAnyPublisher()
    }
}
