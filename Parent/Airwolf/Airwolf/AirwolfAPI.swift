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

public class AirwolfAPI {
    public static var baseURL = RegionPicker.regions[0]

    // MARK: Parent calls
    public class func authenticateRequest(email email: String, password: String) throws -> NSURLRequest {
        return try NSMutableURLRequest(method: .POST, URL: AirwolfAPI.baseURL.URLByAppendingPathComponent("authenticate")!, parameters: ["username": email, "password": password], encoding: .JSON)
    }
    
    public class func authenticateAsCanvasObserver(domain: String) -> NSURLRequest {
        let url = AirwolfAPI.baseURL
            .URLByAppendingPathComponent("canvas")!
            .URLByAppendingPathComponent("authenticate")!
        
        return try! NSMutableURLRequest(method: .GET, URL: url, parameters: ["domain": domain], encoding: .URL)
    }

    public class func createAccountRequest(email email: String, password: String, firstName: String, lastName: String) throws -> NSURLRequest {
        return try NSMutableURLRequest(method: .PUT, URL: AirwolfAPI.baseURL.URLByAppendingPathComponent("newparent")!, parameters: ["parent": ["username": email, "password": password, "first_name": firstName, "last_name": lastName]], encoding: .JSON)
    }

    public class func sendPasswordResetEmailRequest(email email: String) throws -> NSURLRequest {
        let path = "/send_password_reset/\(email)"
        return try NSMutableURLRequest(method: .POST, URL: AirwolfAPI.baseURL.URLByAppendingPathComponent(path)!, parameters: [:], encoding: .URLEncodedInURL)
    }

    public class func resetPasswordRequest(email email: String, password: String, token: String) throws -> NSURLRequest {
        let request = try NSMutableURLRequest(method: .POST, URL: AirwolfAPI.baseURL.URLByAppendingPathComponent("reset_password")!, parameters: ["username": email, "password": password], encoding: .JSON)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        return request
    }

    // MARK: Student calls
    public class func getStudentsRequest(session: Session, parentID: String) throws -> NSURLRequest {
        return try session.GET("/students/\(parentID)")
    }

    public class func addStudentRequest(session: Session, parentID: String, studentDomain: NSURL) throws -> NSURLRequest {
        return try session.GET("/add_student/\(parentID)", parameters: ["student_domain": studentDomain.absoluteString!], encoding: .URLEncodedInURL, authorized: true)
    }

    public class func checkDomainRequest(session: Session, parentID: String, studentDomain: NSURL) throws -> NSURLRequest {
        return try session.GET("/check_domain/\(parentID)", parameters: ["student_domain": studentDomain.absoluteString!], encoding: .URLEncodedInURL, authorized: true)
    }

    public class func deleteStudentRequest(session: Session, parentID: String, studentID: String) throws -> NSURLRequest {
        return try session.DELETE("/student/\(parentID)/\(studentID)")
    }
}
