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

public class GetAssignments: UseCase {
    public enum Sort: String {
        case position, dueAt, name
    }

    public typealias Model = Assignment
    public let courseID: String
    public let sort: Sort
    let include: [GetAssignmentsRequest.Include]
    let perPage: Int?
    public var cacheKey: String? {
        return "\(Context(.course, id: courseID).pathComponent)/assignments"
    }

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

    public func reset(context: NSManagedObjectContext) {
        let all: [Model] = context.fetch(scope.predicate)
        context.delete(all)
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        environment.api.makeRequest(request, callback: completionHandler)
    }

    public func write(response: [APIAssignment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }

        for item in response {
            Assignment.save(item, in: client, updateSubmission: include.contains(.submission), updateScoreStatistics: include.contains(.score_statistics))
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
            NSPredicate(format: "%K contains %@", #keyPath(Assignment.submissionTypesRaw), SubmissionType.online_upload.rawValue)
        ])
        //  this puts nil dueAt at the bottom of the list
        let a = NSSortDescriptor(key: #keyPath(Assignment.dueAtSortNilsAtBottom), ascending: true)
        let b = NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true, selector: #selector(NSString.localizedStandardCompare))
        return Scope(predicate: predicate, order: [ a, b ])
    }

    public override func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        environment.api.exhaust(request, callback: completionHandler)
    }
}

public class GetAssignment: APIUseCase {
    public typealias Model = Assignment

    public let courseID: String
    public let assignmentID: String
    public let include: [GetAssignmentRequest.GetAssignmentInclude]

    public init(courseID: String, assignmentID: String, include: [GetAssignmentRequest.GetAssignmentInclude] = []) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.include = include
    }

    public var cacheKey: String? {
        return "get-\(courseID)-\(assignmentID)-assignment-\(include.map { $0.rawValue } .sorted().joined())"
    }

    public var request: GetAssignmentRequest {
        return GetAssignmentRequest(courseID: courseID, assignmentID: assignmentID, include: include)
    }

    public var scope: Scope {
        return .where((\Assignment.id).string, equals: assignmentID)
    }

    public func write(response: APIAssignment?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }

        let model: Assignment = client.fetch(scope.predicate).first ?? client.insert()
        let updateSubmission = include.contains(.submission)
        let updateScoreStatistics = include.contains(.score_statistics)
        model.update(fromApiModel: response, in: client, updateSubmission: updateSubmission, updateScoreStatistics: updateScoreStatistics)
    }
}

class UpdateAssignment: APIUseCase {
    typealias Model = Assignment

    let request: PutAssignmentRequest

    init(
        courseID: String,
        assignmentID: String,
        description: String? = nil,
        dueAt: Date?,
        gradingType: GradingType?,
        lockAt: Date?,
        name: String? = nil,
        onlyVisibleToOverrides: Bool? = false,
        overrides: [APIAssignmentOverride]?,
        pointsPossible: Double?,
        published: Bool? = nil,
        unlockAt: Date?
    ) {
        request = PutAssignmentRequest(
            courseID: courseID,
            assignmentID: assignmentID,
            body: .init(assignment: APIAssignmentParameters(
                assignment_overrides: overrides,
                description: description,
                due_at: dueAt,
                grading_type: gradingType,
                lock_at: lockAt,
                name: name,
                only_visible_to_overrides: onlyVisibleToOverrides,
                points_possible: pointsPossible,
                published: published,
                unlock_at: unlockAt
            ))
        )
    }

    var cacheKey: String? { nil }

    func write(response: APIAssignment?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        Assignment.save(item, in: client, updateSubmission: false, updateScoreStatistics: false)
    }
}
