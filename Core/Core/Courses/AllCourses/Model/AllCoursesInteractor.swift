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

public protocol AllCoursesInteractor {
    // MARK: - Outputs

    var sections: PassthroughSubject<AllCoursesSections, Error> { get }

    // MARK: - Inputs

    func loadAsync()
    func refresh() -> AnyPublisher<Void, Never>
    func setFilter(_ filter: String) -> AnyPublisher<Void, Never>
}

public class AllCoursesInteractorLive: AllCoursesInteractor {
    // MARK: - Dependencies

    private let courseListInteractor: CourseListInteractor
    private let groupListInteractor: GroupListInteractor

    // MARK: - Outputs

    public let sections = PassthroughSubject<AllCoursesSections, Error>()

    // MARK: - Private State

    private let searchQuery = CurrentValueSubject<String, Never>("")
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    public init(
        courseListInteractor: CourseListInteractor,
        groupListInteractor: GroupListInteractor
    ) {
        self.courseListInteractor = courseListInteractor
        self.groupListInteractor = groupListInteractor

        Publishers.CombineLatest(
            courseListInteractor.getCourses(),
            groupListInteractor.getGroups()
        )
        .map { courses, groups in
            AllCoursesSections(
                courses: .init(
                    current: courses.active,
                    past: courses.past,
                    future: courses.future
                ),
                groups: groups
            )
        }
        .subscribe(sections)
        .store(in: &subscriptions)
    }

    // MARK: - Inputs

    public func loadAsync() {
        courseListInteractor.loadAsync()
        groupListInteractor.loadAsync()
    }

    public func refresh() -> AnyPublisher<Void, Never> {
        Publishers.Zip(
            courseListInteractor.refresh(),
            groupListInteractor.refresh()
        )
        .mapToVoid()
        .first()
        .eraseToAnyPublisher()
    }

    public func setFilter(_ filter: String) -> AnyPublisher<Void, Never> {
        Publishers.Zip(
            courseListInteractor.setFilter(filter),
            groupListInteractor.setFilter(filter)
        )
        .mapToVoid()
        .first()
        .eraseToAnyPublisher()
    }
}
