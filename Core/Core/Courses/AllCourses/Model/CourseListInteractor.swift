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

public protocol CourseListInteractor {
    // MARK: - Outputs

    func getCourses() -> AnyPublisher<
        (
            active: [AllCoursesCourseItem],
            past: [AllCoursesCourseItem],
            future: [AllCoursesCourseItem]
        ),
        Error
    >

    // MARK: - Inputs

    func loadAsync()
    func refresh() -> AnyPublisher<Void, Never>
    func setFilter(_ filter: String) -> AnyPublisher<Void, Never>
}

public class CourseListInteractorLive: CourseListInteractor {
    // MARK: - Dependencies

    private let env: AppEnvironment

    // MARK: - Private properties

    private let activeCoursesStore: ReactiveStore<GetAllCoursesCourseListUseCase>
    private let pastCoursesStore: ReactiveStore<GetAllCoursesCourseListUseCase>
    private let futureCoursesStore: ReactiveStore<GetAllCoursesCourseListUseCase>
    private let searchQuery = CurrentValueSubject<String, Error>("")
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    public init(env: AppEnvironment = .shared) {
        self.env = env

        activeCoursesStore = ReactiveStore(
            useCase: GetAllCoursesCourseListUseCase(enrollmentState: .active)
        )

        pastCoursesStore = ReactiveStore(
            useCase: GetAllCoursesCourseListUseCase(enrollmentState: .completed)
        )

        futureCoursesStore = ReactiveStore(
            useCase: GetAllCoursesCourseListUseCase(enrollmentState: .invited_or_pending)
        )
    }

    public func getCourses() -> AnyPublisher<
        (
            active: [AllCoursesCourseItem],
            past: [AllCoursesCourseItem],
            future: [AllCoursesCourseItem]
        ),
        Error
    > {
        let filterUnpublishedCoursesForStudents: (AppEnvironment.App?, [CDAllCoursesCourseItem]) -> [CDAllCoursesCourseItem] = { app, items in
            if case .student = app {
                return items.filter { $0.isPublished }
            } else {
                return items
            }
        }

        return Publishers.CombineLatest3(
            activeCoursesStore
                .getEntities(keepObservingDatabaseChanges: true)
                .filter(with: searchQuery)
                .map { $0.map { AllCoursesCourseItem.init(from: $0)}},
            pastCoursesStore
                .getEntities(keepObservingDatabaseChanges: true)
                .filter(with: searchQuery)
                .map { $0.map { AllCoursesCourseItem.init(from: $0)}},
            futureCoursesStore
                .getEntities(keepObservingDatabaseChanges: true)
                .map { [env] in filterUnpublishedCoursesForStudents(env.app, $0) }
                .filter(with: searchQuery)
                .map { $0.map { AllCoursesCourseItem.init(from: $0)}}
        )
        .map { ($0.0, $0.1, $0.2) }
        .eraseToAnyPublisher()
    }

    public func loadAsync() {
        activeCoursesStore
            .getEntities()
            .sink()
            .store(in: &subscriptions)

        pastCoursesStore
            .getEntities()
            .sink()
            .store(in: &subscriptions)

        futureCoursesStore
            .getEntities()
            .sink()
            .store(in: &subscriptions)
    }

    public func refresh() -> AnyPublisher<Void, Never> {
        Publishers.CombineLatest3(
            activeCoursesStore.forceRefresh(),
            pastCoursesStore.forceRefresh(),
            futureCoursesStore.forceRefresh()
        )
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    public func setFilter(_ filter: String) -> AnyPublisher<Void, Never> {
        searchQuery.send(filter)
        return Just(()).eraseToAnyPublisher()
    }
}
