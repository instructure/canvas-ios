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
