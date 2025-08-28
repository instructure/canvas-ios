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

struct LearnAssembly {
    static func makeGetCoursesInteractor() -> GetCoursesInteractor {
        GetCoursesInteractorLive()
    }

    static func makeCourseDetailsViewController(
        courseID: String,
        enrollmentID: String,
        course: HCourse? = nil,
        shoudHideTabBar: Bool = false,
        selectedTab: CourseDetailsTabs? = nil
    ) -> UIViewController {
        CoreHostingController(
            makeCourseDetailsView(
                viewModel: makeViewModel(
                    courseID: courseID,
                    enrollmentID: enrollmentID,
                    course: course,
                    selectedTab: selectedTab
                ),
                shoudHideTabBar: shoudHideTabBar
            )
        )
    }

    static func makeViewModel(
        courseID: String,
        enrollmentID: String,
        course: HCourse? = nil,
        selectedTab: CourseDetailsTabs? = nil
    ) -> CourseDetailsViewModel {
        .init(
            router: AppEnvironment.shared.router,
            getCoursesInteractor: makeGetCoursesInteractor(),
            learnCoursesInteractor: GetLearnCoursesInteractorLive(),
            courseID: courseID,
            enrollmentID: enrollmentID,
            course: course,
            selectedTab: selectedTab
        ) { newCourseID, newEnrollmentID in
            ScoresAssembly.makeViewModel(courseID: newCourseID, enrollmentID: newEnrollmentID)
        }
    }

    static func makeCourseDetailsView(
        courseID: String,
        enrollmentID: String,
        course: HCourse? = nil
    ) -> CourseDetailsView {
        let viewModel = makeViewModel(
            courseID: courseID,
            enrollmentID: enrollmentID,
            course: course
        )
        return makeCourseDetailsView(
            viewModel: viewModel,
            isBackButtonVisible: false
        )
    }

    static func makeCourseDetailsView(
        viewModel: CourseDetailsViewModel,
        isBackButtonVisible: Bool = true,
        shoudHideTabBar: Bool = false,
    ) -> CourseDetailsView {
        let environment = AppEnvironment.shared
        let showTabBarAndNavigationBar: (Bool) -> Void = { isVisible in
            environment.tabBar(isVisible: shoudHideTabBar ? isVisible : true)
            environment.navigationBar(isVisible: shoudHideTabBar ? isVisible : false)
        }
       return CourseDetailsView(
            viewModel: viewModel,
            isBackButtonVisible: isBackButtonVisible,
            shouldHideTabBar: shoudHideTabBar,
            onShowNavigationBarAndTabBar: showTabBarAndNavigationBar
        )
    }

    static func makeLearnView() -> UIViewController {
        let programCourseInteractor = ProgramCourseInteractorLive()
        let interactor = ProgramInteractorLive(programCourseInteractor: programCourseInteractor)
        let router = AppEnvironment.shared.router
        let viewModel = LearnViewModel(interactor: interactor, router: router)
        let view = LearnView(viewModel: viewModel)
        return CoreHostingController(view)
    }
}
