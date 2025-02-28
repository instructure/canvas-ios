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
    private var enrollments = CurrentValueSubject<[CDInboxEnrollment], Error>([])
    private var enrollmentsStore: ReactiveStore<GetObservedEnrollments>
    private var coursesStore: ReactiveStore<GetCourses>
    private let environment: AppEnvironment

    public init(env: AppEnvironment) {
        enrollmentsStore = ReactiveStore(useCase: GetObservedEnrollments(observerID: env.currentSession?.userID ?? ""))
        coursesStore = ReactiveStore(useCase: GetCourses())
        environment = env

        enrollmentsStore
            .getEntities()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] enrollmentList in
                self?.enrollments.send(enrollmentList)
            })
            .store(in: &subscriptions)

        coursesStore
            .getEntities()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] courseList in
                self?.courses.send(courseList)
            })
            .store(in: &subscriptions)

        Publishers
            .CombineLatest(courses.dropFirst(), enrollments.dropFirst()) // Drop the initial values
            .map { (courseList, enrollmentList) in
                return enrollmentList.compactMap { enrollment -> StudentContextItem? in
                    let course = courseList.first(where: { $0.canvasContextID == enrollment.canvasContextID })
                    guard let course, let studentId = enrollment.observedUserId, let studentName = enrollment.observedUserDisplayName else { return nil }
                    return StudentContextItem(studentId: studentId, studentDisplayName: studentName, course: course)
                }
            }
            .sink(receiveCompletion: { [weak self] _ in
                self?.state.send(.error)
            },
            receiveValue: { [weak self] items in
                self?.state.send(items.isEmpty ? .empty : .data)
                self?.studentContextItems.send(items)
            })
            .store(in: &subscriptions)
    }

    public func refresh() -> AnyPublisher<[Void], Never> {
        coursesStore.forceRefresh().combineLatest(with: enrollmentsStore.forceRefresh())
    }

    func getCourseURL(courseId: String) -> String {
        guard let baseUrl = environment.currentSession?.baseURL else {
            return "/courses/\(courseId)"
        }
        return baseUrl.appending(path: "courses/\(courseId)").absoluteString
    }
}
