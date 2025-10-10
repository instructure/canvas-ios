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
import CombineSchedulers
import Core
import Foundation

protocol DashboardInteractor {
    func getAndObserveCoursesWithoutModules(ignoreCache: Bool) -> AnyPublisher<[HCourse], Never>
    func refreshModuleItemsUponCompletions() -> AnyPublisher<Void, Never>
    func getUnreadInboxMessageCount() -> AnyPublisher<Int, Never>
}

final class DashboardInteractorLive: DashboardInteractor {
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

    /// Fetches all courses from graphQL but doesn't fetch modules from the REST api.
    /// In addition, it keeps listening for `moduleItemRequirementCompleted` notifications and makes a new request to graphQL whenever it receives one.
    func getAndObserveCoursesWithoutModules(ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        unowned let unownedSelf = self

        return NotificationCenter.default
            .publisher(for: .moduleItemRequirementCompleted)
            .prepend(.init(name: .moduleItemRequirementCompleted))
            .delay(for: .milliseconds(500), scheduler: scheduler)
            .flatMapLatest {
                let shouldIgnoreCache = $0.object != nil ? true : ignoreCache
                return ReactiveStore(useCase: GetHCoursesProgressionUseCase(userId: unownedSelf.userId, horizonCourses: true))
                    .getEntities(ignoreCache: shouldIgnoreCache)
                    .replaceError(with: [])
                    .flatMap {
                        $0.publisher
                            .map { HCourse(from: $0, modules: nil) }
                            .compactMap { $0 }
                            .collect()
                    }
            }
            .map { courses in
                courses.sorted { course1, course2 in
                    let completion1 = course1.learningObjectCardModel?.completionPercentage ?? 0
                    let completion2 = course2.learningObjectCardModel?.completionPercentage ?? 0
                    let isCompleted1 = completion1 >= 1.0
                    let isCompleted2 = completion2 >= 1.0

                    if isCompleted1 == isCompleted2 {
                        return completion1 > completion2
                    }
                    return !isCompleted1
                }
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    /// It fetches the details, including the modules from the REST API, of the courses that have already been obtained from GraphQL in the previous method
    func refreshModuleItemsUponCompletions() -> AnyPublisher<Void, Never> {
        return NotificationCenter.default
            .publisher(for: .moduleItemRequirementCompleted)
            .map { _ in }
            .eraseToAnyPublisher()
    }

    func getUnreadInboxMessageCount() -> AnyPublisher<Int, Never> {
        let useCase = GetHorizonConversationsUnreadCount()
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: true)
            .replaceError(with: [])
            .compactMap { $0.first?.count }
            .eraseToAnyPublisher()
    }
}
