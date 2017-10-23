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
