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

extension Page: OfflineStorageDataProtocol {
    public static func fromOfflineModel(_ model: OfflineStorageDataModel) throws -> Page {
        let env = AppEnvironment.shared
        if model.type == OfflineContentType.page.rawValue {
            let data = model.json.data(using: .utf8)
            let dictionary = (try? JSONSerialization.jsonObject(with: data!) as? [String: Any]) ?? [:]
            let context = env.database.viewContext
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Page.id), model.id)
            if let page: Page = context.fetch(predicate).first { return page }

            let page: Page = context.insert()

            if let url = dictionary["url"] as? String {
                page.url = url
            }

            if let lastUpdatedInterval = dictionary["lastUpdated"] as? TimeInterval {
                page.lastUpdated = Date(timeIntervalSince1970: lastUpdatedInterval)
            }

            if let isFrontPage = dictionary["isFrontPage"] as? Bool {
                page.isFrontPage = isFrontPage
            }

            if let id = dictionary["id"] as? String {
                page.id = id
            }

            if let title = dictionary["title"] as? String {
                page.title = title
            }

            if let urlString = dictionary["htmlURL"] as? String {
                page.htmlURL = URL(string: urlString)
            }

            if let published = dictionary["published"] as? Bool {
                page.published = published
            }

            if let body = dictionary["body"] as? String {
                page.body = body
            }

            if let roles = dictionary["editingRoles"] as? [String] {
                page.editingRoles = roles
            }

            if let contextID = dictionary["contextID"] as? String {
                page.contextID = contextID
            }

            return page
        }

        throw OfflineStorageDataError.cantCreateObject(type: Page.self)
    }

    public func toOfflineModel() throws -> OfflineStorageDataModel {
        let dictionary: [String: Any] = [
            "url": url,
            "lastUpdated": lastUpdated?.timeIntervalSince1970 ?? 0,
            "isFrontPage": isFrontPage,
            "id": id,
            "title": title,
            "htmlURL": htmlURL?.absoluteString ?? "",
            "published": published,
            "body": body,
            "editingRoles": editingRoles,
            "contextID": contextID
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return OfflineStorageDataModel(
                id: id,
                type: OfflineContentType.page.rawValue,
                json: jsonString
            )
        }
        return OfflineStorageDataModel(id: "", type: "", json: "")
    }
}
