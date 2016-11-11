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
import Marshal
import ReactiveCocoa
import SoLazy

extension ModuleItem {
    public static var getModuleItemsParameters: [String: AnyObject] {
        return ["include": ["content_details", "mastery_paths"]]
    }

    public static func getModuleItems(session: Session, courseID: String, moduleID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try session.GET(api/v1/"courses"/courseID/"modules"/moduleID/"items", parameters: getModuleItemsParameters)
        return session.paginatedJSONSignalProducer(request).map(insert(courseID, forKey: "course_id"))
    }

    static func markDone(session: Session, courseID: String, moduleID: String, moduleItemID: String) throws -> SignalProducer<(), NSError> {
        let path: String = api/v1/"courses"/courseID/"modules"/moduleID/"items"/moduleItemID/"done"
        let request = try session.PUT(path)
        return session.emptyResponseSignalProducer(request)
    }

    static func markRead(session: Session, courseID: String, moduleID: String, moduleItemID: String) throws -> SignalProducer<(), NSError> {
        let request = try session.POST(api/v1/"courses"/courseID/"modules"/moduleID/"items"/moduleItemID/"mark_read")
        return session.emptyResponseSignalProducer(request)
    }

    public static func selectMasteryPath(session: Session, courseID: String, moduleID: String, moduleItemID: String, assignmentSetID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.POST(api/v1/"courses"/courseID/"modules"/moduleID/"items"/moduleItemID/"select_mastery_path", parameters: ["assignment_set_id": assignmentSetID], encoding: .URLEncodedInURL)
        return session.JSONSignalProducer(request)
    }
}
