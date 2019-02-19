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



import Result

private let SessionStartedEventType = "ios_session_started"


class CanvasSubmissionAuditLoggingService: SubmissionAuditLoggingService {
    init(auth: Session, apiPath: String) {
        self.auth = auth
        self.apiPath = apiPath
    }
    
    let auth: Session
    let apiPath: String
    
    var baseURL: URL {
        return auth.baseURL
    }
    
    func logSessionStarted(_ completed: @escaping (SubmissionAuditLoggingResult)->()) {
        let _ = makeRequest(submissionEventRequest(SessionStartedEventType), completed: completed)
    }
    
    // TODO: in the future, include other events, such as going into the background, changing answer, flagging a question, etc
    
    func submissionEventRequest(_ eventType: String) -> Request<Bool> {
        let path = (apiPath as NSString).appendingPathComponent("events")
        
        let params: [String: Any] = [
            "quiz_submission_events": [
                [
                    "event_type": eventType,
                    "event_data": [
                        "user_agent": defaultHTTPHeaders["User-Agent"] ?? "Unknown iOS Device" // shouldn't ever be unknown
                    ]
                ]
            ]
        ]
        
        return Request(auth: auth, method: .POST, path: path, parameters: params, parseResponse: parseResponse)
    }
}

private func parseResponse(_ json: Any?) -> Result<Bool, NSError> {
    return Result(value: true) // yay this is a fire-and-forget
}
