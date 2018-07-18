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

import ReactiveSwift

import Marshal

extension Enrollment {
    public static func put(_ session:Session, color: UIColor, forContextID: ContextID) -> SignalProducer<(), NSError> {
        let path = "/api/v1/users/self/colors" / forContextID.canvasContextID
        let params: [String: Any] = ["hexcode": color.hex]
        return attemptProducer { try session.PUT(path, parameters: params) }
            .flatMap(.merge, transform: session.emptyResponseSignalProducer)
    }
    
    public static func arcLTIToolID(courseID: String, callback: @escaping (String?) -> Void) {
        APIBridge.shared().call("getExternalTools", args: [courseID, ["include_parents": true]], callback: { (result, error) in
            guard let jsonLTITools = result as? [JSONObject] else {
                callback(nil)
                return
            }
            let arcID = jsonLTITools
                .filter { json in
                    guard let domain: String = (try? json <| "domain") else { return false }
                    return domain.contains("arc.instructure.com")
                }
                .flatMap { json in
                    return try? json.stringID("id")
                }
                .first ?? ""
            callback(arcID)
        })
    }
    
    public static func getGaugeLTILaunchURL(_ session: Session) throws -> SignalProducer<URL?, NSError> {
        let path = "/api/v1/accounts/self/lti_apps/launch_definitions"
        let request = try session.GET(path, parameters: ["placements[]": "global_navigation"])
        return session.paginatedJSONSignalProducer(request).map { launchDefinitionsJSON in
            return launchDefinitionsJSON
                .filter { json in
                    guard let domain: String = (try? json <| "domain") else { return false }
                    return domain == "gauge.instructure.com"
                }
            
                .flatMap { json in
                    guard let url: String = (try? json <| "placements.global_navigation.url") else { return nil }
                    return URL(string: url)
                }
            
                .first
        }
    }
}
