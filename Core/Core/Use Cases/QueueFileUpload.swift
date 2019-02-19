//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class QueueFileUpload: OperationSet {
    public init(fileInfo: FileInfo, context: Context, assignmentID: String, userID: String, env: AppEnvironment) {
        let insert = DatabaseOperation(database: env.database) { client in
            let assignmentPredicate = Assignment.scope(forName: .details(assignmentID)).predicate
            guard let assignment: Assignment = client.fetch(assignmentPredicate).first else {
                throw NSError.instructureError(NSLocalizedString("Assignment not found.", bundle: .core, comment: ""))
            }

            let upload: FileUpload = client.insert()
            upload.url = fileInfo.url
            upload.size = fileInfo.size
            upload.context = context

            let fileSubmission = assignment.fileSubmission ?? client.insert()
            fileSubmission.assignment = assignment
            fileSubmission.userID = userID
            fileSubmission.addToFileUploads(upload)
        }
        super.init(operations: [insert])
    }
}
