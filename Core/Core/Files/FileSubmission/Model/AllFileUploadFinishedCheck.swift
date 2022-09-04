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

import Combine
import CoreData

/**
 This task completes successfully if all files in the given `FileSubmission` have a valid `apiID`.
 */
class AllFileUploadFinishedCheck {
    private let context: NSManagedObjectContext
    private let fileSubmissionID: NSManagedObjectID

    public init(context: NSManagedObjectContext, fileSubmissionID: NSManagedObjectID) {
        self.context = context
        self.fileSubmissionID = fileSubmissionID
    }

    func checkFileUploadFinished() -> Future<Void, Error> {
        Future<Void, Error> { self.checkFileUploadState(promise: $0) }
    }

    private func checkFileUploadState(promise: @escaping Future<Void, Error>.Promise) {
        context.perform { [self] in
            guard let submission = try? context.existingObject(with: fileSubmissionID) as? FileSubmission else {
                promise(.failure(FileSubmissionErrors.SubmissionNotFound()))
                return
            }

            let isAllFileUploadFinished = submission.files.allSatisfy { $0.apiID != nil }
            promise(isAllFileUploadFinished ? .success(()) : .failure(FileSubmissionErrors.NotReady()))
        }
    }
}
