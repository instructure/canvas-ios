//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Combine
import CombineExt

protocol HCourseSyncScores {
    func getContent(courses: [OfflineCourseItem])
    func cancelRequests()
}

final class HCourseSyncScoresLive: HCourseSyncScores {
    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let userId: String

    // MARK: - Init

    init(userId: String) {
        self.userId = userId
    }

    func getContent(courses: [OfflineCourseItem]) {
        cancelRequests()
        Publishers.Sequence(sequence: courses)
            .flatMap { [weak self] course -> AnyPublisher<Void, Never> in
                guard let self else { return Just(()).eraseToAnyPublisher() }
                return self.getScores(
                    courseID: course.id,
                    enrollmentID: course.enrollmentID
                )
            }
            .collect()
            .mapToVoid()
            .sink()
            .store(in: &subscriptions)
    }

    func getScores(courseID: String, enrollmentID: String) -> AnyPublisher<Void, Never> {
        Publishers.Zip(
            getCourseScore(enrollmentID: enrollmentID),
            getCourse(courseID: courseID)
       )
        .mapToVoid()
        .eraseToAnyPublisher()
    }

   private func getCourseScore(enrollmentID: String) -> AnyPublisher<Void, Never> {
        ReactiveStore(useCase: GetHSubmissionScoresUseCase(userId: userId, enrollmentId: enrollmentID))
            .getEntities()
            .replaceError(with: [])
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func getCourse(courseID: String) -> AnyPublisher<Void, Never> {
        ReactiveStore(
            useCase: GetHScoresCourseUseCase(courseID: courseID)
        )
        .getEntities()
        .replaceError(with: [])
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    func cancelRequests() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
}
