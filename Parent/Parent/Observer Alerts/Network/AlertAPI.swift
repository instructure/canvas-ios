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
    open class func getAlerts(_ session: Session, studentID: String) throws -> URLRequest {
        let path = "/api/v1/users/self/observer_alerts/\(studentID)"
        return try session.GET(path)
    }

    open class func readAlert(_ session: Session, alertID: String) throws -> URLRequest {
        let path = "/api/v1/users/self/observer_alerts/\(alertID)/read"
        return try session.PUT(path)
    }

    open class func dismissAlert(_ session: Session, alertID: String) throws -> URLRequest {
        let path = "/api/v1/users/self/observer_alerts/\(alertID)/dismissed"
        return try session.PUT(path)
    }
}

