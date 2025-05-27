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

    private(set) var course: HCourse
    private(set) var isShowHeader = true
    private(set) var courses: [DropdownMenuItem] = []
    private(set) var selectedCoure: DropdownMenuItem?
    private(set) var isLoaderVisible: Bool = false
    private(set) var overviewDescription = ""

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
    private let learnCoursesInteractor: GetLearnCoursesInteractor
    private var pullToRefreshCancellable: AnyCancellable?

    // MARK: - Init

    /// The course parameter can be provided for immediate display. But doesn't have to be for flexibility, such as deep linking
    init(
        router: Router,
        getCoursesInteractor: GetCoursesInteractor,
        learnCoursesInteractor: GetLearnCoursesInteractor,
        courseID: String,
        enrollmentID: String,
        course: HCourse?
    ) {
        self.router = router
        self.getCoursesInteractor = getCoursesInteractor
        self.learnCoursesInteractor = learnCoursesInteractor
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
            guard let self, self.selectedCoure != selectedCourse else {
                return
            }

            // Needs to cancel refresh api after change the course
            pullToRefreshCancellable?.cancel()
            pullToRefreshCancellable = nil
            isLoaderVisible = true
            selectedTabIndex = 1
            self.selectedCoure = selectedCourse
            getCourse(for: selectedCourse?.id ?? "")
                .sink { [weak self] courseInfo in
                    self?.updateCourse(course: courseInfo.course, syllabus: courseInfo.syllabus)
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
        Publishers.Zip(
            getCourse(for: courseID),
            getCourses()
        )
        .sink { [weak self] courseInfo, courses in
            self?.courses = courses
            self?.updateCourse(course: courseInfo.course, syllabus: courseInfo.syllabus)
            self?.isLoaderVisible = false
        }
        .store(in: &subscriptions)
    }

    private func getCourses() -> AnyPublisher<[DropdownMenuItem], Never> {
        learnCoursesInteractor
            .getCourses(ignoreCache: false)
            .flatMap { Publishers.Sequence(sequence: $0) }
            .map { DropdownMenuItem(id: $0.id, name: $0.name) }
            .collect()
            .eraseToAnyPublisher()
    }

    private func getCourse(for id: String) -> AnyPublisher<(course: HCourse?, syllabus: String?), Never> {
        // Should use CombineLatest instead of Zip to track changes to the course
        Publishers.CombineLatest(
            getCoursesInteractor.getCourseWithModules(id: id, ignoreCache: false),
            getCoursesInteractor.getCourseSyllabus(courseID: id)
        )
        .map { (course: $0, syllabus: $1) }
        .eraseToAnyPublisher()
    }

    private func updateCourse(course: HCourse?, syllabus: String?) {
        guard let course, (course.id == selectedCoure?.id || selectedCoure == nil ) else {
            return
        }
        let currentProgress = self.course.progress
        let nextProgress = course.progress
        self.course = course
        self.course.progress = max(nextProgress, currentProgress)
        selectedCoure = .init(id: course.id, name: course.name)
        overviewDescription = syllabus ?? ""
        // Firt tab is 0 -> Overview 1 -> MyProgress
        selectedTabIndex = overviewDescription.isEmpty ? 0 : 1
        isLoaderVisible = false
    }
}

extension Notification.Name {
    static let courseDetailsForceRefreshed = Notification.Name(rawValue: "com.instructure.horizon.course-details-refreshed")
}
