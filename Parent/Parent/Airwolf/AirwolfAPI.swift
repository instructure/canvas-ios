//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import CanvasCore

open class AirwolfAPI {
    open class func validateSession(_ session: Session, parentID: String, completionHandler: @escaping (_ success: Bool) -> Void) {
        do {
            let request = try session.GET("/api/v1/users/self/enrollments")

            let task = URLSession.shared.dataTask(with: request) {_, response, error in
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
                    (UIApplication.shared.delegate as? ParentAppDelegate)?.logout()
                }
            }
        }
    }
}
