//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class GetAnnouncements: CollectionUseCase {
    typealias Model = DiscussionTopic

    let context: Context
    init(context: Context) {
        self.context = context
    }

    var cacheKey: String? { "\(context.pathComponent)/announcements" }
    var request: GetDiscussionTopicsRequest {
        GetDiscussionTopicsRequest(context: context, isAnnouncement: true)
    }
    var scope: Scope { Scope(
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(DiscussionTopic.isAnnouncement), equals: true),
            NSPredicate(key: #keyPath(DiscussionTopic.canvasContextID), equals: context.canvasContextID)
        ]),
        orderBy: #keyPath(DiscussionTopic.position), ascending: true
    ) }

    func write(response: [APIDiscussionTopic]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        let pageOffset: Int = {
            guard
                let url = urlResponse?.url,
                let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                let pageSize = components.pageSize
            else {
                return 0
            }

            return (components.page - 1) * pageSize
        }()

        response?.enumerated().forEach {
            Model.save($0.element, apiPosition: pageOffset + $0.offset, in: client)
        }
    }
}

class GetDiscussionTopics: CollectionUseCase {
    typealias Model = DiscussionTopic
    typealias Response = [APIDiscussionTopic]

    let context: Context
    init(context: Context) {
        self.context = context
    }

    var cacheKey: String? { "\(context.pathComponent)/discussions" }
    var request: GetDiscussionTopicsRequest {
        GetDiscussionTopicsRequest(context: context)
    }
    var scope: Scope { Scope(
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(DiscussionTopic.isAnnouncement), equals: false),
            NSPredicate(key: #keyPath(DiscussionTopic.canvasContextID), equals: context.canvasContextID)
        ]),
        order: [
            NSSortDescriptor(key: #keyPath(DiscussionTopic.orderSection), ascending: true),
            NSSortDescriptor(key: #keyPath(DiscussionTopic.position), ascending: true),
            NSSortDescriptor(key: #keyPath(DiscussionTopic.order), ascending: false, naturally: true)
        ],
        sectionNameKeyPath: #keyPath(DiscussionTopic.orderSection)
    ) }
}

public class GetDiscussionTopic: APIUseCase {
    public typealias Model = DiscussionTopic

    let context: Context
    let topicID: String

    public var cacheKey: String? {
        "\(context.pathComponent)/discussions/\(topicID)"
    }
    public var request: GetDiscussionTopicRequest {
        GetDiscussionTopicRequest(context: context, topicID: topicID)
    }
    public var scope: Scope {
        .where(#keyPath(DiscussionTopic.id), equals: topicID)
    }

    public init(context: Context, topicID: String) {
        self.context = context
        self.topicID = topicID
    }
}

class DeleteDiscussionTopic: APIUseCase {
    typealias Model = DiscussionTopic

    let context: Context
    let topicID: String

    var cacheKey: String? { nil }
    var request: DeleteDiscussionTopicRequest {
        DeleteDiscussionTopicRequest(context: context, topicID: topicID)
    }
    var scope: Scope { .where(#keyPath(DiscussionTopic.id), equals: topicID) }

    init(context: Context, topicID: String) {
        self.context = context
        self.topicID = topicID
    }

    func write(response: DeleteDiscussionTopicRequest.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard response != nil else { return }
        client.delete(client.fetch(scope: scope) as [DiscussionTopic])
    }
}

class GetDiscussionView: CollectionUseCase {
    typealias Model = DiscussionEntry

    let context: Context
    let topicID: String

    var cacheKey: String? {
        "\(context.pathComponent)/discussions/\(topicID)/view"
    }
    var request: GetDiscussionViewRequest {
        GetDiscussionViewRequest(context: context, topicID: topicID)
    }
    var scope: Scope {
        Scope.where(
            #keyPath(DiscussionEntry.topicID),
            equals: topicID,
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(DiscussionEntry.createdAt), ascending: true, naturally: false),
                NSSortDescriptor(key: #keyPath(DiscussionEntry.id), ascending: true)
            ]
        )
    }

    init(context: Context, topicID: String) {
        self.context = context
        self.topicID = topicID
    }

    func write(response: APIDiscussionView?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let view = response else { return }
        for participant in view.participants {
            DiscussionParticipant.save(participant, in: client)
        }
        let unreadIDs = Set(view.unread_entries.map { $0.value })
        let forcedIDs = Set(view.forced_entries.map { $0.value })
        let entryRatings = view.entry_ratings
        for entry in view.view {
            DiscussionEntry.save(entry, topicID: topicID, unreadIDs: unreadIDs, forcedIDs: forcedIDs, entryRatings: entryRatings, in: client)
        }
        view.new_entries?.forEach { entry in
            let parent: DiscussionEntry? = client.first(where: #keyPath(DiscussionEntry.id), equals: entry.parent_id?.value)
            DiscussionEntry.save(entry, topicID: topicID, parent: parent, unreadIDs: unreadIDs, forcedIDs: forcedIDs, entryRatings: entryRatings, in: client)
        }
    }
}

class GetDiscussionEntry: GetDiscussionView {
    var entryID: String

    init(context: Context, topicID: String, entryID: String) {
        self.entryID = entryID
        super.init(context: context, topicID: topicID)
    }

    override var scope: Scope {
        .where(#keyPath(DiscussionEntry.id), equals: entryID)
    }
}

class UpdateDiscussionTopic: UseCase {
    typealias Model = DiscussionTopic
    enum Request {
        case create(PostDiscussionTopicRequest)
        case update(PutDiscussionTopicRequest)
    }

    var cacheKey: String? { nil }
    let context: Context
    let topicID: String?
    let request: Request

    init(context: Context, topicID: String?, form: [PostDiscussionTopicRequest.DiscussionKey: APIFormDatum?]) {
        self.context = context
        self.topicID = topicID
        if let topicID = topicID {
            self.request = .update(PutDiscussionTopicRequest(context: context, topicID: topicID, form: form))
        } else {
            self.request = .create(PostDiscussionTopicRequest(context: context, form: form))
        }
    }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APIDiscussionTopic?, URLResponse?, Error?) -> Void) {
        switch request {
        case .create(let request):
            environment.api.makeRequest(request, callback: completionHandler)
        case .update(let request):
            environment.api.makeRequest(request, callback: completionHandler)
        }
    }

    func write(response: APIDiscussionTopic?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        if let item = response { DiscussionTopic.save(item, in: client) }
    }
}

class SubscribeDiscussionTopic: APIUseCase {
    typealias Model = DiscussionTopic

    var cacheKey: String? { nil }
    let context: Context
    let topicID: String
    let subscribed: Bool

    init(context: Context, topicID: String, subscribed: Bool) {
        self.context = context
        self.topicID = topicID
        self.subscribed = subscribed
    }

    var request: SubscribeDiscussionTopicRequest {
        SubscribeDiscussionTopicRequest(context: context, topicID: topicID, method: subscribed ? .put : .delete)
    }

    func write(response: APINoContent?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard (urlResponse as? HTTPURLResponse)?.statusCode == 204 else { return }
        let topic: DiscussionTopic? = client.first(where: #keyPath(DiscussionTopic.id), equals: topicID)
        topic?.subscribed = subscribed
    }
}

class CreateDiscussionReply: APIUseCase {
    typealias Model = DiscussionEntry

    var cacheKey: String? { nil }
    let context: Context
    let request: PostDiscussionEntryRequest
    let topicID: String

    init(context: Context, topicID: String, entryID: String? = nil, message: String, attachment: URL? = nil) {
        self.context = context
        self.request = PostDiscussionEntryRequest(context: context, topicID: topicID, entryID: entryID, message: message, attachment: attachment)
        self.topicID = topicID
    }

    func write(response: APIDiscussionEntry?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        DiscussionEntry.save(
            item,
            topicID: topicID,
            parent: client.first(where: #keyPath(DiscussionEntry.id), equals: item.parent_id?.value),
            in: client
        )
        if context.contextType == .course {
            NotificationCenter.default.post(moduleItem: .discussion(topicID), completedRequirement: .contribute, courseID: context.id)
        }
        NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
    }
}

class UpdateDiscussionReply: APIUseCase {
    typealias Model = DiscussionEntry

    var cacheKey: String? { nil }
    let request: PutDiscussionEntryRequest
    let scope: Scope

    init(context: Context, topicID: String, entryID: String, message: String) {
        request = PutDiscussionEntryRequest(context: context, topicID: topicID, entryID: entryID, message: message)
        scope = .where(#keyPath(DiscussionEntry.id), equals: entryID)
    }

    func write(response: APIDiscussionEntry?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        DiscussionEntry.save(item, in: client)
    }
}

class MarkDiscussionTopicRead: APIUseCase {
    var cacheKey: String? { nil }
    let context: Context
    let request: MarkDiscussionTopicReadRequest
    let topicID: String

    init(context: Context, topicID: String, isRead: Bool) {
        self.context = context
        self.request = MarkDiscussionTopicReadRequest(context: context, topicID: topicID, isRead: isRead)
        self.topicID = topicID
    }

    func write(response: APINoContent?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        if context.contextType == .course {
            NotificationCenter.default.post(moduleItem: .discussion(topicID), completedRequirement: .view, courseID: context.id)
        }
        NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
    }
}

class MarkDiscussionEntriesRead: APIUseCase {
    var cacheKey: String? { nil }
    let context: Context
    let request: MarkDiscussionEntriesReadRequest
    let topicID: String
    let isRead: Bool
    let isForcedRead: Bool

    init(context: Context, topicID: String, isRead: Bool, isForcedRead: Bool) {
        self.context = context
        self.request = MarkDiscussionEntriesReadRequest(context: context, topicID: topicID, isRead: isRead, isForcedRead: isForcedRead)
        self.topicID = topicID
        self.isRead = isRead
        self.isForcedRead = isForcedRead
    }

    func write(response: APINoContent?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard (urlResponse as? HTTPURLResponse)?.statusCode == 204 else { return }
        let entries: [DiscussionEntry] = client.all(where: #keyPath(DiscussionEntry.topicID), equals: topicID)
        for entry in entries {
            entry.isForcedRead = isForcedRead
            entry.isRead = isRead
        }
        let topic: DiscussionTopic? = client.first(where: #keyPath(DiscussionTopic.id), equals: topicID)
        topic?.unreadCount = isRead ? 0 : entries.count
    }
}

class MarkDiscussionEntryRead: APIUseCase {
    var cacheKey: String? { nil }
    let context: Context
    let request: MarkDiscussionEntryReadRequest
    let topicID: String
    let entryID: String
    let isRead: Bool
    let isForcedRead: Bool

    init(context: Context, topicID: String, entryID: String, isRead: Bool, isForcedRead: Bool) {
        self.context = context
        self.request = MarkDiscussionEntryReadRequest(context: context, topicID: topicID, entryID: entryID, isRead: isRead, isForcedRead: isForcedRead)
        self.topicID = topicID
        self.entryID = entryID
        self.isRead = isRead
        self.isForcedRead = isForcedRead
    }

    func write(response: APINoContent?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard (urlResponse as? HTTPURLResponse)?.statusCode == 204 else { return }
        let entry: DiscussionEntry? = client.first(where: #keyPath(DiscussionEntry.id), equals: entryID)
        entry?.isForcedRead = isForcedRead
        entry?.isRead = isRead
        let entries: [DiscussionEntry] = client.fetch(NSPredicate(format: "%K == %@ and %K == %@",
            #keyPath(DiscussionEntry.topicID), topicID,
            #keyPath(DiscussionEntry.isRead), false
        ))
        let topic: DiscussionTopic? = client.first(where: #keyPath(DiscussionTopic.id), equals: topicID)
        topic?.unreadCount = entries.count
    }
}

class RateDiscussionEntry: APIUseCase {
    var cacheKey: String? { nil }
    let context: Context
    let request: PostDiscussionEntryRatingRequest
    let topicID: String
    let entryID: String
    let isLiked: Bool

    init(context: Context, topicID: String, entryID: String, isLiked: Bool) {
        self.context = context
        self.request = PostDiscussionEntryRatingRequest(context: context, topicID: topicID, entryID: entryID, isLiked: isLiked)
        self.topicID = topicID
        self.entryID = entryID
        self.isLiked = isLiked
    }

    func write(response: APINoContent?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard (urlResponse as? HTTPURLResponse)?.statusCode == 204 else { return }
        let entry: DiscussionEntry? = client.first(where: #keyPath(DiscussionEntry.id), equals: entryID)
        entry?.isLikedByMe = isLiked
        entry?.likeCount += isLiked ? 1 : -1
    }
}

class DeleteDiscussionEntry: APIUseCase {
    var cacheKey: String? { nil }
    let context: Context
    let request: DeleteDiscussionEntryRequest
    let topicID: String
    let entryID: String

    init(context: Context, topicID: String, entryID: String) {
        self.context = context
        self.request = DeleteDiscussionEntryRequest(context: context, topicID: topicID, entryID: entryID)
        self.topicID = topicID
        self.entryID = entryID
    }

    func write(response: APINoContent?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard (urlResponse as? HTTPURLResponse)?.statusCode == 204 else { return }
        let entry: DiscussionEntry? = client.first(where: #keyPath(DiscussionEntry.id), equals: entryID)
        entry?.isRemoved = true
    }
}
