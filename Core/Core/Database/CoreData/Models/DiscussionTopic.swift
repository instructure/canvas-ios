//
// Copyright (C) 2018-present Instructure, Inc.
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
import CoreData

public final class DiscussionTopic: NSManagedObject, WriteableModel {
    public typealias JSON = APIDiscussionTopic

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var message: String?
    @NSManaged public var htmlUrl: URL?
    @NSManaged public var postedAt: Date?
    @NSManaged public var lastReplyAt: Date?
    @NSManaged public var discussionSubEntryCount: Int
    @NSManaged public var published: Bool
    @NSManaged public var assignment: Assignment?
    @NSManaged public var attachments: Set<File>?
    @NSManaged public var authorAvatarURL: URL?
    @NSManaged public var authorID: String
    @NSManaged public var authorName: String

    @discardableResult
    public static func save(_ item: APIDiscussionTopic, in context: PersistenceClient) throws -> DiscussionTopic {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(DiscussionTopic.id), item.id.value)
        let model: DiscussionTopic = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.title = item.title
        model.htmlUrl = item.html_url
        model.postedAt = item.posted_at
        model.lastReplyAt = item.last_reply_at
        model.discussionSubEntryCount = item.discussion_subentry_count
        model.message = item.message
        model.published = item.published
        model.attachments = Set(try item.attachments?.map { attachment in
            return try File.save(attachment, in: context)
        } ?? [])
        model.authorAvatarURL = item.author.avatar_image_url
        model.authorID = item.author.id
        model.authorName = item.author.display_name
        return model
    }

    public var html: String {
        let date = postedAt.flatMap { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .short) }
        let attachmentIcon = attachments?.isEmpty == true ? "" : """
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1920" width="18" aria-hidden>
        <path fill-rule="evenodd" fill="\(UIColor.named(.textDark).hexString)" d="
            M1752.77 221.1C1532.65 1 1174.28 1 954.17 221.1l-838.6 838.6c-154.05 154.16-154.05 404.9 0 558.94
            149.54 149.42 409.98 149.31 559.06 0l758.74-758.62c87.98-88.1 87.98-231.42 0-319.51-88.32-88.21
            -231.64-87.98-319.51 0l-638.8 638.9 79.85 79.85 638.8-638.9c43.93-43.83 115.54-43.94 159.81 0
            43.93 44.04 43.93 115.87 0 159.8L594.78 1538.8c-110.23 110.12-289.35 110-399.36 0-110.12-110.11-110
            -289.24 0-399.24l838.59-838.6c175.96-175.95 462.38-176.18 638.9 0 176.08 176.2 176.08 462.84 0
            638.92l-798.6 798.72 79.85 79.85 798.6-798.72c220.02-220.13 220.02-578.49 0-798.61"/>
        </svg>
        """
        return """
        <div style="align-items:center; display:flex; margin:1em 0;">
            \(AvatarView.html(for: authorAvatarURL, name: authorName))
            <div style="flex:1; margin-left:8px;">
                <div style="font-size:14px; font-weight:600;">
                    \(CoreWebView.htmlString(authorName))
                </div>
                <div style="color:\(UIColor.named(.textDark).hexString); font-size:12px; margin-top:-4px;">
                    \(CoreWebView.htmlString(date))
                </div>
            </div>
            \(attachmentIcon)
        </div>
        \(message ?? "")
        """
    }
}
