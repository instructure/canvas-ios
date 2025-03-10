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

import Foundation
import UIKit

public enum GradListAssembly {
    public static func makeInteractor(
        courseID: String,
        userID: String?
    ) -> GradeListInteractor {
        GradeListInteractorLive(
            courseID: courseID,
            userID: userID
        )
    }

    public static func makeGradeFilterInteractor(
        appEnvironment: AppEnvironment,
        courseId: String
    ) -> GradeFilterInteractor {
        GradeFilterInteractorLive(
            appEnvironment: appEnvironment,
            courseId: courseId
        )
    }

    public static func makeGradeListViewController(
        env: AppEnvironment,
        courseID: String,
        userID: String?
    ) -> UIViewController {
        let interactor = makeInteractor(
            courseID: courseID,
            userID: userID
        )
        let viewModel = GradeListViewModel(
            interactor: interactor,
            gradeFilterInteractor: makeGradeFilterInteractor(
                appEnvironment: env,
                courseId: courseID
            ),
            router: env.router
        )
        let viewController = CoreHostingController(GradeListView(viewModel: viewModel))
        viewController.defaultViewRoute = .init(url: "/empty")
        return viewController
    }

    public static func makeGradeFilterViewController(
        dependency: GradeFilterViewModel.Dependency,
        gradeFilterInteractor: GradeFilterInteractor
    ) -> UIViewController {
        let viewModel = GradeFilterViewModel(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor
        )
        let view = GradeFilterView(viewModel: viewModel)
        let viewController = CoreHostingController(view)
        return viewController
    }
}
