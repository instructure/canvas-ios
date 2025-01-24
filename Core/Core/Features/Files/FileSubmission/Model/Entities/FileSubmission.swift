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
    @NSManaged public var assignmentName: String
    /** The user entered comment for the submission. **/
    @NSManaged public var comment: String?
    @NSManaged public var isGroupComment: Bool
    @NSManaged public var files: Set<FileUploadItem>
    @NSManaged public var isHiddenOnDashboard: Bool

    // MARK: - Submission Result

    /** The description of the error happened during submission. */
    @NSManaged public var submissionError: String?
    @NSManaged public var isSubmitted: Bool
}
