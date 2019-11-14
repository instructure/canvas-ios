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

import CoreData
import Foundation

public class GetAssignments: CollectionUseCase {
    public enum Sort: String {
        case position, dueAt, name
    }

    public typealias Model = Assignment
    public let courseID: String
    public let sort: Sort
    let include: [GetAssignmentsRequest.Include]
    let updateSubmission: Bool
    let requestQuerySize: Int

    public init(courseID: String, sort: Sort = .position, include: [GetAssignmentsRequest.Include] = [], requestQuerySize: Int = 100) {
        self.courseID = courseID
        self.sort = sort
        self.include = include
        self.updateSubmission = include.contains(.submission)
        self.requestQuerySize = requestQuerySize
    }

    public var cacheKey: String? {
        return "get-\(courseID)-assignments"
    }

    public var request: GetAssignmentsRequest {
        let orderBy: GetAssignmentsRequest.OrderBy
        switch sort {
        case .position, .dueAt:
            orderBy = .position
        case .name:
            orderBy = .name
        }
        return GetAssignmentsRequest(courseID: courseID, orderBy: orderBy, include: include, querySize: requestQuerySize)
    }

    public var scope: Scope {
        switch sort {
        case .dueAt:
            //  this puts nil dueAt at the bottom of the list
            let a = NSSortDescriptor(key: #keyPath(Assignment.dueAtSortNilsAtBottom), ascending: true)
            let b = NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true, selector: #selector(NSString.localizedStandardCompare))
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Assignment.courseID), courseID])
            return Scope(predicate: predicate, order: [a, b])
        case .position:
            return .where(#keyPath(Assignment.courseID), equals: courseID, orderBy: #keyPath(Assignment.position))
        case .name:
            return .where(#keyPath(Assignment.courseID), equals: courseID, orderBy: #keyPath(Assignment.name))
        }
    }

    public func write(response: [APIAssignment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }

        for item in response {
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Assignment.id), item.id.value)
            let model: Assignment = client.fetch(predicate).first ?? client.insert()
            model.update(fromApiModel: item, in: client, updateSubmission: updateSubmission)
        }
    }
}

public class GetSubmittableAssignments: GetAssignments {
    public init(courseID: String) {
        super.init(courseID: courseID, sort: .dueAt)
    }

    public override var scope: Scope {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(Assignment.courseID), courseID),
            NSPredicate(format: "%K == FALSE", #keyPath(Assignment.lockedForUser)),
            NSPredicate(format: "%K == NIL OR %K > %@", #keyPath(Assignment.lockAt), #keyPath(Assignment.lockAt), NSDate()),
            NSPredicate(format: "%K == NIL OR %K <= %@", #keyPath(Assignment.unlockAt), #keyPath(Assignment.unlockAt), NSDate()),
            NSPredicate(format: "%K contains %@", #keyPath(Assignment.submissionTypesRaw), SubmissionType.online_upload.rawValue),
        ])
        //  this puts nil dueAt at the bottom of the list
        let a = NSSortDescriptor(key: #keyPath(Assignment.dueAtSortNilsAtBottom), ascending: true)
        let b = NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true, selector: #selector(NSString.localizedStandardCompare))
        return Scope(predicate: predicate, order: [ a, b ])
    }
}

public class GetAssignmentsForGrades: GetAssignments {

    let groupBy: GroupBy
    let gradingPeriodID: String?

    public enum GroupBy: String {
        case assignmentGroup, dueAt
    }

    public init(courseID: String, gradingPeriodID: String? = nil, groupBy: GroupBy = .dueAt, requestQuerySize: Int = 10) {
        self.groupBy = groupBy
        self.gradingPeriodID = gradingPeriodID
        super.init(courseID: courseID, sort: .dueAt, include: [.observed_users, .submission], requestQuerySize: requestQuerySize)
    }

    public override var scope: Scope {
        switch groupBy {
        case .assignmentGroup:
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Assignment.courseID), courseID)
            let s0 = NSSortDescriptor(key: #keyPath(Assignment.assignmentGroupPosition), ascending: true, selector: nil)
            let s1 = NSSortDescriptor(key: #keyPath(Assignment.dueAt), ascending: true, selector: nil)
            let s2 = NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))

            return Scope(predicate: predicate, order: [s0, s1, s2], sectionNameKeyPath: #keyPath(Assignment.assignmentGroupPosition))
        case .dueAt:
            let a = NSSortDescriptor(key: #keyPath(Assignment.dueAtSortNilsAtBottom), ascending: true)
            let b = NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true, selector: #selector(NSString.localizedStandardCompare))

            let p1 = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Assignment.courseID), courseID])
            var preds: [NSPredicate] = [p1]
            if let gradingPeriodID = gradingPeriodID {
                let p2 = NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Assignment.gradingPeriodID), gradingPeriodID])
                preds.append(p2)
            }
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: preds)
            return Scope(predicate: predicate, order: [a, a, b], sectionNameKeyPath: #keyPath(Assignment.dueAtSortNilsAtBottom))
        }
    }
}
