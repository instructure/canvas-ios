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

import Foundation

public class GetObserverAlerts: CollectionUseCase {
    public typealias Model = ObserverAlert
    public typealias Response = Request.Response

    public let studentID: String
    public init(studentID: String) {
        self.studentID = studentID
    }

    public var cacheKey: String? { "users/self/observer_alerts/\(studentID)" }
    public var request: GetObserverAlertsRequest { GetObserverAlertsRequest(studentID: studentID) }
    public var scope: Scope { Scope(
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(ObserverAlert.userID), equals: studentID),
            NSPredicate(
                format: "%K != %@",
                #keyPath(ObserverAlert.workflowStateRaw),
                ObserverAlertWorkflowState.dismissed.rawValue
            )
        ]),
        orderBy: #keyPath(ObserverAlert.actionDate), ascending: false
    ) }
}

public class MarkObserverAlertRead: APIUseCase {
    public typealias Model = ObserverAlert

    public let alertID: String
    public init(alertID: String) {
        self.alertID = alertID
    }

    public var cacheKey: String? { nil }
    public var request: MarkObserverAlertReadRequest { MarkObserverAlertReadRequest(alertID: alertID) }
    public var scope: Scope { .where(#keyPath(ObserverAlert.id), equals: alertID) }
}

public class DismissObserverAlert: APIUseCase {
    public typealias Model = ObserverAlert

    public let alertID: String
    public init(alertID: String) {
        self.alertID = alertID
    }

    public var cacheKey: String? { nil }
    public var request: DismissObserverAlertRequest { DismissObserverAlertRequest(alertID: alertID) }
    public var scope: Scope { .where(#keyPath(ObserverAlert.id), equals: alertID) }
}
