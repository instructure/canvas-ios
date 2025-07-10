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

import Foundation

struct AssignmentConfirmationMessagesAssembly {
    static func makeSubmissionAlertViewModel(
        isSegmentControlVisible: Bool,
        isTextSubmission: Bool,
        onPerformSubmission: @escaping () -> Void
    ) -> SubmissionAlertViewModel {
        SubmissionAlertViewModel(
            title: AssignmentLocalizedKeys.confirmSubmission.title,
            body: makeConfirmationMessage(
                isSegmentControlVisible: isSegmentControlVisible,
                isTextSubmission: isTextSubmission
            ),
            button: .init(title: AssignmentLocalizedKeys.submitAttempt.title, action: onPerformSubmission)
        )
    }

    private static func makeConfirmationMessage(
        isSegmentControlVisible: Bool,
        isTextSubmission: Bool
    ) -> String {
        guard isSegmentControlVisible else {
            return AssignmentLocalizedKeys.confirmationNormalBody.title
        }
        return isTextSubmission
        ? AssignmentLocalizedKeys.submitTextWithUploadFile.title
        : AssignmentLocalizedKeys.submitUploadFileWithText.title
    }

    static func makeDraftAlertViewModel(onDelete: @escaping () -> Void) -> SubmissionAlertViewModel {
        SubmissionAlertViewModel(
            title: AssignmentLocalizedKeys.deleteDraftTitle.title,
            body: AssignmentLocalizedKeys.deleteDraftBody.title,
            button: .init(title: AssignmentLocalizedKeys.deleteDraftTitle.title, action: onDelete)
        )
    }

    static func makeSuccessAlertViewModel(submission: HSubmission?) -> SubmissionAlertViewModel {
        SubmissionAlertViewModel(
            title: AssignmentLocalizedKeys.successfullySubmitted.title,
            body: AssignmentLocalizedKeys.successfullySubmittedBody.title,
            type: .success,
            submission: submission,
            button: .init(title: AssignmentLocalizedKeys.viewSubmission.title) {}
        )
    }
}
