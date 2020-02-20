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
    let perPage: Int?
    public var cacheKey: String? {
        return "\(ContextModel(.course, id: courseID).pathComponent)/assignments"
    }

    public var clearsBeforeWrite: Bool { true }

    public init(courseID: String, sort: Sort = .position, include: [GetAssignmentsRequest.Include] = [], perPage: Int? = nil) {
        self.courseID = courseID
        self.sort = sort
        self.include = include
        self.perPage = perPage
    }

    public var request: GetAssignmentsRequest {
        let orderBy: GetAssignmentsRequest.OrderBy
        switch sort {
        case .position, .dueAt:
            orderBy = .position
        case .name:
            orderBy = .name
        }
        return GetAssignmentsRequest(courseID: courseID, orderBy: orderBy, include: include, perPage: perPage)
    }

    public var scope: Scope {
        let order: [NSSortDescriptor]
        switch sort {
        case .dueAt:
            //  this puts nil dueAt at the bottom of the list
            let a = NSSortDescriptor(key: #keyPath(Assignment.dueAtSortNilsAtBottom), ascending: true)
            let b = NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true, selector: #selector(NSString.localizedStandardCompare))
            order = [a, b]
        case .position:
            order = [NSSortDescriptor(key: #keyPath(Assignment.position), ascending: true)]
        case .name:
            order = [NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true)]
        }
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Assignment.courseID), courseID)
        return Scope(predicate: predicate, order: order)
    }

    public func write(response: [APIAssignment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }

        for item in response {
            Assignment.save(item, in: client, updateSubmission: include.contains(.submission))
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

public class GetSyllabusAssignments: GetAssignments {
    public override var clearsBeforeWrite: Bool { false }

    public override var scope: Scope {
        let course = NSPredicate(key: #keyPath(Assignment.courseID), equals: courseID)
        let syllabus = NSPredicate(key: #keyPath(Assignment.syllabus.courseID), equals: courseID)
        let dueAt = NSSortDescriptor(key: #keyPath(Assignment.dueAtSortNilsAtBottom), ascending: true)
        let name = NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true, selector: #selector(NSString.localizedStandardCompare))
        return Scope(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [course, syllabus]), order: [dueAt, name])
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping ([APIAssignment]?, URLResponse?, Error?) -> Void) {
        environment.database.performBackgroundTask { context in
            let syllabus: Syllabus = context.first(where: #keyPath(Syllabus.courseID), equals: self.courseID) ?? context.insert()
            syllabus.courseID = self.courseID
            syllabus.assignments = []
            try? context.save()
            super.makeRequest(environment: environment, completionHandler: completionHandler)
        }
    }

    public override func write(response: [APIAssignment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        let syllabus: Syllabus = client.first(where: #keyPath(Syllabus.courseID), equals: courseID) ?? client.insert()
        syllabus.courseID = courseID
        for item in response {
            let assignment = Assignment.save(item, in: client, updateSubmission: include.contains(.submission))
            assignment.syllabus = syllabus
        }
    }
}
