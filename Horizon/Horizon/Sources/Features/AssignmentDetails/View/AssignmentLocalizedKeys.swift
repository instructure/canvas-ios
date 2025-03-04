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

enum AssignmentLocalizedKeys {
    case submissionText
    case submissionFileUpload
    case addSubmissionText
    case selectSubmissionType
    case newAttempt
    case submitAssignment
    case chooseFile
    case takeMedia
    case selectMedia
    case uploadFile
    case deleteDraft
    case savedAt
    case attemptHistory
    case comments
    case tools
    case emptyAttempt
    case confirmSubmission
    case confirmationNormalBody
    case cancel
    case submitAttempt
    case submitUploadFileWithText
    case submitTextWithUploadFile
    case successfullySubmitted
    case successfullySubmittedBody
    case viewSubmission
    case deleteDraftTitle
    case deleteDraftBody
    case draftDeletedAlert
    case markAsDone
    case done

    var title: String {
        switch self {
        case .submissionText:
            return String(localized: "Your Text Submission", bundle: .horizon)
        case .submissionFileUpload:
            return String(localized: "Your Uploaded Submission", bundle: .horizon)
        case .addSubmissionText:
            return String(localized: "Add your text entry", bundle: .horizon)
        case .selectSubmissionType:
            return String(localized: "Select a Submission Type", bundle: .horizon)
        case .newAttempt:
            return String(localized: "New Attempt", bundle: .horizon)
        case .submitAssignment:
            return String(localized: "Submit Assignment", bundle: .horizon)
        case .chooseFile:
            return String(localized: "Choose File", bundle: .horizon)
        case .takeMedia:
            return String(localized: "Take Photo or Video", bundle: .horizon)
        case .selectMedia:
            return String(localized: "Choose Photo or Video", bundle: .horizon)
        case .uploadFile:
            return String(localized: "Upload File", bundle: .horizon)
        case .deleteDraft:
            return String(localized: "Delete Draft", bundle: .horizon)
        case .savedAt:
            return String(localized: "Saved at ", bundle: .horizon)
        case .attemptHistory:
            return String(localized: "Attempt History", bundle: .horizon)
        case .comments:
            return String(localized: "Comments", bundle: .horizon)
        case .tools:
            return String(localized: "Tools", bundle: .horizon)
        case .emptyAttempt:
            return String(
                localized: "This assignment allows multiple attempts. Once you've made a submission, you can view it here.",
                bundle: .horizon
            )
        case .confirmSubmission:
            return String(localized: "Confirm Submission", bundle: .horizon)
        case .confirmationNormalBody:
            return String(localized: "Once you submit this attempt, you won’t be able to make any changes.", bundle: .horizon)
        case .cancel:
            return String(localized: "Cancel", bundle: .horizon)
        case .submitAttempt:
            return String(localized: "Submit Attempt", bundle: .horizon)
        case .submitUploadFileWithText:
            return String(
                localized: "You are submitting an uploaded file. Any content in the text field will be deleted upon submission. Once you submit this attempt, you won’t be able to make any changes.",
                bundle: .horizon
            )
        case .submitTextWithUploadFile:
            return String(
                localized: "You are submitting a text-based attempt. Any uploaded files will be deleted upon submission. Once you submit this attempt, you won’t be able to make any changes.",
                bundle: .horizon
            )
        case .successfullySubmitted:
            return String(localized: "Assignment Successfully Submitted!", bundle: .horizon)
        case .successfullySubmittedBody:
            return String(localized: "We received your submission. You will be notified once it's been reviewed.", bundle: .horizon)
        case .viewSubmission:
            return String(localized: "View Submission", bundle: .horizon)
        case .deleteDraftTitle:
            return String(localized: "Delete Draft", bundle: .horizon)
        case .deleteDraftBody:
            return String(localized: "Once deleted, this draft cannot be recovered.", bundle: .horizon)
        case .draftDeletedAlert:
            return String(localized: "Your draft was deleted.", bundle: .horizon)
        case .markAsDone:
            return String(localized: "Mark as Done", bundle: .horizon)
        case .done:
            return String(localized: "Done", bundle: .horizon)
        }
    }
}
