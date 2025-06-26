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
        filter: [GetSubmissions.Filter]
    ) -> UIViewController {

        if ExperimentalFeature.hideRedesignedSubmissionList.isEnabled {
            return SubmissionListViewController.create(
                env: env,
                context: context,
                assignmentID: assignmentID,
                filter: filter
            )
        } else {
            return makeSubmissionListController(
                env: env,
                context: context,
                assignmentID: assignmentID,
                filter: filter
            )
        }
    }

    private static func makeSubmissionListController(
        env: AppEnvironment,
        context: Context,
        assignmentID: String,
        filter: [GetSubmissions.Filter]
    ) -> UIViewController {
        let filterMode = SubmissionFilterMode.allCases.first(where: { $0.filters == filter }) ?? .all
        let interactor = SubmissionListInteractorLive(context: context, assignmentID: assignmentID, filters: filter, env: env)
        let viewModel = SubmissionListViewModel(interactor: interactor, filterMode: filterMode, env: env)
        let view = SubmissionListScreen(viewModel: viewModel)
        return CoreHostingController(view, env: env)
    }
}
