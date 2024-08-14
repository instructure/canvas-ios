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
 This object is responsible for managing submission entries in CoreData.
 */
public class FileSubmissionComposer {
    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    /**
     - returns: The `objectID` of the created `FileSubmission` object.
     */
    public func makeNewSubmission(
        courseId: String,
        assignmentId: String,
        assignmentName: String,
        comment: String?,
        isGroupComment: Bool?,
        files: [URL]
    ) -> NSManagedObjectID {
        var result: NSManagedObjectID!

        context.performAndWait {
            let fileSubmission: FileSubmission = context.insert()
            fileSubmission.courseID = courseId
            fileSubmission.assignmentID = assignmentId
            fileSubmission.assignmentName = assignmentName
            fileSubmission.comment = comment
            fileSubmission.isGroupComment = isGroupComment ?? false
            fileSubmission.files = Set(files.map {
                let item: FileUploadItem = context.insert()
                item.localFileURL = $0
                item.fileSize = $0.lookupFileSize()
                item.bytesToUpload = item.fileSize
                return item
            })
            fileSubmission.isHiddenOnDashboard = false
            try? context.saveAndNotify()
            result = fileSubmission.objectID
        }

        return result
    }

    /**
     Asynchronously removes the `FileSubmissionItem` based on its `objectID` but keeps the item's file at `localFileURL` intact.
     */
    public func deleteItem(itemID: NSManagedObjectID) {
        delete(objectID: itemID)
    }

    /**
     Asynchronously removes the `FileSubmission` based on its `objectID` and all of its items but keeps local files intact.
     */
    public func deleteSubmission(submissionID: NSManagedObjectID) {
        delete(objectID: submissionID)
    }

    private func delete(objectID: NSManagedObjectID) {
        context.perform { [context] in
            guard let item = try? context.existingObject(with: objectID) else { return }
            context.delete(item)
            try? context.saveAndNotify()
        }
    }
}
