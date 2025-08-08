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

import Core
import Combine
import CombineSchedulers
import Foundation

protocol GetLearnCoursesInteractor {
    func getFirstCourse(ignoreCache: Bool) -> AnyPublisher<LearnCourse?, Error>
    func getCourses(ignoreCache: Bool) -> AnyPublisher<[LearnCourse], Never>
}

final class GetLearnCoursesInteractorLive: GetLearnCoursesInteractor {
    // MARK: - Properties

    private let userId: String
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        userId: String = AppEnvironment.shared.currentSession?.userID ?? "",
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.userId = userId
        self.scheduler = scheduler
    }

    func getFirstCourse(ignoreCache: Bool) -> AnyPublisher<LearnCourse?, any Error> {
        ReactiveStore(useCase: GetHLearnCoursesUseCase(userId: userId))
            .getEntities(ignoreCache: ignoreCache)
            .map { $0.first }
            .map { LearnCourse(from: $0) }
            .eraseToAnyPublisher()
    }

    func getCourses(ignoreCache: Bool) -> AnyPublisher<[LearnCourse], Never> {
        ReactiveStore(useCase: GetHLearnCoursesUseCase(userId: userId))
            .getEntities()
            .replaceError(with: [])
            .flatMap {
                $0.publisher
                    .map { LearnCourse(from: $0) }
                    .compactMap { $0 }
                    .collect()
            }
            .eraseToAnyPublisher()
    }
}
