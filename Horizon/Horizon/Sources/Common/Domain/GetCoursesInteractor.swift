//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import CombineSchedulers
import Core
import Foundation

protocol GetCoursesInteractor {
    func getCourses(ignoreCache: Bool) -> AnyPublisher<[HCourse], Never>
    func getCourse(id: String, ignoreCache: Bool) -> AnyPublisher<HCourse?, Never>
    func getInstitutionName() -> AnyPublisher<String, Never>
    func getDashboardCourses(ignoreCache: Bool) -> AnyPublisher<[DashboardCourse], Never>
    func refreshModuleItemsUponCompletions() -> AnyPublisher<Void, Never>
}

final class GetCoursesInteractorLive: GetCoursesInteractor {
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

    // MARK: - Functions

    func getCourses(ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        fetchCourses(ignoreCache: ignoreCache)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func getCourse(id: String, ignoreCache: Bool) -> AnyPublisher<HCourse?, Never> {
        fetchCourses(courseId: id, ignoreCache: ignoreCache)
            .map { $0.first }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func getInstitutionName() -> AnyPublisher<String, Never> {
        ReactiveStore(useCase: GetDashboardCoursesWithProgressionsUseCase(userId: userId))
            .getEntities()
            .replaceError(with: [])
            .compactMap { $0.first?.institutionName }
            .eraseToAnyPublisher()
    }

    func refreshModuleItemsUponCompletions() -> AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: .moduleItemRequirementCompleted)
            .compactMap { $0.object as? ModuleItemAttributes }
            .flatMap {
                ReactiveStore(
                    useCase: GetModuleItem(
                        courseID: $0.courseID,
                        moduleID: $0.moduleID,
                        itemID: $0.itemID
                    )
                )
                .getEntities(ignoreCache: true)
            }
            .replaceError(with: [])
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func getDashboardCourses(ignoreCache _: Bool) -> AnyPublisher<[DashboardCourse], Never> {
        unowned let unownedSelf = self

        return NotificationCenter.default
            .publisher(for: .moduleItemRequirementCompleted)
            .prepend(.init(name: .moduleItemRequirementCompleted))
            .delay(for: .milliseconds(500), scheduler: scheduler)
            .map { _ in () }
            .flatMapLatest {
                ReactiveStore(useCase: GetDashboardCoursesWithProgressionsUseCase(userId: unownedSelf.userId))
                    .getEntities(ignoreCache: true)
                    .replaceError(with: [])
                    .flatMap {
                        $0.publisher
                            .flatMap { $0.fetchNextUpModuleItems() }
                            .compactMap { $0 }
                            .collect()
                    }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func fetchCourses(courseId: String? = nil, ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        unowned let unownedSelf = self

        return ReactiveStore(useCase: GetDashboardCoursesWithProgressionsUseCase(userId: unownedSelf.userId, courseId: courseId))
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap { unownedSelf.fetchModules(dashboardCourses: $0, ignoreCache: ignoreCache) }
            .eraseToAnyPublisher()
    }

    private func fetchModules(dashboardCourses: [CDDashboardCourse], ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        let publishers = dashboardCourses.map { $0.fetchModules(ignoreCache: ignoreCache) }
        return publishers.combineLatest().eraseToAnyPublisher()
    }
}

private extension CDDashboardCourse {
    func fetchNextUpModuleItems() -> AnyPublisher<DashboardCourse?, Never> {
        let name = course.name ?? ""
        let progress = completionPercentage / 100.0

        guard let nextModuleID, let nextModuleItemID else {
            return Just(nil)
                .eraseToAnyPublisher()
        }

        return ReactiveStore(
            useCase: GetModuleItem(
                courseID: courseID,
                moduleID: nextModuleID,
                itemID: nextModuleItemID
            )
        )
        .getEntities(ignoreCache: true)
        .replaceError(with: [])
        .compactMap { $0.first }
        .map { HModuleItem(from: $0) }
        .map { item in
            let moduleItem = LearningObjectCard(
                moduleTitle: item.moduleName ?? "",
                learningObjectName: item.title,
                type: item.type?.label,
                dueDate: item.dueAt?.relativeShortDateOnlyString,
                url: item.htmlURL,
                estimatedTime: item.estimatedDurationFormatted
            )

            return DashboardCourse(
                name: name,
                progress: progress,
                learningObjectCardViewModel: moduleItem
            )
        }
        .eraseToAnyPublisher()
    }

    func fetchModules(ignoreCache: Bool) -> AnyPublisher<HCourse, Never> {
        let courseID = courseID
        let institutionName = institutionName
        let name = course.name ?? ""
        let overviewDescription = course.syllabusBody
        let progress = completionPercentage
        let incompleteModule = IncompleteModule(
            moduleId: nextModuleID,
            moduleItemId: nextModuleItemID
        )
        return ReactiveStore(
            useCase: GetModules(
                courseID: courseID,
                includes: GetModulesRequest.Include.allCases
            )
        )
        .getEntities(ignoreCache: ignoreCache, keepObservingDatabaseChanges: true)
        .replaceError(with: [])
        .map {
            HCourse(
                id: courseID,
                institutionName: institutionName ?? "",
                name: name,
                overviewDescription: overviewDescription,
                progress: progress,
                modules: $0.map { HModule(from: $0) },
                incompleteModule: incompleteModule
            )
        }
        .eraseToAnyPublisher()
    }
}
