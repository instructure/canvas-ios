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

import Foundation
import Combine
import Core

class ParentInboxCoursePickerInteractorLive: ParentInboxCoursePickerInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var courses = CurrentValueSubject<[Course], Never>([])
    public var enrollments = CurrentValueSubject<[Enrollment], Never>([])

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let courseListStore: Store<GetCourses>
    private let enrollmentListStore: Store<GetEnrollments>

    public init(env: AppEnvironment) {
        self.courseListStore = env.subscribe(GetCourses())
        self.enrollmentListStore = env.subscribe(GetEnrollments(context: .currentUser))

        StoreState.combineLatest(courseListStore.statePublisher, enrollmentListStore.statePublisher)
            .subscribe(state)
            .store(in: &subscriptions)

        courseListStore
            .allObjects
            .subscribe(courses)
            .store(in: &subscriptions)
        courseListStore.exhaust()

        enrollmentListStore
            .allObjects
            .subscribe(enrollments)
            .store(in: &subscriptions)
        enrollmentListStore.exhaust()
    }

    // MARK: - Inputs
    public func refresh() -> AnyPublisher<[Void], Never> {
        courseListStore.refreshWithFuture(force: true).combineLatest(with: enrollmentListStore.refreshWithFuture(force: true))
    }
}
