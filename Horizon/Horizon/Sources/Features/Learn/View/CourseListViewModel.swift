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
import CombineExt
import Core
import Foundation

final class CourseListViewModel: ObservableObject {
    // MARK: - Outputs

    @Published private(set) var state: InstUI.ScreenState = .loading
    @Published private(set) var courses: [CourseListCourse] = []

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private let router: Router

    // MARK: - Init

    init(
        router: Router,
        interactor: GetCoursesInteractor
    ) {
        self.router = router

        unowned let unownedSelf = self

        interactor.getCourses()
            .sink { courseProgressions in
                unownedSelf.courses = courseProgressions.map {
                    CourseListCourse(
                        id: $0.courseID,
                        institutionName: $0.institutionName ?? "",
                        name: $0.course.name ?? "",
                        progress: $0.completionPercentage,
                        progressString: $0.completionPercentage.progressString,
                        progressState: $0.completionPercentage.progressState
                    )
                }
                unownedSelf.state = .data
            }
            .store(in: &subscriptions)
    }

    func routeToCourse(course: CourseListCourse, vc: WeakViewController) {
        router.route(to: "/courses/\(course.id)", userInfo: ["course": course], from: vc)
    }

    struct CourseListCourse: Identifiable {
        let id: String
        let institutionName: String
        let name: String
        let progress: Double
        let progressString: String
        let progressState: String
    }
}

extension Double {
    var progressState: String {
        switch self {
        case 0:
            return "Not Started"
        case 100:
            return "Completed"
        default:
            return "On Track"
        }
    }
    var progressString: String {
        let percentageRound = self.rounded()
        return "\(percentageRound)%"
    }
}
