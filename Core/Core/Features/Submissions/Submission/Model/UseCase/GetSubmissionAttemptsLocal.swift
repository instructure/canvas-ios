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

public class GetSubmissionAttemptsLocal: LocalUseCase<Submission> {
    public init(assignmentId: String, userId: String) {
        let scope = Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(Submission.assignmentID), equals: assignmentId),
                NSPredicate(key: #keyPath(Submission.userID), equals: userId),
                NSPredicate(format: "%K != nil", #keyPath(Submission.submittedAt))
            ]),
            orderBy: #keyPath(Submission.attempt)
        )
        super.init(scope: scope)
    }
}
