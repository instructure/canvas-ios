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
import Observation

@Observable
final class CourseListViewModel {
    // MARK: - Outputs
    private(set) var filteredCourses: [CourseCardModel] = []
    private(set) var isSeeMoreButtonVisible: Bool = false

    // MARK: - Private Properties

    private var allCourses: [CourseCardModel]
    private var paginatedCourses: [[CourseCardModel]] = []
    private var totalPages = 0
    private var currentPage = 0 {
        didSet {
            isSeeMoreButtonVisible = currentPage < totalPages - 1
        }
    }

    // MARK: - Dependencies
    private let router: Router
    private let onTapProgram: (ProgramSwitcherModel?, WeakViewController) -> Void

    // MARK: - Init
    init(
        courses: [CourseCardModel],
        router: Router,
        onTapProgram: @escaping (ProgramSwitcherModel?, WeakViewController) -> Void
    ) {
        self.allCourses = courses
        self.router = router
        self.onTapProgram = onTapProgram

        setupPagination(with: courses)
    }

    // MARK: - Pagination Setup
    private func setupPagination(with courses: [CourseCardModel]) {
        paginatedCourses = courses.chunked(into: 10)
        totalPages = paginatedCourses.count
        currentPage = 0
        filteredCourses = paginatedCourses.first ?? []
        isSeeMoreButtonVisible = totalPages > 1
    }

    // MARK: - Input Actions

    func filter(status: CourseCardModel.CourseStatus) {
        let filtered: [CourseCardModel]
        switch status {
        case .all:
            filtered = allCourses
        case .completed:
            filtered = allCourses.filter { $0.status == .completed }
        case .notStarted:
            filtered = allCourses.filter { $0.status == .notStarted }
        case .inProgress:
            filtered = allCourses.filter { $0.status == .inProgress }
        }

        setupPagination(with: filtered)
    }

    func seeMore() {
        currentPage += 1
        guard currentPage + 1 < totalPages else { return }
        filteredCourses.append(contentsOf: paginatedCourses[currentPage])
    }

    // MARK: - Navigation
    func navigateToCourseDetails(course: CourseCardModel, viewController: WeakViewController) {
        router.show(
            LearnAssembly.makeCourseDetailsViewController(
                courseID: course.id,
                enrollmentID: course.enrollmentID,
                programID: course.firstProgramID
            ),
            from: viewController
        )
    }

    func navigateProgram(id: String, viewController: WeakViewController) {
        onTapProgram(.init(id: id), viewController)
    }
}
