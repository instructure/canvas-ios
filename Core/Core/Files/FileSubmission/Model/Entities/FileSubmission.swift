//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import CoreData

/**
 This entity encapsulates all the necessary information to submit multiple files to a file upload assignment
 and contains the state of the upload progress.
 */
public final class FileSubmission: NSManagedObject {
    @NSManaged public var courseID: String
    @NSManaged public var assignmentID: String
    /** The user entered comment for the submission. **/
    @NSManaged public var comment: String?
    @NSManaged public var files: Set<FileUploadItem>
    /** The description of the error happened during submission. */
    @NSManaged public var submissionError: String?
    @NSManaged public var isSubmitted: Bool
}

extension FileSubmission {

    public var state: State {
        if isSubmitted {
            return .submitted
        } else if let submissionError = submissionError {
            return .failedSubmission(message: submissionError)
        } else {
            return State(files.map { $0.state })
        }
    }

    /** The sum of file sizes in this submission, in bytes. */
    public var totalSize: Int {
        files.reduce(into: 0) { $0 += $1.bytesToUpload }
    }
}
