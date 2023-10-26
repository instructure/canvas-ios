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

import CoreData
import Foundation
import SwiftUI

public final class CDWidgetAnnouncement: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var date: Date
    @NSManaged public var url: URL

    @NSManaged public var authorName: String
    @NSManaged public var avatarRaw: Data?

    @NSManaged public var courseName: String
    @NSManaged public var courseColorHex: String

    public var courseColor: UIColor {
        UIColor(hexString: courseColorHex) ?? .textDarkest
    }

    public var avatar: UIImage? {
        if let avatarRaw {
            return UIImage(data: avatarRaw)
        } else {
            return nil
        }
    }

    @discardableResult
    public static func save(
        _ item: APIDiscussionTopic,
        in context: NSManagedObjectContext
    ) -> CDWidgetAnnouncement? {
        guard
            let title = item.title,
            let date = item.posted_at,
            let authorName = item.author?.display_name,
            let url = item.html_url
        else { return nil }

        let dbItem: CDWidgetAnnouncement = context.first(where: #keyPath(CDWidgetAnnouncement.id),
                                                         equals: item.id.value) ?? context.insert()
        dbItem.id = item.id.value
        dbItem.title = title
        dbItem.date = date
        dbItem.url = url
        dbItem.authorName = authorName

        if let avatarURL = item.author?.avatar_image_url?.rawValue,
           dbItem.avatarRaw == nil,
           let avatarData = try? Data(contentsOf: avatarURL),
           let avatarImage = UIImage(data: avatarData)?.scaleTo(CGSize(width: 16, height: 16)),
           let resizedImageData = avatarImage.jpegData(compressionQuality: 0.9) {
            dbItem.avatarRaw = resizedImageData
        }

        if  let announcementContextCode = item.context_code,
            let announcementCourseID = Context(canvasContextID: announcementContextCode)?.id,
            let course: Course = context.first(where: #keyPath(Course.id),
                                               equals: announcementCourseID) {
            dbItem.courseName = course.name ?? ""
            dbItem.courseColorHex = course.color.hexString
        } else {
            dbItem.courseName = ""
            dbItem.courseColorHex = UIColor.textDarkest.hexString
        }

        return dbItem
    }
}
