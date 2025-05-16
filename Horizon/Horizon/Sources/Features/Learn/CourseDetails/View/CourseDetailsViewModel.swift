//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@Observable
final class CourseDetailsViewModel {
    // MARK: - Outputs

    private(set) var state: InstUI.ScreenState = .loading
    private(set) var course: HCourse
    private(set) var isShowHeader = true
    private(set) var courses: [DropdownMenuItem] = []
    private(set) var selectedCoure: DropdownMenuItem?
    private(set) var isLoaderVisible: Bool = false

    // MARK: - Inputs

    var onSelectCourse: (DropdownMenuItem?) -> Void = { _ in }
    private(set) var showHeaderPublisher = PassthroughSubject<Bool, Never>()

    // MARK: - Inputs / Outputs

    var selectedTabIndex: Int = 1

    // MARK: - Private

    private let router: Router
    private let courseID: String
    private var subscriptions = Set<AnyCancellable>()
    private let getCoursesInteractor: GetCoursesInteractor
    private var pullToRefreshCancellable: AnyCancellable?

    // MARK: - Init

    /// The course parameter can be provided for immediate display. But doesn't have to be for flexibility, such as deep linking
    init(
        router: Router,
        getCoursesInteractor: GetCoursesInteractor,
        courseID: String,
        enrollmentID: String,
        course: HCourse?,
    ) {
        self.router = router
        self.getCoursesInteractor = getCoursesInteractor
        self.courseID = courseID
        self.course = course ?? .init()
        self.isLoaderVisible = true
        fetchData()
        observeCourseSelection()
        observeHeaderVisiablity()
    }

    // MARK: - Inputs

    @MainActor
    func refresh() async {
        // Let other screens know about pull to refresh action
        NotificationCenter.default.post(name: .courseDetailsForceRefreshed, object: nil)

        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume()
                return
            }
             pullToRefreshCancellable = getCoursesInteractor.getCourseWithModules(id: course.id, ignoreCache: true)
                .first()
                .sink { [weak self] course in
                    continuation.resume()
                    guard let course = course, let self = self else { return }
                    self.course = course
                }
        }
    }

    func didTapBackButton(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func moduleItemDidTap(url: URL, from: WeakViewController) {
        router.route(to: url, from: from)
    }

    // MARK: - Private Functions

    private func observeCourseSelection() {
        onSelectCourse = { [weak self] selectedCourse in
            guard let self else {
                return
            }

            // Needs to cancel refresh api after change the course
            pullToRefreshCancellable?.cancel()
            pullToRefreshCancellable = nil
            isLoaderVisible = true
            selectedTabIndex = 1
            getCourse(for: selectedCourse?.id ?? "")
                .sink { [weak self] _ in
                    self?.isLoaderVisible = false
                }
                .store(in: &subscriptions)
        }
    }

    private func observeHeaderVisiablity() {
        showHeaderPublisher
            .removeDuplicates()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isShowHeader = value
            }
            .store(in: &subscriptions)
    }

    private func fetchData() {
        Publishers.Zip(getCourse(for: courseID), getCourses())
            .sink { [weak self] _, courses in
                self?.courses = courses
                self?.isLoaderVisible = false
            }
            .store(in: &subscriptions)
    }

    private func getCourses() -> AnyPublisher<[DropdownMenuItem], Never> {
        getCoursesInteractor
            .getCoursesWithoutModules(ignoreCache: false)
            .flatMap { Publishers.Sequence(sequence: $0) }
            .map { DropdownMenuItem(id: $0.id, name: $0.name) }
            .collect()
            .eraseToAnyPublisher()
    }

    @discardableResult
    private func getCourse(for id: String) -> AnyPublisher<HCourse, Never> {
        unowned let unownedSelf = self
        return Future<HCourse, Never> { promise in
            unownedSelf.getCoursesInteractor.getCourseWithModules(id: id, ignoreCache: false)
                .sink { [weak self] course in
                    guard let course = course, let self = self else { return }
                    let currentProgress = self.course.progress
                    let nextProgress = course.progress
                    self.course = course
                    self.course.progress = max(nextProgress, currentProgress)
                    self.state = .data
                    self.selectedCoure = .init(id: course.id, name: course.name)
                    // Firt tab is 0 -> Overview 1 -> MyProgress
                    self.selectedTabIndex = course.overviewDescription.isEmpty ? 0 : 1
                    promise(.success(course))
                }
                .store(in: &unownedSelf.subscriptions)
        }.eraseToAnyPublisher()
    }
}

extension Notification.Name {
    static let courseDetailsForceRefreshed = Notification.Name(rawValue: "com.instructure.horizon.course-details-refreshed")
}
