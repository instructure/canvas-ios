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

import Core
import UIKit

final class LearnAssembly {
    static func makeGetCoursesInteractor() -> GetCoursesInteractor {
        GetCoursesInteractorLive()
    }

    static func makeCourseDetailsViewController(
        courseID: String,
        enrollmentID: String,
        course: HCourse? = nil
    ) -> UIViewController {
        let appEnvironment = AppEnvironment.shared
        return CoreHostingController(
            CourseDetailsView(
                viewModel: .init(
                    router: appEnvironment.router,
                    getCoursesInteractor: makeGetCoursesInteractor(),
                    courseID: courseID,
                    enrollmentID: enrollmentID,
                    course: course,
                    onShowTabBar: appEnvironment.tabBar(isVisible:)
                )
            )
        )
    }

    static func makeCourseDetailsView(
        courseID: String,
        enrollmentID: String,
        course: HCourse? = nil
    ) -> CourseDetailsView {
        let appEnvironment = AppEnvironment.shared
        return CourseDetailsView(
            viewModel: .init(
                router: appEnvironment.router,
                getCoursesInteractor: makeGetCoursesInteractor(),
                courseID: courseID,
                enrollmentID: enrollmentID,
                course: course,
                onShowTabBar: appEnvironment.tabBar(isVisible:)
            ),
            isBackButtonVisible: false
        )
    }

    static func makeLearnView() -> UIViewController {
        let viewModel = LearnViewModel(
            interactor: GetLearnCoursesInteractorLive()
        )
        let view = LearnView(viewModel: viewModel)
        return  CoreHostingController(view)
    }
}
