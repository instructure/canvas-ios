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
    let courseID: String
    private(set) var isLoaderVisible: Bool = false
    let scoresViewModel: ScoresViewModel

    // MARK: - Private

    private let onShowTabBar: (Bool) -> Void
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()
    private let getCoursesInteractor: GetCoursesInteractor
    private var refreshCompletedModuleItemCancellable: AnyCancellable?

    // MARK: - Init

    /// The course parameter can be provided for immediate display. But doesn't have to be for flexibility, such as deep linking
    init(
        router: Router,
        getCoursesInteractor: GetCoursesInteractor,
        courseID: String,
        course: HCourse?,
        onShowTabBar: @escaping (Bool) -> Void
    ) {
        self.router = router
        self.getCoursesInteractor = getCoursesInteractor
        self.courseID = courseID
        self.course = course ?? .init()
        self.onShowTabBar = onShowTabBar
        self.scoresViewModel = ScoresAssembly.makeViewModel(courseID: courseID)
        self.isLoaderVisible = true

        getCoursesInteractor.getCourse(id: courseID, ignoreCache: false)
            .sink { [weak self] course in
                guard let course = course, let self = self else { return }
                let currentProgress = self.course.progress
                let nextProgress = course.progress
                self.course = course
                self.course.progress = max(nextProgress, currentProgress)
                self.state = .data
                self.isLoaderVisible = false
            }
            .store(in: &subscriptions)

        refreshCompletedModuleItemCancellable = getCoursesInteractor.fetchCourseProgression(courseId: courseID)
            .sink { [weak self] progress in
                self?.course.progress = progress
            }
    }

    deinit {
        refreshCompletedModuleItemCancellable?.cancel()
        refreshCompletedModuleItemCancellable = nil
    }

    // MARK: - Inputs

    @MainActor
    func refresh() async {
        // Let other screens know about pull to refresh action
        NotificationCenter.default.post(name: .courseDetailsForceRefreshed, object: nil)

        await withCheckedContinuation { continuation in
            getCoursesInteractor.getCourse(id: courseID, ignoreCache: true)
                .first()
                .sink { [weak self] course in
                    continuation.resume()
                    guard let course = course, let self = self else { return }
                    self.course = course
                }
                .store(in: &subscriptions)
        }
    }

    func moduleItemDidTap(url: URL, from: WeakViewController) {
        router.route(to: url, from: from)
    }

    func showTabBar() {
        onShowTabBar(true)
    }
}

extension Notification.Name {
    static let courseDetailsForceRefreshed = Notification.Name(rawValue: "com.instructure.horizon.course-details-refreshed")
}
