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

public class GetSubmissions: CollectionUseCase {
    public typealias Model = Submission
    public typealias Response = Request.Response

    public let context: Context
    public let assignmentID: String
    public var shuffled: Bool

    public var filter: Filter?
    public var sortMode: SortMode

    public init(
        context: Context,
        assignmentID: String,
        shuffled: Bool = false,
        filter: Filter? = nil,
        sortMode: SortMode = .studentSortableName
    ) {
        self.assignmentID = assignmentID
        self.context = context
        self.shuffled = shuffled
        self.filter = filter
        self.sortMode = sortMode
    }

    public var cacheKey: String? {
        "\(context.pathComponent)/assignments/\(assignmentID)/submissions"
    }

    public var request: GetSubmissionsRequest {
        GetSubmissionsRequest(
            context: context,
            assignmentID: assignmentID,
            grouped: true,
            include: GetSubmissionsRequest.Include.allCases
        )
    }

    private var commonScopePredicates: [NSPredicate] {
        [
            NSPredicate(key: #keyPath(Submission.assignmentID), equals: assignmentID),
            NSPredicate(key: #keyPath(Submission.isLatest), equals: true),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "%K.@count == 0", #keyPath(Submission.enrollments)),
                NSPredicate(format: "NONE %K IN %@", #keyPath(Submission.enrollments.stateRaw), ["inactive", "invited"]),
                NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "ANY %K IN %@", #keyPath(Submission.enrollments.stateRaw), ["active"]),
                    NSPredicate(format: "ANY %K != nil", #keyPath(Submission.enrollments.courseSectionID))
                ])
            ])
        ]
    }

    public var scope: Scope {
        var predicates = commonScopePredicates

        if let filterPredicate = filter?.predicate {
            predicates.append(filterPredicate)
        }

        return Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates),
            order: shuffled
                ? [NSSortDescriptor(key: #keyPath(Submission.shuffleOrder), ascending: true)]
                : sortMode.sortDescriptors
        )
    }

    public func reset(context: NSManagedObjectContext) {
        let oldSubmissions: [Submission] = context
            .fetch(
                NSPredicate(key: #keyPath(Submission.assignmentID), equals: assignmentID),
                sortDescriptors: nil
            )
        context.delete(oldSubmissions)
    }
}
