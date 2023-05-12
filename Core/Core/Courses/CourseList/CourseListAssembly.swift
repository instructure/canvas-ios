//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public enum CourseListAssembly {

    public static func makeCourseListViewController() -> UIViewController {
        let interactor = CourseListInteractorLive(env: AppEnvironment.shared)
        let viewModel = CourseListViewModel(interactor)
        return CoreHostingController(CourseListView(viewModel: viewModel))
    }

#if DEBUG
    private static let environment = PreviewEnvironment()
    private static let viewContext = environment.database.viewContext

    static func makePreview() -> CourseListView {
        let currentAPICourse = APICourse.make(id: "1", term: .make(name: "Fall 2020"), is_favorite: true)
        let pastAPICourse = APICourse.make(id: "3",
                                           enrollments: [.make(id: "6",
                                                               course_id: "3",
                                                               enrollment_state: .completed,
                                                               type: "TeacherEnrollment",
                                                               user_id: "1",
                                                               role: "TeacherEnrollment"),
                                           ]
        )
        let futureAPICourse = APICourse.make(id: "4", name: nil, course_code: "course_code")

        let currentDBCourse = CourseListItem.save(currentAPICourse, enrollmentState: .active, in: environment.database.viewContext)
        let pastDBCourse = CourseListItem.save(pastAPICourse, enrollmentState: .completed, in: environment.database.viewContext)
        let futureDBCourse = CourseListItem.save(futureAPICourse, enrollmentState: .invited_or_pending, in: environment.database.viewContext)

        let selectorInteractor = CourseListInteractorPreview(past: [pastDBCourse],
                                                     current: [currentDBCourse],
                                                     future: [futureDBCourse])
        let viewModel = CourseListViewModel(selectorInteractor)
        let view = CourseListView(viewModel: viewModel)
        return view
    }

#endif
}
