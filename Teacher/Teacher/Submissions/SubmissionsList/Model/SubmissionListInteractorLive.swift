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

class SubmissionListInteractorLive: SubmissionListInteractor {

    let context: Context
    let assignmentID: String

    private let env: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()
    private var submissionsSubscription: AnyCancellable?

    private var customStatusesStore: ReactiveStore<GetCustomGradeStatuses>
    private var courseStore: ReactiveStore<GetCourse>
    private var courseSectionsStore: ReactiveStore<GetCourseSections>
    private var assignmentStore: ReactiveStore<GetAssignment>
    private var submissionsStore: ReactiveStore<GetSubmissions>?

    private var submissionsSubject = PassthroughSubject<[Submission], Never>()
    private var filterSubject: CurrentValueSubject<GetSubmissions.Filter, Never>

    init(context: Context, assignmentID: String, filter: GetSubmissions.Filter, env: AppEnvironment) {
        self.context = context
        self.assignmentID = assignmentID
        self.filterSubject = CurrentValueSubject<GetSubmissions.Filter, Never>(filter)
        self.env = env

        customStatusesStore = ReactiveStore(
            useCase: GetCustomGradeStatuses(courseID: context.id),
            environment: env
        )

        courseStore = ReactiveStore(
            useCase: GetCourse(courseID: context.id),
            environment: env
        )

        courseSectionsStore = ReactiveStore(
            useCase: GetCourseSections(courseID: context.id),
            environment: env
        )

        assignmentStore = ReactiveStore(
            useCase: GetAssignment(courseID: context.id, assignmentID: assignmentID),
            environment: env
        )

        filterSubject
            .sink { [weak self] filter in
                self?.setupSubmissionsStore(filter)
            }
            .store(in: &subscriptions)

        /// Light loading for custom statuses
        customStatusesStore
            .getEntities()
            .sink()
            .store(in: &subscriptions)
    }

    private func setupSubmissionsStore(_ filter: GetSubmissions.Filter) {
        submissionsStore = ReactiveStore(
            useCase: GetSubmissions(context: context, assignmentID: assignmentID, filter: filter),
            environment: env
        )

        submissionsSubscription?.cancel()
        submissionsSubscription = submissionsStore?
            .getEntities(ignoreCache: true, keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .map { $0.filterOutStudentViewUsers() }
            .sink { [weak self] list in
                self?.submissionsSubject.send(list)
            }
    }

    var assignment: AnyPublisher<Assignment?, Never> {
        assignmentStore
            .getEntities(keepObservingDatabaseChanges: true)
            .map { $0.first }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    var course: AnyPublisher<Course?, Never> {
        courseStore
            .getEntities(keepObservingDatabaseChanges: true)
            .map { $0.first }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    var courseSections: AnyPublisher<[CourseSection], Never> {
        courseSectionsStore
            .getEntities(keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    var submissions: AnyPublisher<[Submission], Never> {
        submissionsSubject.eraseToAnyPublisher()
    }

    var assigneeGroups: AnyPublisher<[AssigneeGroup], Never> {
        assignment
            .flatMap { [weak self] assignment in
                guard let self, let categoryID = assignment?.groupCategoryID else {
                    return Just([AssigneeGroup]()).eraseToAnyPublisher()
                }

                return ReactiveStore(
                    useCase: GetGroupsInCategory(categoryID),
                    environment: self.env
                )
                .getEntities(ignoreCache: true)
                .flatMap({ groups in
                    Publishers
                        .Sequence(sequence: groups)
                        .flatMap { [weak self] group in
                            guard let self else {
                                return Just(AssigneeGroup(group: group))
                                    .eraseToAnyPublisher()
                            }

                            return self
                                .env
                                .api
                                .makeRequest(GetGroupUsersRequest(groupID: group.id))
                                .map { (users: [APIUser], _) in
                                    let userIDs = users.map { $0.id.value }
                                    return AssigneeGroup(group: group, memberIDs: userIDs)
                                }
                                .replaceError(with: AssigneeGroup(group: group))
                                .eraseToAnyPublisher()
                        }
                        .collect()
                })
                .replaceError(with: [])
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func refresh() -> AnyPublisher<Void, Never> {
        return Publishers.Last(
            upstream:
                Publishers.Merge5(
                    customStatusesStore.forceRefresh(),
                    courseStore.forceRefresh(),
                    courseSectionsStore.forceRefresh(),
                    assignmentStore.forceRefresh(),
                    submissionsStore?.forceRefresh() ?? Empty<Void, Never>().eraseToAnyPublisher()
                )
        )
        .eraseToAnyPublisher()
    }

    func applyFilter(_ filter: GetSubmissions.Filter) {
        filterSubject.send(filter)
    }
}

private extension [Submission] {

    func filterOutStudentViewUsers() -> [Submission] {
        var filteredSubmissions = self
        filteredSubmissions.removeAll { submission in
            submission.enrollments.contains { enrollment in
                enrollment.isStudentView
            }
        }
        return filteredSubmissions
    }
}
