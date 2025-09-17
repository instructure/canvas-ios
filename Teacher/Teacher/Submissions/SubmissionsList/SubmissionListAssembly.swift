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
import UIKit

public enum SubmissionListAssembly {

    public static func makeViewController(
        env: AppEnvironment,
        context: Context,
        assignmentID: String,
        filter: GetSubmissions.Filter
    ) -> UIViewController {
        let interactor = SubmissionListInteractorLive(context: context, assignmentID: assignmentID, filter: filter, env: env)
        let viewModel = SubmissionListViewModel(interactor: interactor, filter: filter, env: env)
        let view = SubmissionListScreen(viewModel: viewModel)
        return CoreHostingController(view, env: env)
    }

#if DEBUG

    public static func makeFilterScreenPreview() -> UIViewController {
        let env = PreviewEnvironment()
        let context = env.database.viewContext

        let assignment: Assignment = context.insert()
        assignment.gradingType = .points
        assignment.pointsPossible = 5

        let section1: CourseSection = context.insert()
        section1.id = "1"
        section1.name = "Default"
        section1.courseID = "1"

        let section2: CourseSection = context.insert()
        section2.id = "2"
        section2.name = "Performers"
        section2.courseID = "1"

        let section3: CourseSection = context.insert()
        section3.id = "3"
        section3.name = "Explorers"
        section3.courseID = "1"

        let interactor = SubmissionListInteractorPreview(env: env)
        let viewModel = SubmissionListViewModel(
            interactor: interactor,
            filter: .init(statuses: Set(SubmissionStatusFilter.sharedCases)),
            env: env
        )
        let view = SubmissionsFilterScreen(viewModel: viewModel)
        let hostingController = CoreHostingController(view, env: env)
        return CoreNavigationController(rootViewController: hostingController)
    }

#endif
}
