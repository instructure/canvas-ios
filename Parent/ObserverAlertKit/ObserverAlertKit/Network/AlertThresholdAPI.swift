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

public class AlertThresholdAPI {

    public class func deleteAlertThreshold(session: Session, observerID: String, alertThresholdID: String) throws -> NSURLRequest {
        let path = "/alertthreshold/\(observerID)/\(alertThresholdID)"
        let parameters: [String: AnyObject] = [:]

        return try session.DELETE(path, parameters: parameters)
    }

    public class func getAlertThresholdByObservee(session: Session, parentID: String, studentID: String) throws -> NSURLRequest {
        let path = "/alertthreshold/student/\(parentID)/\(studentID)"
        let parameters: [String: AnyObject] = [:]

        return try session.GET(path, parameters: parameters)
    }

    public class func getAllAlertThresholds(session: Session) throws -> NSURLRequest {
        let path = "/alertthreshold/\(session.user.id)"
        let parameters: [String: AnyObject] = [:]

        return try session.GET(path, parameters: parameters)
    }

    public class func insertAlertThreshold(session: Session, observerID: String, studentID: String, alertType: String, threshold: String? = nil) throws -> NSURLRequest {
        let path = "/alertthreshold/\(observerID)/"
        let nillableParameters: [String: AnyObject?] = [
            "observer_id": observerID,
            "student_id": studentID,
            "alert_type": alertType,
            "threshold": threshold
        ]

        let parameters = Session.rejectNilParameters(nillableParameters)

        return try session.PUT(path, parameters: parameters)
    }

    public class func updateAlertThreshold(session: Session, observerID: String, alertThresholdID: String, alertType: String, threshold: String? = nil) throws -> NSURLRequest {
        let path = "/alertthreshold/\(observerID)/\(alertThresholdID)"
        let nillableParameters: [String: AnyObject?] = [
            "alert_type": alertType,
            "threshold": threshold
        ]

        let parameters = Session.rejectNilParameters(nillableParameters)

        return try session.POST(path, parameters: parameters)
    }
}