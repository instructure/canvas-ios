//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class GetEnrollments: CollectionUseCase {
    public typealias Model = Enrollment

    public let cacheKey: String?
    public let context: Context
    public let gradingPeriodID: String?
    public let request: GetEnrollmentsRequest
    public let scope: Scope

    public init(
        context: Context,
        userID: String? = nil,
        gradingPeriodID: String? = nil,
        types: [String]? = nil,
        includes: [GetEnrollmentsRequest.Include] = [],
        states: [GetEnrollmentsRequest.State]? = nil,
        roles: [Role]? = nil
    ) {
        self.context = context
        self.gradingPeriodID = gradingPeriodID
        request = GetEnrollmentsRequest(
            context: context,
            userID: userID,
            gradingPeriodID: gradingPeriodID,
            types: types,
            includes: includes,
            states: states,
            roles: roles
        )
        var predicates = [
            NSPredicate(key: #keyPath(Enrollment.canvasContextID), equals: context.canvasContextID),
            NSPredicate(format: "%K != nil", #keyPath(Enrollment.id))
        ]
        if let userID {
            predicates.append(NSPredicate(key: #keyPath(Enrollment.userID), equals: userID))
        }
        scope = Scope(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), order: [])

        var url = URLComponents()
        url.queryItems = request.queryItems
        cacheKey = "\(request.path)?\(url.query ?? "")"
    }

    public func write(response: [APIEnrollment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.forEach { item in
            let enrollment: Enrollment = client.first(where: #keyPath(Enrollment.id), equals: item.id!.rawValue) ?? client.insert()
            enrollment.update(fromApiModel: item, course: nil, gradingPeriodID: gradingPeriodID, in: client)
        }
    }
}

struct GetCourseInvitations: CollectionUseCase {
    typealias Model = Enrollment

    var cacheKey: String? { "users/self/enrollments?state[]=invited" }

    var request: GetEnrollmentsRequest {
        GetEnrollmentsRequest(context: .currentUser, states: [ .invited ])
    }

    var scope: Scope { .where(#keyPath(Enrollment.isFromInvitation), equals: true, orderBy: #keyPath(Enrollment.id)) }

    func write(response: [APIEnrollment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.forEach { item in
            guard let id = item.id?.value, item.course_id != nil else { return }
            let model: Enrollment = client.first(where: #keyPath(Enrollment.id), equals: id) ?? client.insert()
            model.update(fromApiModel: item, course: nil, in: client)
            model.isFromInvitation = true
        }
    }
}

public struct HandleCourseInvitation: APIUseCase {
    public typealias Model = Course

    let courseID: String
    let enrollmentID: String
    let isAccepted: Bool

    public init(
        courseID: String,
        enrollmentID: String,
        isAccepted: Bool
    ) {
        self.courseID = courseID
        self.enrollmentID = enrollmentID
        self.isAccepted = isAccepted
    }

    public var cacheKey: String? { nil }

    public var request: HandleCourseInvitationRequest {
        HandleCourseInvitationRequest(courseID: courseID, enrollmentID: enrollmentID, isAccepted: isAccepted)
    }

    public func write(response: HandleCourseInvitationRequest.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard response?.success == true else { return }
        let enrollment: Enrollment? = client.first(where: #keyPath(Enrollment.id), equals: enrollmentID)
        enrollment?.state = isAccepted ? .active : .rejected
    }
}
