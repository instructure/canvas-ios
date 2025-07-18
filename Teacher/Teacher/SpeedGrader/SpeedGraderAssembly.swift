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

import Combine
import Core
import UIKit
import SwiftUI

enum SpeedGraderAssembly {

    static func makeSpeedGraderViewController(
        context: Context,
        assignmentId: String,
        userId: String?,
        filter: [GetSubmissions.Filter],
        env: AppEnvironment
    ) -> UIViewController {
        let normalizedUserId = SpeedGraderUserIdNormalization.normalizeUserId(userId)
        let gradeStatusInteractor = GradeStatusInteractorLive(
            courseId: context.id,
            assignmentId: assignmentId,
            api: env.api
        )
        let submissionWordCountInteractor = SubmissionWordCountInteractorLive(assignmentId: assignmentId, api: env.api)
        let customGradebookColumnsInteractor = CustomGradebookColumnsInteractorLive(courseId: context.id)
        let interactor = SpeedGraderInteractorLive(
            context: context,
            assignmentID: assignmentId,
            userID: normalizedUserId,
            filter: filter,
            gradeStatusInteractor: gradeStatusInteractor,
            submissionWordCountInteractor: submissionWordCountInteractor,
            customGradebookColumnsInteractor: customGradebookColumnsInteractor,
            env: env
        )
        let viewModel = SpeedGraderScreenViewModel(
            interactor: interactor,
            environment: env
        )
        let view = SpeedGraderScreen(
            viewModel: viewModel
        )
        return CoreHostingController(view)
    }

    static func makePageViewModel(
        assignment: Assignment,
        submission: Submission,
        contextColor: AnyPublisher<Color, Never>,
        gradeStatusInteractor: GradeStatusInteractor,
        submissionWordCountInteractor: SubmissionWordCountInteractor,
        customGradebookColumnsInteractor: CustomGradebookColumnsInteractor,
        env: AppEnvironment
    ) -> SpeedGraderPageViewModel {
        let rubricGradingInteractor = RubricGradingInteractorLive(
            assignment: assignment,
            submission: submission
        )

        let gradeInteractor = GradeInteractorLive(
            assignment: assignment,
            submission: submission,
            rubricGradingInteractor: rubricGradingInteractor,
            env: env
        )

        return SpeedGraderPageViewModel(
            assignment: assignment,
            latestSubmission: submission,
            contextColor: contextColor,
            studentAnnotationViewModel: .init(submission: submission),
            gradeViewModel: .init(
                assignment: assignment,
                submission: submission,
                gradeInteractor: gradeInteractor
            ),
            gradeStatusViewModel: .init(
                userId: submission.userID,
                submissionId: submission.id,
                attempt: submission.attempt,
                interactor: gradeStatusInteractor
            ),
            commentListViewModel: SubmissionCommentsAssembly.makeCommentListViewModel(
                assignment: assignment,
                latestSubmission: submission,
                latestAttemptNumber: submission.attempt,
                contextColor: contextColor,
                env: env
            ),
            rubricsViewModel: .init(
                assignment: assignment,
                submission: submission,
                interactor: rubricGradingInteractor
            ),
            submissionWordCountViewModel: .init(
                userId: submission.userID,
                attempt: submission.attempt,
                interactor: submissionWordCountInteractor
            ),
            studentNotesViewModel: .init(
                userId: submission.userID,
                interactor: customGradebookColumnsInteractor
            )
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

        let viewModel = SpeedGraderScreenViewModel(
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

    static func testData() -> SpeedGraderData {
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
