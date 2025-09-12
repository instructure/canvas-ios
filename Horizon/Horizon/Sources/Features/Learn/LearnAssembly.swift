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
        programID: String? = nil,
        course: HCourse? = nil,
        shoudHideTabBar: Bool = false,
        selectedTab: CourseDetailsTabs? = nil
    ) -> UIViewController {
        CoreHostingController(
            makeCourseDetailsView(
                viewModel: makeViewModel(
                    courseID: courseID,
                    enrollmentID: enrollmentID,
                    programID: programID,
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
        programID: String? = nil,
        course: HCourse? = nil,
        selectedTab: CourseDetailsTabs? = nil
    ) -> CourseDetailsViewModel {
        .init(
            router: AppEnvironment.shared.router,
            getCoursesInteractor: makeGetCoursesInteractor(),
            learnCoursesInteractor: GetLearnCoursesInteractorLive(),
            programInteractor: ProgramInteractorLive(programCourseInteractor: ProgramCourseInteractorLive()),
            courseID: courseID,
            enrollmentID: enrollmentID,
            programID: programID,
            course: course,
            selectedTab: selectedTab
        ) { newCourseID, newEnrollmentID in
            ScoresAssembly.makeViewModel(courseID: newCourseID, enrollmentID: newEnrollmentID)
        }
    }

    static func makeCourseDetailsView(
        courseID: String,
        enrollmentID: String,
        programID: String? = nil,
        course: HCourse? = nil
    ) -> CourseDetailsView {
        let viewModel = makeViewModel(
            courseID: courseID,
            enrollmentID: enrollmentID,
            programID: programID,
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
        shoudHideTabBar: Bool = false
    ) -> CourseDetailsView {
        let environment = AppEnvironment.shared
        let showTabBarAndNavigationBar: (Bool) -> Void = { isVisible in
            environment.tabBar(isVisible: shoudHideTabBar ? isVisible : true)
            environment.navigationBar(isVisible: shoudHideTabBar ? isVisible : false)
        }
        let onSwitchToLearnTab: (ProgramSwitcherModel?, WeakViewController) -> Void = { program, viewController in
            environment.switchToLearnTab(with: program, from: viewController)
        }
       return CourseDetailsView(
            viewModel: viewModel,
            isBackButtonVisible: isBackButtonVisible,
            shouldHideTabBar: shoudHideTabBar,
            onShowNavigationBarAndTabBar: showTabBarAndNavigationBar,
            onSwitchToLearnTab: onSwitchToLearnTab
        )
    }

    static func makeLearnView(programID: String? = nil) -> UIViewController {
        let programCourseInteractor = ProgramCourseInteractorLive()
        let interactor = ProgramInteractorLive(programCourseInteractor: programCourseInteractor)
        let router = AppEnvironment.shared.router
        let viewModel = LearnViewModel(
            interactor: interactor,
            learnCoursesInteractor: GetLearnCoursesInteractorLive(),
            router: router,
            programID: programID
        )
        let view = LearnView(
            viewModel: viewModel
        )
        return CoreHostingController(view)
    }
}

extension AppEnvironment {
    fileprivate func switchToLearnTab(
        with program: ProgramSwitcherModel?,
        from viewController: WeakViewController
    ) {
        guard let learnHost = getTabHostingController(at: HorizonTabBarType.learn.index, of: LearnView.self) else {
            return
        }

        switchToTab(at: HorizonTabBarType.learn.index)
        learnHost.rootView.content.viewModel.updateProgram(program)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak router = self.router] in
            router?.popToRoot(from: viewController.value, animated: false)
        }
    }
}
