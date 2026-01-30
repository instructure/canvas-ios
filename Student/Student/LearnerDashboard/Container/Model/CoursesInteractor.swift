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
    func getCourses(ignoreCache: Bool) -> AnyPublisher<CoursesResult, Error>
    func acceptInvitation(courseId: String, enrollmentId: String) -> AnyPublisher<Void, Error>
    func declineInvitation(courseId: String, enrollmentId: String) -> AnyPublisher<Void, Error>
}

final class CoursesInteractorLive: CoursesInteractor {
    let useCase = GetAllUserCourses()

    let env: AppEnvironment
    private let coursesStore: ReactiveStore<GetAllUserCourses>
    private var subscriptions = Set<AnyCancellable>()

    private struct PendingRequest {
        let ignoreCache: Bool
        let subject: PassthroughSubject<CoursesResult, Error>
    }
    private var pendingRequests: [PendingRequest] = []
    private var isFetching = false
    private var currentFetchIgnoresCache = false

    private let queue = DispatchQueue(label: "com.instructure.student.coursesInteractor")

    init(env: AppEnvironment = .shared) {
        self.env = env
        self.coursesStore = ReactiveStore(useCase: useCase)
    }

    func getCourses(ignoreCache: Bool) -> AnyPublisher<CoursesResult, Error> {
        return queue.sync {
            let subject = PassthroughSubject<CoursesResult, Error>()
            let request = PendingRequest(ignoreCache: ignoreCache, subject: subject)
            pendingRequests.append(request)

            if !isFetching {
                startFetch()
            }

            return subject.eraseToAnyPublisher()
        }
    }

    private func startFetch() {
        queue.async { [weak self] in
            guard let self, !isFetching else { return }
            isFetching = true

            let shouldIgnoreCache = pendingRequests.contains { $0.ignoreCache }
            currentFetchIgnoresCache = shouldIgnoreCache

            coursesStore
                .getEntities(ignoreCache: shouldIgnoreCache, loadAllPages: true)
                .map { courses in
                    let allCourses = courses.filter { !$0.isCourseDeleted }
                    let invitedCourses = allCourses.filter { course in
                        course.enrollments.hasInvitedEnrollment
                    }
                    return CoursesResult(allCourses: allCourses, invitedCourses: invitedCourses)
                }
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.handleFetchCompletion(completion)
                    },
                    receiveValue: { [weak self] result in
                        self?.handleFetchResult(result)
                    }
                )
                .store(in: &subscriptions)
        }
    }

    private func handleFetchResult(_ result: CoursesResult) {
        queue.async { [weak self] in
            guard let self else { return }

            let gotFresh = currentFetchIgnoresCache
            var remainingRequests: [PendingRequest] = []

            for request in pendingRequests {
                if gotFresh || !request.ignoreCache {
                    request.subject.send(result)
                    request.subject.send(completion: .finished)
                } else {
                    remainingRequests.append(request)
                }
            }

            pendingRequests = remainingRequests
            isFetching = false
            currentFetchIgnoresCache = false

            if remainingRequests.isNotEmpty {
                startFetch()
            }
        }
    }

    private func handleFetchCompletion(_ completion: Subscribers.Completion<Error>) {
        queue.async { [weak self] in
            guard let self else { return }

            if case .failure(let error) = completion {
                for request in pendingRequests {
                    request.subject.send(completion: .failure(error))
                }
                pendingRequests.removeAll()
                isFetching = false
                currentFetchIgnoresCache = false
            }
        }
    }
}

private extension Optional where Wrapped == Set<Enrollment> {

    var hasInvitedEnrollment: Bool {
        self?.contains { $0.state == .invited } ?? false
    }
}
