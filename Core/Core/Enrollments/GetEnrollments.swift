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

class GetEnrollments: CollectionUseCase {
    typealias Model = Enrollment

    let cacheKey: String?
    let context: Context
    let gradingPeriodID: String?
    let request: GetEnrollmentsRequest
    let scope: Scope

    init(
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
            NSPredicate(format: "%K != nil", #keyPath(Enrollment.id)),
        ]
        if let id = userID {
            predicates.append(NSPredicate(key: #keyPath(Enrollment.userID), equals: id))
        }
        scope = Scope(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), order: [])

        var url = URLComponents()
        url.queryItems = request.queryItems
        cacheKey = "\(request.path)?\(url.query ?? "")"
    }

    func write(response: [APIEnrollment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.forEach { item in
            let enrollment: Enrollment = client.first(where: #keyPath(Enrollment.id), equals: item.id!.rawValue) ?? client.insert()
            enrollment.update(fromApiModel: item, course: nil, gradingPeriodID: gradingPeriodID, in: client)
        }
    }
}
