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
                courses.sorted {
                    // First, prioritize Horizon courses (those with learningObjectCardModel)
                    let lhs = $0.learningObjectCardModel != nil
                    let rhs = $1.learningObjectCardModel != nil
                    
                    if lhs != rhs {
                        return lhs
                    }
                    
                    // Then sort by position if available
                    if let lhsPosition = $0.position, let rhsPosition = $1.position {
                        if lhsPosition != rhsPosition {
                            return lhsPosition < rhsPosition
                        }
                    }
                    
                    // Finally, sort by name for stable ordering
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func refreshModuleItemsUponCompletions() -> AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: .moduleItemRequirementCompleted)
            .delay(for: .milliseconds(500), scheduler: scheduler)
            .flatMapLatest { _ in
                ReactiveStore(useCase: GetHCoursesProgressionUseCase(userId: self.userId, horizonCourses: true))
                    .getEntities(ignoreCache: true)
                    .replaceError(with: [])
                    .map { _ in () }
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func getUnreadInboxMessageCount() -> AnyPublisher<Int, Never> {
        ReactiveStore(useCase: GetConversationUnreadCountUseCase())
            .getEntities(ignoreCache: false)
            .replaceError(with: [])
            .map { $0.first?.count ?? 0 }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
}