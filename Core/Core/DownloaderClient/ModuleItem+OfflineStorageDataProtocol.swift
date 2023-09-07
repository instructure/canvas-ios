//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import mobile_offline_downloader_ios

public enum OfflineContentType: String {
    case moduleitem
    case page
    case course
    case file
    case downloadcourse
}

extension ModuleItem: OfflineStorageDataProtocol {

    public static func fromOfflineModel(_ model: OfflineStorageDataModel) throws -> ModuleItem {
        let env = AppEnvironment.shared
        if model.type == OfflineContentType.moduleitem.rawValue {
            let data = model.json.data(using: .utf8)
            let dictionary = (try? JSONSerialization.jsonObject(with: data!) as? [String: Any]) ?? [:]
            let context = env.database.viewContext
            let predicate = NSPredicate(format: "%K == %@", #keyPath(ModuleItem.id), model.id)
            if let moduleItem: ModuleItem = context.fetch(predicate).first { return moduleItem }
            let moduleItem: ModuleItem = context.insert()

            if let id = dictionary["id"] as? String {
                moduleItem.id = id
            }

            if let courseID = dictionary["courseID"] as? String {
                moduleItem.courseID = courseID
            }

            if let moduleID = dictionary["moduleID"] as? String {
                moduleItem.moduleID = moduleID
            }

            if let title = dictionary["title"] as? String {
                moduleItem.title = title
            }

            if let htmlURL = dictionary["htmlURL"] as? String {
                moduleItem.htmlURL = URL(string: htmlURL)
            }

            if let url = dictionary["url"] as? String {
                moduleItem.url = URL(string: url)
            }

            if let typeRaw = dictionary["typeRaw"] as? String {
                moduleItem.typeRaw = Data(typeRaw.utf8)
            }

            return moduleItem
        }

        throw OfflineStorageDataError.cantCreateObject(type: ModuleItem.self)
    }

    public func toOfflineModel() throws -> OfflineStorageDataModel {
        guard let typeRaw = typeRaw else {
            return OfflineStorageDataModel(id: "", type: "", json: "")
        }
        let dictionary: [String: Any] = [
            "id": id,
            "courseID": courseID,
            "moduleID": moduleID,
            "position": position,
            "title": title,
            "htmlURL": htmlURL?.absoluteString ?? "",
            "url": url?.absoluteString ?? "",
            "typeRaw": String(decoding: typeRaw, as: UTF8.self)
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return OfflineStorageDataModel(
                id: id,
                type: OfflineContentType.moduleitem.rawValue,
                json: jsonString
            )
        }
        return OfflineStorageDataModel(id: "", type: "", json: "")
    }

}
