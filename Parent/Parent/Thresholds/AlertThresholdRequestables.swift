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

import Core
import CoreData

public class GetAlertThresholds: CollectionUseCase {
    public typealias Model = Core.AlertThreshold
    public let studentID: String

    public init(studentID: String) {
        self.studentID = studentID
    }

    public var cacheKey: String? {
        return "get-alertthresholds-\(studentID)"
    }

    public var scope: Scope {
        return .where(#keyPath(AlertThreshold.studentID), equals: studentID)
    }

    public var request: GetAlertThresholdRequest {
        return GetAlertThresholdRequest(studentID: studentID)
    }

    public func write(response: [APIAlertThreshold]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        for item in response ?? [] {
            let predicate = NSPredicate(format: "%K == %@", #keyPath(AlertThreshold.id), item.id)
            let a: Core.AlertThreshold = client.fetch(predicate).first ?? client.insert()
            a.id = item.id
            a.studentID = item.user_id
            a.observerID = item.observer_id
            a.threshold = item.threshold
            a.typeRaw = item.alert_type
        }
    }
}

public class RemoveAlertThreshold: CollectionUseCase {
    public typealias Model = Core.AlertThreshold
    public let thresholdID: String

    public init(thresholdID: String) {
        self.thresholdID = thresholdID
    }

    public var cacheKey: String?

    public var request: DeleteAlertThresholdRequest {
        return DeleteAlertThresholdRequest(thresholdID: thresholdID)
    }

    public var scope: Scope {
        return .where(#keyPath(AlertThreshold.id), equals: thresholdID)
    }

    public func write(response: APIAlertThreshold?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
    }
}

public class CreateAlertThreshold: APIUseCase {
    public typealias Model = Core.AlertThreshold
    public let userID: String
    public let value: String?
    public let alertType: AlertThresholdType

    public init(userID: String, value: String?, alertType: AlertThresholdType) {
        self.userID = userID
        self.value = value
        self.alertType = alertType
    }

    public var cacheKey: String?

    public var request: PostAlertThresholdRequest {
        return PostAlertThresholdRequest(userID: userID, alertType: alertType, value: value)
    }

    public func write(response: APIAlertThreshold?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        let predicate = NSPredicate(format: "%K == %@", #keyPath(AlertThreshold.id), item.id)
        let a: Core.AlertThreshold = client.fetch(predicate).first ?? client.insert()
        a.id = item.id
        a.studentID = item.user_id
        a.observerID = item.observer_id
        a.threshold = item.threshold
        a.typeRaw = item.alert_type
    }
}

public class UpdateAlertThreshold: APIUseCase {
    public typealias Model = Core.AlertThreshold
    public let thresholdID: String
    public let value: String
    public let alertType: AlertThresholdType

    public init(thresholdID: String, value: String, alertType: AlertThresholdType) {
        self.thresholdID = thresholdID
        self.value = value
        self.alertType = alertType
    }

    public var cacheKey: String?

    public var request: PutAlertThresholdRequest {
        return PutAlertThresholdRequest(thresholdID: thresholdID, alertType: alertType, value: value)
    }

    public func write(response: APIAlertThreshold?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        let predicate = NSPredicate(format: "%K == %@", #keyPath(AlertThreshold.id), item.id)
        let a: Core.AlertThreshold = client.fetch(predicate).first ?? client.insert()
        a.id = item.id
        a.studentID = item.user_id
        a.observerID = item.observer_id
        a.threshold = item.threshold
        a.typeRaw = item.alert_type
    }
}

public struct DeleteAlertThresholdRequest: APIRequestable {
    public typealias Response = APIAlertThreshold

    let thresholdID: String

    public var path: String { return "users/self/observer_alert_thresholds/\(thresholdID)" }

    public var method: APIMethod {
        return .delete
    }
}

public struct PutAlertThresholdRequest: APIRequestable {
    public typealias Response = APIAlertThreshold

    let thresholdID: String

    init(thresholdID: String, alertType: AlertThresholdType, value: String) {
        self.thresholdID = thresholdID
        self.body = Body(threshold: value, alert_type: alertType.rawValue)
    }

    public var path: String { return "users/self/observer_alert_thresholds/\(thresholdID)" }

    public var method: APIMethod {
        return .put
    }

    public let body: Body?

    public struct Body: Codable, Equatable {
        let threshold: String
        let alert_type: String
    }
}

public struct PostAlertThresholdRequest: APIRequestable {
    public typealias Response = APIAlertThreshold

    init(userID: String, alertType: AlertThresholdType, value: String?) {
        self.body = Body(observer_alert_threshold: AlertBody(user_id: userID, alert_type: alertType.rawValue, threshold: value))
    }

    public var path: String { return "users/self/observer_alert_thresholds" }

    public var method: APIMethod {
        return .post
    }

    public let body: Body?

    public struct Body: Codable, Equatable {
        let observer_alert_threshold: AlertBody
    }

    public struct AlertBody: Codable, Equatable {
        let user_id: String
        let alert_type: String
        let threshold: String?
    }
}

public struct GetAlertThresholdRequest: APIRequestable {
    public typealias Response = [APIAlertThreshold]

    let studentID: String

    public var path: String { return "users/self/observer_alert_thresholds" }

    public var query: [APIQueryItem] {
        return [
            .perPage(99),
            .value("student_id", studentID),
        ]
    }
}
