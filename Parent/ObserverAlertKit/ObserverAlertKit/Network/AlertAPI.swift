
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

import TooLegit
import SoLazy

public class AlertAPI {

    public class func getAlert(session: Session, observerID: String, alertID: String) throws -> NSURLRequest {
        let path = "/alert/\(observerID)/\(alertID)"
        let parameters: [String: AnyObject] = [:]

        return try session.GET(path, parameters: parameters)
    }

    public class func getAlertsForParent(session: Session, observerID: String, studentID: String, earliestTimestamp: NSDate? = nil, latestTimeStamp: NSDate? = nil) throws -> NSURLRequest {
        let path = "/alerts/student/\(observerID)/\(studentID)"

        let earlyTimestamp: Double? = (earliestTimestamp?.timeIntervalSince1970 == nil) ? nil : (earliestTimestamp?.timeIntervalSince1970)!*1000
        let lateTimestamp: Double? = (latestTimeStamp?.timeIntervalSince1970 == nil) ? nil : (latestTimeStamp?.timeIntervalSince1970)!*1000
        let nillableParams: [String: AnyObject?] = [
            "earliest_timestamp" : earlyTimestamp,
            "latest_timestamp" : lateTimestamp
        ]

        let parameters = Session.rejectNilParameters(nillableParams)

        return try session.GET(path, parameters: parameters)
    }

    public class func getAlerts(session: Session, earliestTimestamp: NSDate? = nil, latestTimeStamp: NSDate? = nil) throws -> NSURLRequest {
        let path = "/alerts/\(session.user.id)"

        let earlyTimestamp: Double? = (earliestTimestamp?.timeIntervalSince1970 == nil) ? nil : (earliestTimestamp?.timeIntervalSince1970)!*1000
        let lateTimestamp: Double? = (latestTimeStamp?.timeIntervalSince1970 == nil) ? nil : (latestTimeStamp?.timeIntervalSince1970)!*1000
        let nillableParams: [String: AnyObject?] = [
            "earliest_timestamp" : earlyTimestamp,
            "latest_timestamp" : lateTimestamp
            ]

        let parameters = Session.rejectNilParameters(nillableParams)

        return try session.GET(path, parameters: parameters)
    }

    public class func updateAlert(session: Session, observerID: String, alertID: String, read: Bool? = nil, dismissed: Bool? = nil) throws -> NSURLRequest {
        let path = "/alert/\(observerID)/\(alertID)"

        let nillableParams: [String: AnyObject?] = [
            "read" : read,
            "dismissed" : dismissed
            ]

        let parameters = Session.rejectNilParameters(nillableParams)

        return try session.POST(path, parameters: parameters, encoding: .URL)
    }

}

