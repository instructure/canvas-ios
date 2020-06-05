//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import CoreData

public final class DiscussionTopic: NSManagedObject, WriteableModel {
    public typealias JSON = APIDiscussionTopic

    @NSManaged public var id: String
    @NSManaged public var isAnnouncement: Bool
    @NSManaged public var title: String?
    @NSManaged public var message: String?
    @NSManaged public var htmlURL: URL?
    @NSManaged public var postedAt: Date?
    @NSManaged public var lastReplyAt: Date?
    @NSManaged public var discussionSubEntryCount: Int
    @NSManaged public var published: Bool
    @NSManaged public var assignment: Assignment?
    @NSManaged public var assignmentID: String?
    @NSManaged public var attachments: Set<File>?
    @NSManaged public var author: DiscussionParticipant?
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var allowRating: Bool
    @NSManaged public var sortByRating: Bool
    @NSManaged public var onlyGradersCanRate: Bool
    @NSManaged public var canAttach: Bool
    @NSManaged public var canDelete: Bool
    @NSManaged public var canReply: Bool
    @NSManaged public var canUpdate: Bool
    @NSManaged public var groupCategoryID: String?
    @NSManaged public var groupTopicChildren: [String: String]?
    @NSManaged public var unreadCount: Int
    @NSManaged public var isSectionSpecific: Bool
    @NSManaged public var sections: Set<CourseSection>

    @discardableResult
    public static func save(_ item: APIDiscussionTopic, in context: NSManagedObjectContext) -> DiscussionTopic {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(DiscussionTopic.id), item.id.value)
        let model: DiscussionTopic = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.isAnnouncement = item.subscription_hold == "topic_is_announcement"
        model.title = item.title
        model.htmlURL = item.html_url
        model.postedAt = item.posted_at
        model.lastReplyAt = item.last_reply_at
        model.discussionSubEntryCount = item.discussion_subentry_count
        model.message = item.message
        model.published = item.published
        model.assignmentID = item.assignment_id?.value
        model.attachments = Set(item.attachments?.map { attachment in
            return File.save(attachment, in: context)
        } ?? [])
        model.author = item.author.id.map { _ in
            DiscussionParticipant.save(item.author, in: context)
        }
        model.lockedForUser = item.locked_for_user
        model.allowRating = item.allow_rating
        model.sortByRating = item.sort_by_rating
        model.onlyGradersCanRate = item.only_graders_can_rate == true
        if let permissions = item.permissions {
            model.canAttach = permissions.attach == true
            model.canDelete = permissions.delete == true
            model.canReply = permissions.reply == true
            model.canUpdate = permissions.update == true
        }
        model.groupCategoryID = item.group_category_id?.value
        model.groupTopicChildren = item.group_topic_children.flatMap { children in
            guard !children.isEmpty else { return nil }
            var dict: [String: String] = [:]
            for child in children {
                dict[child.group_id.value] = child.id.value
            }
            return dict
        }
        model.isSectionSpecific = item.is_section_specific
        if let sections = item.sections {
            model.sections = Set(sections.map { CourseSection.save($0, in: context) })
        }
        return model
    }
}
