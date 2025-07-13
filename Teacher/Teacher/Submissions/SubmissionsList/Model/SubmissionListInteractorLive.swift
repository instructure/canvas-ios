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

    private var courseStore: ReactiveStore<GetCourse>
    private var assignmentStore: ReactiveStore<GetAssignment>
    private var submissionsStore: ReactiveStore<GetSubmissions>?

    private var submissionsSubject = PassthroughSubject<[Submission], Never>()
    private var filtersSubject: CurrentValueSubject<[GetSubmissions.Filter], Never>

    init(context: Context, assignmentID: String, filters: [GetSubmissions.Filter], env: AppEnvironment) {
        self.context = context
        self.assignmentID = assignmentID
        self.filtersSubject = CurrentValueSubject<[GetSubmissions.Filter], Never>(filters)
        self.env = env

        courseStore = ReactiveStore(
            useCase: GetCourse(courseID: env.convertToRootID(context.id)),
            environment: env.root
        )

        assignmentStore = ReactiveStore(
            useCase: GetAssignment(courseID: context.id, assignmentID: assignmentID),
            environment: env
        )

        filtersSubject
            .sink { [weak self] filters in
                self?.setupSubmissionsStore(filters)
            }
            .store(in: &subscriptions)
    }

    private func setupSubmissionsStore(_ filters: [GetSubmissions.Filter] = []) {
        submissionsStore = ReactiveStore(
            useCase: GetSubmissions(context: context, assignmentID: assignmentID, filter: filters),
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

    var submissions: AnyPublisher<[Submission], Never> {
        submissionsSubject.eraseToAnyPublisher()
    }

    func refresh() -> AnyPublisher<Void, Never> {
        return Publishers.Last(
            upstream:
                Publishers.Merge3(
                    courseStore.forceRefresh(),
                    assignmentStore.forceRefresh(),
                    submissionsStore?.forceRefresh() ?? Empty<Void, Never>().eraseToAnyPublisher()
                )
        )
        .eraseToAnyPublisher()
    }

    func applyFilters(_ filters: [GetSubmissions.Filter]) {
        filtersSubject.send(filters)
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
