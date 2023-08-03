//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class GetCourseSyncContextEnrollments: CollectionUseCase {

    public typealias Model = ContextEnrollment

    public var cacheKey: String? { "courseSyncPeopleEnrollments" }
    public let request: GetEnrollmentsRequest
    public let scope: Scope = .all
    private let userID: String

    public init(context: Context, gradingPeriodID: String? = nil, states: [GetEnrollmentsRequest.State]? = nil, userID: String) {
        request = GetEnrollmentsRequest(context: context,
                                        userID: userID,
                                        gradingPeriodID: gradingPeriodID,
                                        states: [ .active ])
        self.userID = userID
    }

    public func write(response: [APIEnrollment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else { return }
        let apiEnrollment = response.first {
            $0.id != nil &&
            $0.enrollment_state == .active &&
            $0.user_id.value == userID
        }
        if let apiEnrollment = apiEnrollment, let id = apiEnrollment.id?.value {
            let databaseContext = AppEnvironment.shared.database.viewContext
            let enrollment: ContextEnrollment = databaseContext.first(where: #keyPath(ContextEnrollment.id), equals: id) ?? databaseContext.insert()
            enrollment.update(fromApiModel: apiEnrollment, course: nil, in: databaseContext)
        }
    }
}
