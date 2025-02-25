//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core

public class GetObservedEnrollments: CollectionUseCase {

    public typealias Model = CDInboxEnrollment
    public typealias Response = Request.Response

    let observerID: String

    public init(observerID: String) {
        self.observerID = observerID
    }

    public var cacheKey: String? {
        return "get-observed-enrollments-\(observerID)"
    }

    public var scope: Scope {
        return .where(#keyPath(CDInboxEnrollment.userId), equals: observerID, orderBy: #keyPath(CDInboxEnrollment.id))
    }

    public var request: GetEnrollmentsRequest {
        GetEnrollmentsRequest(
            context: .currentUser,
            includes: [.observed_users, .avatar_url],
            states: GetEnrollmentsRequest.State.allForParentObserver
        )
    }
}
