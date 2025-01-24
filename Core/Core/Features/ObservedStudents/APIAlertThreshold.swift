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

import Foundation

public struct APIAlertThreshold: Codable, Equatable {
    let id: ID
    let observer_id: ID
    let user_id: ID
    let alert_type: AlertThresholdType
    let threshold: String?
}

#if DEBUG
extension APIAlertThreshold {
    public static func make(
    	id: String = "1",
    	observer_id: String = "5",
    	user_id: String = "1",
    	alert_type: AlertThresholdType = .assignmentGradeHigh,
    	threshold: UInt? = 100
    ) -> APIAlertThreshold {
        return APIAlertThreshold(
            id: ID(id),
            observer_id: ID(observer_id),
            user_id: ID(user_id),
            alert_type: alert_type,
            threshold: threshold.flatMap { String($0) }
        )
    }
}
#endif

public struct DeleteAlertThresholdRequest: APIRequestable {
    public typealias Response = APIAlertThreshold

    let thresholdID: String

    public var path: String { "users/self/observer_alert_thresholds/\(thresholdID)" }

    public let method = APIMethod.delete
}

public struct PutAlertThresholdRequest: APIRequestable {
    public typealias Response = APIAlertThreshold

    let thresholdID: String

    init(thresholdID: String, alertType: AlertThresholdType, value: UInt) {
        self.thresholdID = thresholdID
        body = Body(threshold: value, alert_type: alertType)
    }

    public var path: String { "users/self/observer_alert_thresholds/\(thresholdID)" }

    public let method = APIMethod.put

    public let body: Body?

    public struct Body: Codable, Equatable {
        let threshold: UInt
        let alert_type: AlertThresholdType
    }
}

public struct PostAlertThresholdRequest: APIRequestable {
    public typealias Response = APIAlertThreshold

    init(userID: String, alertType: AlertThresholdType, value: UInt?) {
        body = Body(observer_alert_threshold: AlertBody(
            user_id: userID,
            alert_type: alertType,
            threshold: value
        ))
    }

    public var path: String { "users/self/observer_alert_thresholds" }

    public let method = APIMethod.post

    public let body: Body?

    public struct Body: Codable, Equatable {
        let observer_alert_threshold: AlertBody
    }

    public struct AlertBody: Codable, Equatable {
        let user_id: String
        let alert_type: AlertThresholdType
        let threshold: UInt?
    }
}

public struct GetAlertThresholdRequest: APIRequestable {
    public typealias Response = [APIAlertThreshold]

    public let studentID: String

    public var path: String { "users/self/observer_alert_thresholds" }

    public var query: [APIQueryItem] { [
        .perPage(100),
        .value("student_id", studentID)
    ] }
}
