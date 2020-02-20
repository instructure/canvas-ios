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

import Marshal
import ReactiveSwift


extension ModuleItem {
    @objc public static var getModuleItemsParameters: [String: Any] {
        return ["include": ["content_details", "mastery_paths"]]
    }

    public static func getModuleItems(_ session: Session, courseID: String, moduleID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let path = "api/v1/courses/\(courseID)/modules/\(moduleID)/items"
        let request = try session.GET(path, parameters: getModuleItemsParameters)
        return session.paginatedJSONSignalProducer(request).map(insert(courseID, forKey: "course_id"))
    }

    static func markDone(_ session: Session, courseID: String, moduleID: String, moduleItemID: String) throws -> SignalProducer<(), NSError> {
        let path = "api/v1/courses/\(courseID)/modules/\(moduleID)/items/\(moduleItemID)/done"
        let request = try session.PUT(path)
        return session.emptyResponseSignalProducer(request)
    }

    static func markRead(_ session: Session, courseID: String, moduleID: String, moduleItemID: String) throws -> SignalProducer<(), NSError> {
        let path = "api/v1/courses/\(courseID)/modules/\(moduleID)/items/\(moduleItemID)/mark_read"
        let request = try session.POST(path)
        return session.emptyResponseSignalProducer(request)
    }

    public static func selectMasteryPath(_ session: Session, courseID: String, moduleID: String, moduleItemID: String, assignmentSetID: String) throws -> SignalProducer<JSONObject, NSError> {
        let path = "api/v1/courses/\(courseID)/modules/\(moduleID)/items/\(moduleItemID)/select_mastery_path"
        let request = try session.POST(path, parameters: ["assignment_set_id": assignmentSetID], encoding: .urlEncodedInURL)
        return session.JSONSignalProducer(request)
    }

    public static func moduleItemSequence(_ session: Session, courseID: String, moduleItemID: String) throws -> SignalProducer<JSONObject, NSError> {
        let path = "api/v1/courses/\(courseID)/module_item_sequence"
        let parameters = ["asset_id": moduleItemID, "asset_type": "ModuleItem"]
        let request = try session.GET(path, parameters: parameters, paginated: false)
        return session.JSONSignalProducer(request)
    }
}
