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

open class AirwolfAPI {
    open static var baseURL = RegionPicker.defaultPicker.defaultURL

    // MARK: Parent calls
    open class func authenticateRequest(email: String, password: String) throws -> URLRequest {
        return try URLRequest(method: .POST, URL: AirwolfAPI.baseURL.appendingPathComponent("authenticate"), parameters: ["username": email, "password": password], encoding: .json)
    }
    
    open class func authenticateAsCanvasObserver(_ domain: String) -> URLRequest {
        let url = AirwolfAPI.baseURL
            .appendingPathComponent("canvas")
            .appendingPathComponent("authenticate")
        
        return try! URLRequest(method: .GET, URL: url, parameters: ["domain": domain], encoding: .url)
    }

    open class func createAccountRequest(email: String, password: String, firstName: String, lastName: String) throws -> URLRequest {
        return try URLRequest(method: .PUT, URL: AirwolfAPI.baseURL.appendingPathComponent("newparent"), parameters: ["parent": ["username": email, "password": password, "first_name": firstName, "last_name": lastName]], encoding: .json)
    }

    open class func sendPasswordResetEmailRequest(email: String) throws -> URLRequest {
        let path = "/send_password_reset/\(email)"
        return try URLRequest(method: .POST, URL: AirwolfAPI.baseURL.appendingPathComponent(path), parameters: [:], encoding: .urlEncodedInURL)
    }

    open class func resetPasswordRequest(email: String, password: String, token: String) throws -> URLRequest {
        var request = try URLRequest(method: .POST, URL: AirwolfAPI.baseURL.appendingPathComponent("reset_password"), parameters: ["username": email, "password": password], encoding: .json)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        return request
    }

    // MARK: Student calls
    open class func getStudentsRequest(_ session: Session, parentID: String) throws -> URLRequest {
        return try session.GET("/students/\(parentID)")
    }

    open class func addStudentRequest(_ session: Session, parentID: String, studentDomain: URL) throws -> URLRequest {
        return try session.GET("/add_student/\(parentID)", parameters: ["student_domain": studentDomain.absoluteString], encoding: .urlEncodedInURL, authorized: true)
    }

    open class func checkDomainRequest(_ session: Session, parentID: String, studentDomain: URL) throws -> URLRequest {
        return try session.GET("/check_domain/\(parentID)", parameters: ["student_domain": studentDomain.absoluteString], encoding: .urlEncodedInURL, authorized: true)
    }

    open class func deleteStudentRequest(_ session: Session, parentID: String, studentID: String) throws -> URLRequest {
        return try session.DELETE("/student/\(parentID)/\(studentID)")
    }
}
