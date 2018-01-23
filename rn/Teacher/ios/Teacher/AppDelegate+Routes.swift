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

extension AppDelegate {
    func registerNativeRoutes() {
        HelmManager.shared.registerNativeViewController(for: "/attendance", factory: { props in
            guard
                let destinationURL = (props["launchURL"] as? String).flatMap(URL.init(string:)),
                let courseName = props["courseName"] as? String,
                let courseID = props["courseID"] as? String,
                let courseColor = props["courseColor"].flatMap(RCTConvert.uiColor)
                else { return nil }
            
            return TeacherAttendanceViewController(
                courseName: courseName,
                courseColor: courseColor,
                launchURL: destinationURL,
                courseID: courseID,
                date: Date()
            )
        })
        
        HelmManager.shared.registerNativeViewController(for: "/launch_external_tool", factory: { props in
            guard let toolUrl = props["url"] as? String
            ,let baseUrl = CanvasKeymaster.the().currentClient.baseURL?.absoluteString
            else { return nil }
            let currentSession = CanvasKeymaster.the().currentClient.authSession
            let sessionlessUrl = "\(baseUrl)/api/v1/accounts/self/external_tools/sessionless_launch?url=\(toolUrl)"
            guard let url = URL(string: sessionlessUrl) else { fatalError("Invalid URL") }
            let toolName = props["toolName"] as? String ?? ""
            let ltiController = LTIViewController(toolName: toolName, courseID: nil, launchURL: url, in: currentSession, showDoneButton: true)
            return UINavigationController(rootViewController: ltiController)
        })
    }
}
