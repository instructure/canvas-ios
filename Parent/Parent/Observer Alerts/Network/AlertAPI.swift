//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation


import CanvasCore

open class AlertAPI {

    open class func getAlert(_ session: Session, observerID: String, alertID: String) throws -> URLRequest {
        let path = "/alert/\(observerID)/\(alertID)"
        let parameters: [String: Any] = [:]

        return try session.GET(path, parameters: parameters)
    }

    open class func getAlertsForParent(_ session: Session, observerID: String, studentID: String, earliestTimestamp: Date? = nil, latestTimeStamp: Date? = nil) throws -> URLRequest {
        let path = "/alerts/student/\(observerID)/\(studentID)"

        let earlyTimestamp: Double? = (earliestTimestamp?.timeIntervalSince1970 == nil) ? nil : (earliestTimestamp?.timeIntervalSince1970)!*1000
        let lateTimestamp: Double? = (latestTimeStamp?.timeIntervalSince1970 == nil) ? nil : (latestTimeStamp?.timeIntervalSince1970)!*1000
        let nillableParams: [String: Any?] = [
            "earliest_timestamp" : earlyTimestamp,
            "latest_timestamp" : lateTimestamp
        ]

        let parameters = Session.rejectNilParameters(nillableParams)

        return try session.GET(path, parameters: parameters)
    }

    open class func getAlerts(_ session: Session, earliestTimestamp: Date? = nil, latestTimeStamp: Date? = nil) throws -> URLRequest {
        let path = "/alerts/\(session.user.id)"

        let earlyTimestamp: Double? = (earliestTimestamp?.timeIntervalSince1970 == nil) ? nil : (earliestTimestamp?.timeIntervalSince1970)!*1000
        let lateTimestamp: Double? = (latestTimeStamp?.timeIntervalSince1970 == nil) ? nil : (latestTimeStamp?.timeIntervalSince1970)!*1000
        let nillableParams: [String: Any?] = [
            "earliest_timestamp" : earlyTimestamp,
            "latest_timestamp" : lateTimestamp
            ]

        let parameters = Session.rejectNilParameters(nillableParams)

        return try session.GET(path, parameters: parameters)
    }

    open class func updateAlert(_ session: Session, observerID: String, alertID: String, read: Bool? = nil, dismissed: Bool? = nil) throws -> URLRequest {
        let path = "/alert/\(observerID)/\(alertID)"

        let nillableParams: [String: Any?] = [
            "read" : read,
            "dismissed" : dismissed
            ]

        let parameters = Session.rejectNilParameters(nillableParams)

        return try session.POST(path, parameters: parameters, encoding: .url)
    }

}

