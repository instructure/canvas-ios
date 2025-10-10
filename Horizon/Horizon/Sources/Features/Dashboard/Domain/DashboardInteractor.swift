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
                    let card1 = course1.learningObjectCardModel
                    let card2 = course2.learningObjectCardModel

                    // Courses without cards go to the end
                    if card1 == nil && card2 == nil {
                        return false
                    }
                    if card1 == nil {
                        return false
                    }
                    if card2 == nil {
                        return true
                    }

                    guard let card1 = card1, let card2 = card2 else {
                        return false
                    }

                    // Completed courses go to the end
                    if card1.isCompleted && !card2.isCompleted {
                        return false
                    }
                    if !card1.isCompleted && card2.isCompleted {
                        return true
                    }

                    // If both completed or both incomplete, sort by completion percentage descending
                    return card1.completionPercentage > card2.completionPercentage
                }
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func refreshModuleItemsUponCompletions() -> AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: .moduleItemRequirementCompleted)
            .delay(for: .milliseconds(500), scheduler: scheduler)
            .flatMapLatest {
                guard let courseId = $0.object as? String else {
                    return Just(()).eraseToAnyPublisher()
                }
                return ReactiveStore(useCase: GetModules(courseID: courseId))
                    .getEntities(ignoreCache: true)
                    .replaceError(with: [])
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func getUnreadInboxMessageCount() -> AnyPublisher<Int, Never> {
        ReactiveStore(useCase: GetConversationsUnreadCount())
            .getEntities(ignoreCache: true)
            .map { $0.first?.count ?? 0 }
            .replaceError(with: 0)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
}
