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
        ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: userId))
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

    func getDashboardCourses(ignoreCache: Bool) -> AnyPublisher<[DashboardCourse], Never> {
        unowned let unownedSelf = self

        return NotificationCenter.default
            .publisher(for: .moduleItemRequirementCompleted)
            .prepend(.init(name: .moduleItemRequirementCompleted))
            .delay(for: .milliseconds(500), scheduler: scheduler)
            .map { _ in () }
            .flatMapLatest {
                ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: unownedSelf.userId))
                    .getEntities(ignoreCache: true)
                    .replaceError(with: [])
                    .flatMap {
                        $0.publisher
                            .flatMap { courseProgression -> AnyPublisher<DashboardCourse?, Never> in
                                let courseID = courseProgression.courseID
                                let name = courseProgression.course.name ?? ""
                                let progress = courseProgression.completionPercentage / 100.0
                                let moduleID = courseProgression.nextModuleID
                                let itemID = courseProgression.nextModuleItemID

                                guard let moduleID, let itemID else {
                                    return Just(nil)
                                        .eraseToAnyPublisher()
                                }
                                // The GetCoursesProgressionUseCase does not return all of the module item data.
                                // Currently, we only use all the module item information when requesting a single course.
                                // Should this change in the future, we should update the GraphQL endpoint in GetCourseProgressionUseCase
                                // to return all the module item information required
                                return ReactiveStore(
                                    useCase: GetModuleItem(
                                        courseID: courseID,
                                        moduleID: moduleID,
                                        itemID: itemID
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
                            .compactMap { $0 }
                            .collect()
                    }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func fetchCourses(courseId: String? = nil, ignoreCache: Bool) -> AnyPublisher<[HCourse], Never> {
        unowned let unownedSelf = self

        return ReactiveStore(useCase: GetCoursesProgressionUseCase(userId: unownedSelf.userId, courseId: courseId))
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .flatMap { unownedSelf.fetchModules(courseProgressions: $0, ignoreCache: ignoreCache) }
            .eraseToAnyPublisher()
    }

    private func fetchModules(courseProgressions: [CDCourseProgression], ignoreCache _: Bool) -> AnyPublisher<[HCourse], Never> {
        let publishers = courseProgressions.map { $0.fetchMod() }
        return publishers.combineLatest().eraseToAnyPublisher()
    }
}

extension CDCourseProgression {
    func fetchMod() -> AnyPublisher<HCourse, Never> {
        let courseProgression = self
        let courseID = courseProgression.courseID
        let institutionName = courseProgression.institutionName
        let name = courseProgression.course.name ?? ""
        let overviewDescription = courseProgression.course.syllabusBody
        let progress = courseProgression.completionPercentage
        let incompleteModule = IncompleteModule(
            moduleId: courseProgression.nextModuleID,
            moduleItemId: courseProgression.nextModuleItemID
        )
        return ReactiveStore(
            useCase: GetModules(
                courseID: courseProgression.courseID,
                includes: GetModulesRequest.Include.allCases
            )
        )
        .getEntities(ignoreCache: false, keepObservingDatabaseChanges: true)
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
