//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import TooLegit
import ReactiveSwift
import SoPretty
import Marshal

extension Enrollment {
    public static func put(_ session:Session, color: UIColor, forContextID: ContextID) -> SignalProducer<(), NSError> {
        let path = "/api/v1/users/self/colors" / forContextID.canvasContextID
        let params: [String: Any] = ["hexcode": color.hex]
        return attemptProducer { try session.PUT(path, parameters: params) }
            .flatMap(.merge, transform: session.emptyResponseSignalProducer)
    }
    
    public static func arcLTIToolID(_ session: Session, for contextID: ContextID) throws -> SignalProducer<String, NSError> {
        let path = contextID.apiPath + "/external_tools"
        let request = try session.GET(path, parameters: ["include_parents": "true"], encoding: .urlEncodedInURL, authorized: true)
        return session.paginatedJSONSignalProducer(request)
            .map { jsonLTITools in
                
                return jsonLTITools
                    .filter { json in
                        guard let url: String = (try? json <| "url") else { return false }
                        return url.contains("instructuremedia.com/lti/launch")
                    }
                
                    .flatMap { json in
                        return try? json.stringID("id")
                    }
                
                    // There should only ever be one arc lti me thinks
                    // See Enrollment.swift - 
                    // Empty string means we've checked, nil string means we haven't
                    .first ?? ""
            }
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
