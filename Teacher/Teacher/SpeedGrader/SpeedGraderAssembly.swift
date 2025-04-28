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

enum SpeedGraderAssembly {

    static func makeSpeedGraderViewController(
        context: Context,
        assignmentID: String,
        userID: String?,
        env: AppEnvironment,
        filter: [GetSubmissions.Filter]
    ) -> UIViewController {
        let normalizedUserId = SpeedGraderViewController.normalizeUserID(userID)
        let interactor = SpeedGraderInteractorLive(
            context: context,
            assignmentID: assignmentID,
            userID: normalizedUserId,
            filter: filter,
            env: env
        )
        let viewModel = SpeedGraderViewModel(
            interactor: interactor,
            environment: env
        )
        let view = SpeedGraderScreen(
            viewModel: viewModel
        )
        return CoreNavigationController(
            rootViewController: CoreHostingController(view)
        )
    }

#if DEBUG

    static func makeSpeedGraderViewControllerPreview(
        state: SpeedGraderInteractorState
    ) -> UIViewController {
        let interactor = SpeedGraderInteractorPreview(
            state: state
        )
        if case .data = state {
            interactor.data = testData()
        }

        let viewModel = SpeedGraderViewModel(
            interactor: interactor,
            environment: .shared
        )
        let view = SpeedGraderScreen(
            viewModel: viewModel
        )
        return CoreNavigationController(
            rootViewController: CoreHostingController(view)
        )
    }

    private static func testData() -> SpeedGraderData {
        let context = PreviewEnvironment().database.viewContext
        let assignment = Assignment.save(.make(), in: context, updateSubmission: false, updateScoreStatistics: false)
        let submission1 = Submission.save(.make(id: "1", user: .make(name: "User 1")), in: context)
        let submission2 = Submission.save(.make(id: "2", user: .make(name: "User 2")), in: context)
        return SpeedGraderData(
            assignment: assignment,
            submissions: [submission1, submission2],
            focusedSubmissionIndex: 1
        )
    }

#endif
}
