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

import Marshal
import ReactiveSwift


extension ModuleItem {
    public static var getModuleItemsParameters: [String: Any] {
        return ["include": ["content_details", "mastery_paths"]]
    }

    public static func getModuleItems(_ session: Session, courseID: String, moduleID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let modulePath = api/v1/"courses"/courseID/"modules"/moduleID
        let request = try session.GET(modulePath/"items", parameters: getModuleItemsParameters)
        return session.paginatedJSONSignalProducer(request).map(insert(courseID, forKey: "course_id"))
    }

    static func markDone(_ session: Session, courseID: String, moduleID: String, moduleItemID: String) throws -> SignalProducer<(), NSError> {
        let modulePath = api/v1/"courses"/courseID/"modules"/moduleID
        let path: String = modulePath/"items"/moduleItemID/"done"
        let request = try session.PUT(path)
        return session.emptyResponseSignalProducer(request)
    }

    static func markRead(_ session: Session, courseID: String, moduleID: String, moduleItemID: String) throws -> SignalProducer<(), NSError> {
        let modulePath = api/v1/"courses"/courseID/"modules"/moduleID
        let request = try session.POST(modulePath/"items"/moduleItemID/"mark_read")
        return session.emptyResponseSignalProducer(request)
    }

    public static func selectMasteryPath(_ session: Session, courseID: String, moduleID: String, moduleItemID: String, assignmentSetID: String) throws -> SignalProducer<JSONObject, NSError> {
        let modulePath = api/v1/"courses"/courseID/"modules"/moduleID
        let request = try session.POST(modulePath/"items"/moduleItemID/"select_mastery_path", parameters: ["assignment_set_id": assignmentSetID], encoding: .urlEncodedInURL)
        return session.JSONSignalProducer(request)
    }

    public static func moduleItemSequence(_ session: Session, courseID: String, moduleItemID: String) throws -> SignalProducer<JSONObject, NSError> {
        let path = api/v1/"courses"/courseID/"module_item_sequence"
        let parameters = ["asset_id": moduleItemID, "asset_type": "ModuleItem"]
        let request = try session.GET(path, parameters: parameters)
        return session.JSONSignalProducer(request)
    }
}
