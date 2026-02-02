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

/// Manages course data fetching with request coalescing and cache coordination.
///
/// ## Synchronization Strategy
///
/// This interactor implements request coalescing to optimize network usage and prevent race conditions:
///
/// - **Request Queuing**: Multiple concurrent `getCourses()` calls are queued and served by a single fetch
/// - **Thread Safety**: All state mutations happen on a serial `DispatchQueue` to prevent data races
/// - **Cache Coordination**: If any pending request requires fresh data (`ignoreCache: true`),
///   the fetch bypasses cache and all pending requests receive fresh data
///
/// ## Request Flow
///
/// 1. **getCourses()** creates a `PassthroughSubject` and queues the request
/// 2. **startFetch()** initiates a network fetch if none is in progress
/// 3. **handleFetchResult()** broadcasts results to requests and triggers subsequent fetches if needed
/// 4. **handleFetchCompletion()** broadcasts errors to all pending requests
///
/// ## Cache Behavior
///
/// - Cached request during cached fetch → Receives cached data
/// - Fresh request during cached fetch → Triggers second fetch after first completes
/// - Cached request during fresh fetch → Receives fresh data (upgrades to fresh)
/// - Fresh request during fresh fetch → Receives same fresh data
///
final class CoursesInteractorLive: CoursesInteractor {
    private struct PendingRequest {
        let ignoreCache: Bool
        let subject: PassthroughSubject<CoursesResult, Error>
    }

    let useCase = GetAllUserCourses()
    let env: AppEnvironment

    private let coursesStore: ReactiveStore<GetAllUserCourses>
    private let sortComparator: any SortComparator<Course>
    private var subscriptions = Set<AnyCancellable>()

    /// Queue of requests waiting for fetch completion. Protected by `queue`.
    private var pendingRequests: [PendingRequest] = []
    /// Indicates if a fetch is currently in progress. Protected by `queue`.
    private var isFetching = false
    /// Tracks whether the current fetch bypasses cache. Protected by `queue`.
    private var currentFetchIgnoresCache = false
    /// Serial queue ensuring thread-safe access to mutable state.
    private let queue = DispatchQueue(label: "com.instructure.student.coursesInteractor")

    init(
        env: AppEnvironment = .shared,
        sortComparator: some SortComparator<Course> = InvitedCourseSortComparator()
    ) {
        self.env = env
        self.sortComparator = sortComparator
        self.coursesStore = ReactiveStore(useCase: useCase)
    }

    /// Fetches courses with request coalescing.
    ///
    /// Multiple concurrent calls are queued and may be served by a single network fetch.
    /// If any pending request requires fresh data, all requests receive fresh data.
    ///
    /// - Parameter ignoreCache: Whether to bypass cache and fetch fresh data
    /// - Returns: A publisher emitting course results or an error
    func getCourses(ignoreCache: Bool) -> AnyPublisher<CoursesResult, Error> {
        let subject = PassthroughSubject<CoursesResult, Error>()
        let request = PendingRequest(ignoreCache: ignoreCache, subject: subject)

        queue.async { [weak self] in
            guard let self else {
                subject.send(completion: .failure(NSError(domain: "CoursesInteractor", code: -1)))
                return
            }
            pendingRequests.append(request)

            if !isFetching {
                startFetch()
            }
        }

        return subject.eraseToAnyPublisher()
    }

    /// Initiates a network fetch for all pending requests.
    ///
    /// Determines cache strategy by checking if any pending request requires fresh data.
    /// Must be called on `queue` to ensure thread safety.
    private func startFetch() {
        guard !isFetching else { return }
        isFetching = true

        let shouldIgnoreCache = pendingRequests.contains { $0.ignoreCache }
        currentFetchIgnoresCache = shouldIgnoreCache

        let enrollmentsStore = ReactiveStore(
            useCase: GetEnrollments(
                context: .currentUser,
                states: [.active, .completed, .invited]
            ),
            environment: env
        )

        Publishers.Zip(
            coursesStore.getEntities(ignoreCache: shouldIgnoreCache, loadAllPages: true),
            enrollmentsStore.getEntities(ignoreCache: shouldIgnoreCache, loadAllPages: true)
        )
        .map { [sortComparator] courses, _ in
            let allCourses = courses.filter { !$0.isCourseDeleted }
            let invitedCourses = allCourses
                .filter { course in
                    course.enrollments.hasInvitedEnrollment
                }
                .sorted(using: sortComparator)
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

    /// Broadcasts fetch results to satisfied requests and triggers subsequent fetches if needed.
    ///
    /// Requests are satisfied if:
    /// - The fetch provided fresh data (satisfies all requests)
    /// - The request accepts cached data and fetch provided cached data
    ///
    /// Unsatisfied requests (cached fetch, but request needs fresh data) remain queued
    /// and trigger a new fetch.
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

    /// Broadcasts errors to all pending requests and resets fetch state.
    ///
    /// On fetch failure, all pending requests receive the error and are cleared.
    /// No automatic retry occurs - callers must initiate new requests.
    private func handleFetchCompletion(_ completion: Subscribers.Completion<Error>) {
        if case .failure(let error) = completion {
            queue.async { [weak self] in
                guard let self else { return }

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
        self?.contains { $0.state == .invited && $0.id != nil } ?? false
    }
}
