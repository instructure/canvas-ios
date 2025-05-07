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

import Observation
import Combine

@Observable
final class LearnViewModel {
    // MARK: - Outputs

    private(set) var isLoaderVisible: Bool = false
    private(set) var corseID: String?
    private(set) var enrollmentID: String?

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Dependencies

    private let getCoursesInteractor: GetCoursesInteractor

    // MARK: - Init

    init(getCoursesInteractor: GetCoursesInteractor) {
        self.getCoursesInteractor = getCoursesInteractor
    }

    func fetchCourses() {
        isLoaderVisible = true
        getCoursesInteractor.getDashboardCourses(ignoreCache: false)
            .sink { [weak self] courses in
                self?.corseID = courses.first?.courseId
                self?.enrollmentID = courses.first?.enrollmentID
                self?.isLoaderVisible = false
            }
            .store(in: &subscriptions)
    }
}
