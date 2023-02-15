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

public class CourseListInteractorLive: CourseListInteractor {
    // MARK: - Outputs
    public let state = CurrentValueSubject<StoreState, Never>(.loading)
    public let courseList = CurrentValueSubject<CourseListSections, Never>(.init())

    // MARK: - Private State
    private let searchQuery = CurrentValueSubject<String, Never>("")
    private let activeCoursesListStore: Store<GetCourseListCourses>
    private let pastCoursesListStore: Store<GetCourseListCourses>
    private let futureCoursesListStore: Store<GetCourseListCourses>
    private var subscriptions = Set<AnyCancellable>()

    public init(env: AppEnvironment) {
        activeCoursesListStore = env.subscribe(GetCourseListCourses(enrollmentState: .active))
        pastCoursesListStore = env.subscribe(GetCourseListCourses(enrollmentState: .completed))
        futureCoursesListStore = env.subscribe(GetCourseListCourses(enrollmentState: .invited_or_pending))

        Publishers
            .CombineLatest3(activeCoursesListStore.allObjects.filter(with: searchQuery),
                            pastCoursesListStore.allObjects.filter(with: searchQuery),
                            futureCoursesListStore.allObjects.filter(with: searchQuery))
            .map {
                CourseListSections(current: $0.0, past: $0.1, future: $0.2)
            }
            .subscribe(courseList)
            .store(in: &subscriptions)

        StoreState
            .combineLatest(activeCoursesListStore.statePublisher,
                           pastCoursesListStore.statePublisher,
                           futureCoursesListStore.statePublisher)
            .subscribe(state)
            .store(in: &subscriptions)

        activeCoursesListStore.exhaust()
        pastCoursesListStore.exhaust()
        futureCoursesListStore.exhaust()
    }

    // MARK: - Inputs

    public func refresh() -> Future<Void, Never> {
        Future { [weak self] promise in
            guard let self else {
                return promise(.success(()))
            }
            Publishers
                .CombineLatest3(self.activeCoursesListStore.refreshWithFuture(force: true),
                                self.pastCoursesListStore.refreshWithFuture(force: true),
                                self.futureCoursesListStore.refreshWithFuture(force: true))
                .sink { _ in
                    promise(.success(()))
                }
                .store(in: &self.subscriptions)
        }
    }

    public func setFilter(_ filter: String) -> Future<Void, Never> {
        Future { [searchQuery] promise in
            searchQuery.send(filter)
            promise(.success(()))
        }
    }
}
