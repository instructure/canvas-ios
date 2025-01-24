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

extension AlertThreshold: WriteableModel {
    public typealias JSON = APIAlertThreshold

    @discardableResult
    public static func save(_ item: APIAlertThreshold, in context: NSManagedObjectContext) -> AlertThreshold {
        let model: AlertThreshold = context.first(where: #keyPath(AlertThreshold.id), equals: item.id.value) ?? context.insert()
        model.id = item.id.value
        model.studentID = item.user_id.value
        model.observerID = item.observer_id.value
        model.value = item.threshold.flatMap { UInt($0) }
        model.type = item.alert_type
        return model
    }
}

public class GetAlertThresholds: CollectionUseCase {
    public typealias Model = AlertThreshold
    public typealias Response = Request.Response
    public let studentID: String

    public init(studentID: String) {
        self.studentID = studentID
    }

    public var cacheKey: String? { "get-alertthresholds-\(studentID)" }

    public var scope: Scope { .where(#keyPath(AlertThreshold.studentID), equals: studentID) }

    public var request: GetAlertThresholdRequest {
        return GetAlertThresholdRequest(studentID: studentID)
    }
}

public class RemoveAlertThreshold: CollectionUseCase {
    public typealias Model = AlertThreshold
    public let thresholdID: String

    public init(thresholdID: String) {
        self.thresholdID = thresholdID
    }

    public var cacheKey: String?

    public var request: DeleteAlertThresholdRequest {
        return DeleteAlertThresholdRequest(thresholdID: thresholdID)
    }

    public var scope: Scope { .where(#keyPath(AlertThreshold.id), equals: thresholdID) }

    public func write(response: APIAlertThreshold?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
    }
}

public class CreateAlertThreshold: APIUseCase {
    public typealias Model = AlertThreshold

    public var cacheKey: String?
    public let request: PostAlertThresholdRequest

    public init(userID: String, value: UInt?, alertType: AlertThresholdType) {
        request = PostAlertThresholdRequest(userID: userID, alertType: alertType, value: value)
    }
}

public class UpdateAlertThreshold: APIUseCase {
    public typealias Model = AlertThreshold

    public var cacheKey: String?
    public let request: PutAlertThresholdRequest

    public init(thresholdID: String, value: UInt, alertType: AlertThresholdType) {
        request = PutAlertThresholdRequest(thresholdID: thresholdID, alertType: alertType, value: value)
    }
}
