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

open class AirwolfAPI {
    // MARK: Parent calls
    open class func loginUserAgent() -> String {
        let template = "Mozilla/5.0 (iPhone; CPU iPhone OS %@ like Mac OS X) AppleWebKit/603.1.23 (KHTML, like Gecko) Version/10.0 Mobile/14E5239e Safari/602.1"
        let version = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        return String(format: template, version)
    }

    // MARK: Student calls
    open class func getStudentsRequest(_ session: Session, parentID: String) throws -> URLRequest {
        return try session.GET("/students/\(parentID)")
    }

    open class func addStudentRequest(_ session: Session, parentID: String, studentDomain: URL, authenticationProvider: String?) throws -> URLRequest {
        var parameters = ["student_domain": studentDomain.absoluteString]
        if let provider = authenticationProvider {
            parameters["authentication_provider"] = provider
        }
        return try session.GET("/add_student/\(parentID)", parameters: parameters, encoding: .urlEncodedInURL, authorized: true, userAgent: self.loginUserAgent())
    }

    open class func checkDomainRequest(_ session: Session, parentID: String, studentDomain: URL) throws -> URLRequest {
        return try session.GET("/check_domain/\(parentID)", parameters: ["student_domain": studentDomain.absoluteString], encoding: .urlEncodedInURL, authorized: true)
    }

    open class func deleteStudentRequest(_ session: Session, parentID: String, studentID: String) throws -> URLRequest {
        return try session.DELETE("/student/\(parentID)/\(studentID)")
    }

    open class func validateSession(_ session: Session, parentID: String, completionHandler: @escaping (_ success: Bool) -> Void) {
        do {
            let request = try self.getStudentsRequest(session, parentID: parentID)

            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                if error != nil {
                    completionHandler(false)
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if (httpResponse.statusCode == 401) {
                        completionHandler(false)
                    } else {
                        completionHandler(true)
                    }
                }
            }
            task.resume()
        } catch {
            completionHandler(false)
        }
    }

    open class func validateSessionAndLogout(_ session: Session, parentID: String) {
        validateSession(session, parentID: parentID) {success in
            if !success {
                DispatchQueue.main.async {
                    CanvasKeymaster.the().logout()
                }
            }
        }
    }
}
