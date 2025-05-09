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
    func getCoursesAndModules(ignoreCache: Bool) -> AnyPublisher<[HCourse], Never>
    func getCourseAndModules(id: String, ignoreCache: Bool) -> AnyPublisher<HCourse?, Never>
    func getCourses(ignoreCache: Bool) -> AnyPublisher<[DashboardCourse], Never>
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

    func getCoursesAndModules(ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        fetchCourses(ignoreCache: ignoreCache)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func getCourseAndModules(id: String, ignoreCache: Bool) -> AnyPublisher<HCourse?, Never> {
        fetchCourses(courseId: id, ignoreCache: ignoreCache)
            .map { $0.first }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func getCourses(ignoreCache: Bool) -> AnyPublisher<[DashboardCourse], Never> {
        unowned let unownedSelf = self

        return NotificationCenter.default
            .publisher(for: .moduleItemRequirementCompleted)
            .prepend(.init(name: .moduleItemRequirementCompleted))
            .delay(for: .milliseconds(500), scheduler: scheduler)
            .flatMapLatest {
                let shouldIgnoreCache = $0.object != nil ? true : ignoreCache
                return ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: unownedSelf.userId, horizonCourses: true))
                    .getEntities(ignoreCache: shouldIgnoreCache)
                    .replaceError(with: [])
                    .flatMap {
                        $0.publisher
                            .flatMap { $0.mapToDashboardCourse() }
                            .compactMap { $0 }
                            .collect()
                    }
            }
            .map { courses in
                courses.sorted {
                    ($0.learningObjectCardModel != nil) && ($1.learningObjectCardModel == nil)
                }
            }
            .receive(on: scheduler)
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

    // MARK: - Private

    private func fetchCourses(courseId: String? = nil, ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        unowned let unownedSelf = self

        return ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: unownedSelf.userId, courseId: courseId, horizonCourses: true))
            .getEntities(ignoreCache: ignoreCache, keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .flatMap { unownedSelf.fetchModules(dashboardCourses: $0, ignoreCache: ignoreCache) }
            .eraseToAnyPublisher()
    }

    private func fetchModules(dashboardCourses: [CDCourse], ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        let publishers = dashboardCourses.map { $0.fetchModules(ignoreCache: ignoreCache) }
        return publishers.combineLatest().eraseToAnyPublisher()
    }
}

private extension CDCourse {
    func mapToDashboardCourse() -> AnyPublisher<DashboardCourse?, Never> {
        let name = course.name ?? ""
        let progress = completionPercentage / 100.0
        let hasNextModuleItem: Bool = nextModuleID != nil && nextModuleItemID != name
        guard hasNextModuleItem else {
            return Just(
                DashboardCourse(
                    name: name,
                    progress: progress,
                    courseId: courseID,
                    state: state,
                    enrollmentID: enrollmentID,
                    learningObjectCardModel: nil
                )
            )
            .eraseToAnyPublisher()
        }

        let moduleItem = LearningObjectCard(
            moduleTitle: nextModuleName ?? "",
            learningObjectName: nextModuleItemName ?? "",
            type: nextModuleItemType,
            dueDate: nextModuleItemDueDate?.relativeShortDateOnlyString,
            url: URL(string: nextModuleItemURL ?? ""),
            estimatedTime: nextModuleItemEstimatedTime?.toISO8601Duration
        )
        return Just(
            DashboardCourse(
                name: name,
                progress: progress,
                courseId: courseID,
                state: state,
                enrollmentID: enrollmentID,
                learningObjectCardModel: moduleItem
            )
        )
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
        .map { [enrollmentID] in
            HCourse(
                id: courseID,
                enrollmentID: enrollmentID,
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
