//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Core
import Foundation

struct CoursesResult {
    let allCourses: [Course]
    let invitedCourses: [Course]
}

protocol CoursesInteractor {
    func getCourses() -> AnyPublisher<CoursesResult, Error>
    func acceptInvitation(courseId: String, enrollmentId: String) -> AnyPublisher<Void, Error>
    func declineInvitation(courseId: String, enrollmentId: String) -> AnyPublisher<Void, Error>
}

final class CoursesInteractorLive: CoursesInteractor {
    let useCase = GetAllUserCourses()

    private let env: AppEnvironment
    private let coursesStore: ReactiveStore<GetAllUserCourses>
    private var subscriptions = Set<AnyCancellable>()
    private var inFlightPublisher: AnyPublisher<CoursesResult, Error>?
    private let queue = DispatchQueue(label: "com.instructure.student.coursesInteractor")

    init(env: AppEnvironment = .shared) {
        self.env = env
        self.coursesStore = ReactiveStore(useCase: useCase)
    }

    func getCourses() -> AnyPublisher<CoursesResult, Error> {
        return queue.sync {
            if let existing = inFlightPublisher {
                return existing
            }

            let publisher = coursesStore
                .getEntities(loadAllPages: true)
                .map { courses in
                    let allCourses = courses.filter { !$0.isCourseDeleted }
                    let invitedCourses = allCourses.filter { course in
                        course.enrollments.hasInvitedEnrollment
                    }
                    return CoursesResult(allCourses: allCourses, invitedCourses: invitedCourses)
                }
                .handleEvents(
                    receiveCompletion: { [weak self] _ in
                        self?.clearInFlightPublisher()
                    },
                    receiveCancel: { [weak self] in
                        self?.clearInFlightPublisher()
                    }
                )
                .share()
                .eraseToAnyPublisher()

            inFlightPublisher = publisher
            return publisher
        }
    }

    private func clearInFlightPublisher() {
        queue.async { [weak self] in
            self?.inFlightPublisher = nil
        }
    }

    func acceptInvitation(courseId: String, enrollmentId: String) -> AnyPublisher<Void, Error> {
        handleInvitation(courseId: courseId, enrollmentId: enrollmentId, isAccepted: true)
    }

    func declineInvitation(courseId: String, enrollmentId: String) -> AnyPublisher<Void, Error> {
        handleInvitation(courseId: courseId, enrollmentId: enrollmentId, isAccepted: false)
    }

    private func handleInvitation(courseId: String, enrollmentId: String, isAccepted: Bool) -> AnyPublisher<Void, Error> {
        let request = HandleCourseInvitationRequest(
            courseID: courseId,
            enrollmentID: enrollmentId,
            isAccepted: isAccepted
        )

        return env.api.makeRequest(request)
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

private extension Optional where Wrapped == Set<Enrollment> {

    var hasInvitedEnrollment: Bool {
        self?.contains { $0.state == .invited } ?? false
    }
}
