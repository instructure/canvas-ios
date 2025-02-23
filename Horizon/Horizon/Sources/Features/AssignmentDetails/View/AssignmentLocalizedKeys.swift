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
        }
    }
}
