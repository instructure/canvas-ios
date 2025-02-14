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
    public var studentContextItems = CurrentValueSubject<[StudentContextItem], Never>([])

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private var courses = CurrentValueSubject<[Course], Error>([])
    private var enrollments = CurrentValueSubject<[Enrollment], Error>([])

    public init(env: AppEnvironment) {
//        ReactiveStore(
//            useCase: GetEnrollments(
//                context: .currentUser,
//                includes: [.observed_users, .avatar_url],
//                states: GetEnrollmentsRequest.State.allForParentObserver
//            )
//        )
        ReactiveStore(useCase: GetObservedEnrollments(observerID: env.currentSession?.userID ?? ""))
        .getEntities()
        .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] enrollmentList in
            print("ENROLLMENTS")
            print(enrollmentList)
            self?.enrollments.send(enrollmentList)
        })
        .store(in: &subscriptions)

        ReactiveStore(useCase: GetCourses())
            .getEntities()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] courseList in
                print("COURSES")
                print(courseList)
                self?.courses.send(courseList)
            })
            .store(in: &subscriptions)

        Publishers.CombineLatest(courses, enrollments)
            .map { (courseList, enrollmentList) in
                return enrollmentList.compactMap { enrollment -> StudentContextItem? in
                    let course = courseList.first(where: { $0.canvasContextID == enrollment.canvasContextID })
                    let user = enrollment.observedUser
                    guard let course, let user else { return nil }
                    return StudentContextItem(student: user, course: course)
                }
            }
            .sink(receiveCompletion: { [weak self] _ in
                self?.state.send(.error)
            },
            receiveValue: { [weak self] items in
                print("ITEMS")
                print(items)
                self?.studentContextItems.send(items)
            })
            .store(in: &subscriptions)
    }

    // MARK: - Inputs
    public func refresh() -> AnyPublisher<[Void], Never> {
        Future<[Void], Never> {_ in }.eraseToAnyPublisher()
        // courseListStore.refreshWithFuture(force: true).combineLatest(with: enrollmentListStore.refreshWithFuture(force: true))
    }
}
