//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

final public class SubmissionComment: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var assignmentID: String
    /// If `assignments_2_student` feature flag is enabled, comments are segmented based on which attempt they belong to. 
    @NSManaged public var attemptFromAPI: NSNumber?
    @NSManaged public var authorAvatarURL: URL?
    @NSManaged public var authorID: String?
    @NSManaged public var authorName: String
    @NSManaged public var authorPronouns: String?
    @NSManaged public var comment: String
    @NSManaged public var createdAt: Date?
    @NSManaged public var editedAt: Date?
    @NSManaged public var mediaID: String?
    @NSManaged public var mediaLocalURL: URL?
    @NSManaged public var mediaName: String?
    @NSManaged public var mediaTypeRaw: String?
    @NSManaged public var mediaURL: URL?
    @NSManaged public var userID: String
    @NSManaged public var attachments: Set<File>?

    /// If set, this comment represents an actual submission attempt
    ///
    /// In the case of these syntesized comments, the id is `"submission-[submissionID]-[attempt]"`
    public var attempt: Int? {
        let parts = id.split(separator: "-", maxSplits: 3, omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        return Int(parts[2])
    }

    public var mediaLocalOrRemoteURL: URL? {
        if let url = mediaLocalURL, FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return mediaURL
    }

    public var mediaType: MediaCommentType? {
        get { return mediaTypeRaw.flatMap { MediaCommentType(rawValue: $0) } }
        set { mediaTypeRaw = newValue?.rawValue }
    }

    public var createdAtLocalizedString: String {
        guard let createdAt = createdAt else { return "" }
        return DateFormatter.localizedString(from: createdAt, dateStyle: .long, timeStyle: .short)
    }

    public var attachmentsSorted: [File] {
        attachments?.sorted(by: File.idCompare) ?? []
    }

    @discardableResult
    static public func save(_ item: APISubmissionComment, for submission: APISubmission, replacing id: String? = nil, in client: NSManagedObjectContext) -> SubmissionComment {
        let model: SubmissionComment = client.first(where: #keyPath(SubmissionComment.id), equals: id ?? item.id) ?? client.insert()
        model.id = item.id
        model.assignmentID = submission.assignment_id.value
        if let attempt = item.attempt {
            model.attemptFromAPI = NSNumber(value: attempt)
        }
        model.authorAvatarURL = item.author.avatar_image_url?.rawValue
        model.authorID = item.author_id?.value
        model.authorName = item.author.display_name ?? item.author_name
        model.authorPronouns = item.author.pronouns
        model.comment = item.comment
        model.createdAt = item.created_at
        model.editedAt = item.edited_at
        model.mediaID = item.media_comment?.media_id
        model.mediaName = item.media_comment?.display_name
        model.mediaType = item.media_comment?.media_type
        model.mediaURL = item.media_comment?.url
        model.userID = submission.user_id.value
        if let attachments = item.attachments {
            model.attachments = Set(File.save(attachments, in: client))
        }
        return model
    }

    @discardableResult
    static public func save(_ item: APISubmission, in client: NSManagedObjectContext) -> SubmissionComment? {
        guard let attempt = item.attempt, let submittedAt = item.submitted_at else { return nil }
        let id = "submission-\(item.id)-\(attempt)"
        let predicate = NSPredicate(format: "%K == %@", #keyPath(SubmissionComment.id), id)
        let model: SubmissionComment = client.fetch(predicate).first ?? client.insert()
        model.id = id
        model.assignmentID = item.assignment_id.value
        model.authorAvatarURL = item.user?.avatar_url?.rawValue
        model.authorID = item.user_id.value
        model.authorName = item.user?.short_name ?? ""
        model.authorPronouns = item.user?.pronouns
        model.comment = ""
        model.createdAt = submittedAt
        model.editedAt = submittedAt
        model.userID = item.user_id.value
        return model
    }
}
