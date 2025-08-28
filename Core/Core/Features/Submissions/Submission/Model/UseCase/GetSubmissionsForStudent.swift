//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import CoreData

public class GetSubmissionsForStudent: CollectionUseCase {
    public typealias Model = Submission
    public typealias Response = Request.Response

    public let cacheKey: String?
    public let request: GetSubmissionsForStudentRequest
    public var scope: Scope

    init(context: Context, studentID: String) {
        cacheKey = "\(context.pathComponent)/students/\(studentID)/submissions"
        request = GetSubmissionsForStudentRequest(context: context, studentID: studentID)
        scope = Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(Submission.userID), equals: studentID),
                NSPredicate(key: #keyPath(Submission.isLatest), equals: true)
            ]),
            order: [
                NSSortDescriptor(key: #keyPath(Submission.gradedAt), ascending: false, selector: #selector(NSDate.compare(_:)))
            ]
        )
    }
}
