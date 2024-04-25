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

    @NSManaged public var allowRating: Bool
    @NSManaged public var anonymousState: String?
    @NSManaged public var assignment: Assignment?
    @NSManaged public var assignmentID: String?
    @NSManaged public var courseID: String?
    @NSManaged public var attachments: Set<File>?
    @NSManaged public var author: DiscussionParticipant?
    @NSManaged public var canAttach: Bool
    @NSManaged public var canDelete: Bool
    @NSManaged public var canReply: Bool
    @NSManaged public var canUnpublish: Bool
    @NSManaged public var canUpdate: Bool
    @NSManaged public var canvasContextID: String?
    @NSManaged public var delayedPostAt: Date?
    @NSManaged public var discussionSubEntryCount: Int
    @NSManaged public var discussionType: String?
    @NSManaged public var groupCategoryID: String?
    @NSManaged public var groupTopicChildren: [String: String]?
    @NSManaged public var htmlURL: URL?
    @NSManaged public var id: String
    @NSManaged public var isAnnouncement: Bool
    @NSManaged public var isSectionSpecific: Bool
    @NSManaged public var lastReplyAt: Date?
    @NSManaged public var lockAt: Date?
    @NSManaged public var locked: Bool
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var message: String?
    @NSManaged public var onlyGradersCanRate: Bool
    @NSManaged public var order: String
    @NSManaged public var orderSection: Int
    @NSManaged public var pinned: Bool
    @NSManaged public var position: Int
    @NSManaged public var postedAt: Date?
    @NSManaged public var published: Bool
    @NSManaged public var requireInitialPost: Bool
    @NSManaged public var sections: Set<CourseSection>
    @NSManaged public var sortByRating: Bool
    @NSManaged public var subscribed: Bool
    @NSManaged public var title: String?
    @NSManaged public var unreadCount: Int

    public var context: Context? {
        get { canvasContextID.flatMap { Context(canvasContextID: $0) } }
        set { canvasContextID = newValue?.canvasContextID }
    }

    public var nRepliesString: String {
        String.localizedStringWithFormat(String(localized: "%d Replies", bundle: .core), discussionSubEntryCount)
    }

    public var nUnreadString: String {
        String.localizedStringWithFormat(String(localized: "%d Unread", bundle: .core), unreadCount)
    }

    @discardableResult
    public static func save(_ item: APIDiscussionTopic, apiPosition: Int = 0, in context: NSManagedObjectContext) -> DiscussionTopic {
        let model = save(item, in: context)
        model.position = apiPosition
        return model
    }

    @discardableResult
    public static func save(_ item: APIDiscussionTopic, in context: NSManagedObjectContext) -> DiscussionTopic {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(DiscussionTopic.id), item.id.value)
        let model: DiscussionTopic = context.fetch(predicate).first ?? context.insert()
        model.allowRating = item.allow_rating
        model.anonymousState = item.anonymous_state
        if let assignment = item.assignment?.values.first {
            model.assignment = nil // sever relationship first so assignment doesn't delete me
            model.assignment = Assignment.save(assignment, in: context, updateSubmission: false, updateScoreStatistics: false)
        } else {
            model.assignment = item.assignment_id.flatMap { context.first(where: (\Assignment.id).string, equals: $0.value) }
        }
        model.assignmentID = item.assignment_id?.value
        model.attachments = Set(item.attachments?.map { File.save($0, in: context) } ?? [])
        if let author = item.author {
            model.author = author.id.map { _ in DiscussionParticipant.save(author, in: context) }
        }
        if let permissions = item.permissions {
            model.canAttach = permissions.attach == true
            model.canDelete = permissions.delete == true
            model.canReply = permissions.reply == true
            model.canUpdate = permissions.update == true
        }
        model.canUnpublish = item.can_unpublish != false
        model.context = item.html_url.flatMap { Context(path: $0.path) }
        if model.context?.contextType == .course {
            model.courseID = model.context?.id
        }
        model.delayedPostAt = item.delayed_post_at
        model.discussionSubEntryCount = item.discussion_subentry_count
        model.discussionType = item.discussion_type
        model.groupCategoryID = item.group_category_id?.value
        model.groupTopicChildren = item.group_topic_children.flatMap { children in
            guard !children.isEmpty else { return nil }
            var dict: [String: String] = [:]
            for child in children {
                dict[child.group_id.value] = child.id.value
            }
            return dict
        }
        model.htmlURL = item.html_url
        model.id = item.id.value
        model.isAnnouncement = item.subscription_hold == "topic_is_announcement"
        model.isSectionSpecific = item.is_section_specific
        model.lastReplyAt = item.last_reply_at
        model.lockAt = item.lock_at
        model.locked = item.locked == true
        model.lockedForUser = item.locked_for_user
        model.message = item.message
        model.onlyGradersCanRate = item.only_graders_can_rate == true
        model.order = item.locked == true
            ? "2 \((item.last_reply_at ?? item.created_at ?? .distantPast).isoString()) \(model.id)"
            : "1 \((item.last_reply_at ?? item.created_at ?? .distantPast).isoString()) \(model.id)"
        model.orderSection = item.pinned == true ? 0 : item.locked == true ? 2 : 1
        model.pinned = item.pinned == true

        // In case of announcements we use the API's natural ordering. When we fetch a single instance
        // we don't want to overwrite the previously set position in save(_:apiPosition:in:). Also, announcements
        // cannot be pinned.
        if !model.isAnnouncement {
            model.position = item.pinned == true ? item.position ?? 0 : Int.max
        }

        model.postedAt = item.delayed_post_at ?? item.posted_at
        model.published = item.published
        model.requireInitialPost = item.require_initial_post == true
        model.sortByRating = item.sort_by_rating
        model.sections = Set((item.sections ?? []).map { CourseSection.save($0, in: context) })
        model.subscribed = item.subscribed == true
        model.title = item.title
        model.unreadCount = item.unread_count ?? 0
        return model
    }
}
