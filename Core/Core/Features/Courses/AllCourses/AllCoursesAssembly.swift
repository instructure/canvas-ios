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

public enum AllCoursesAssembly {
    public static func makeInteractor(env: AppEnvironment) -> AllCoursesInteractor {
        AllCoursesInteractorLive(
            courseListInteractor: makeCourseListInteractor(),
            groupListInteractor: makeGroupListInteractor(env: env)
        )
    }

    public static func makeCourseListInteractor() -> CourseListInteractor {
        CourseListInteractorLive()
    }

    public static func makeGroupListInteractor(env: AppEnvironment) -> GroupListInteractor {
        let shouldListGroups = (env.app == .student)
        return GroupListInteractorLive(shouldListGroups: shouldListGroups)
    }

    public static func makeCourseListViewController(env: AppEnvironment) -> UIViewController {
        let interactor = makeInteractor(env: env)
        interactor.loadAsync()
        let viewModel = AllCoursesViewModel(interactor)
        return CoreHostingController(AllCoursesView(viewModel: viewModel))
    }

    public static func makeCourseCellViewModel(with item: AllCoursesCellViewModel.Item, env: AppEnvironment) -> AllCoursesCellViewModel {
        AllCoursesCellViewModel(
            item: item,
            offlineModeInteractor: OfflineModeAssembly.make(),
            sessionDefaults: env.userDefaults ?? .fallback,
            app: env.app,
            router: env.router
        )
    }

    #if DEBUG
    private static let environment = PreviewEnvironment()
    private static let viewContext = environment.database.viewContext

    static func makePreview() -> AllCoursesView {
        let currentAPICourse = APICourse.make(id: "1", term: .make(name: "Fall 2020"), is_favorite: true)
        let pastAPICourse = APICourse.make(
            id: "3",
            enrollments: [
                .make(id: "6",
                      course_id: "3",
                      enrollment_state: .completed,
                      type: "TeacherEnrollment",
                      user_id: "1",
                      role: "TeacherEnrollment")
            ]
        )
        let futureAPICourse = APICourse.make(id: "4", name: nil, course_code: "course_code")

        let currentDBCourse = AllCoursesCourseItem(
            from: CDAllCoursesCourseItem.save(currentAPICourse, enrollmentState: .active, in: environment.database.viewContext)
        )
        let pastDBCourse = AllCoursesCourseItem(
            from: CDAllCoursesCourseItem.save(pastAPICourse, enrollmentState: .completed, in: environment.database.viewContext)
        )
        let futureDBCourse = AllCoursesCourseItem(
            from: CDAllCoursesCourseItem.save(futureAPICourse, enrollmentState: .invited_or_pending, in: environment.database.viewContext)
        )

        let selectorInteractor = AllCoursesInteractorPreview(past: [pastDBCourse],
                                                             current: [currentDBCourse],
                                                             future: [futureDBCourse])
        let viewModel = AllCoursesViewModel(selectorInteractor)
        let view = AllCoursesView(viewModel: viewModel)
        return view
    }

    #endif
}
