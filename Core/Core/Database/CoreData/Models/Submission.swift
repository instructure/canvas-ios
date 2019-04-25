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
import UIKit

final public class Submission: NSManagedObject {
    @NSManaged public var assignment: Assignment?
    @NSManaged public var assignmentID: String
    @NSManaged public var userID: String
    @NSManaged public var body: String?
    @NSManaged var excusedRaw: NSNumber?
    @NSManaged public var grade: String?
    @NSManaged public var id: String
    @NSManaged public var late: Bool
    @NSManaged var latePolicyStatusRaw: String?
    @NSManaged public var missing: Bool
    @NSManaged var pointsDeductedRaw: NSNumber?
    @NSManaged var scoreRaw: NSNumber?
    @NSManaged var typeRaw: String?
    @NSManaged public var submittedAt: Date?
    @NSManaged public var workflowStateRaw: String
    @NSManaged public var attempt: Int
    @NSManaged public var attachments: Set<File>?
    @NSManaged public var discussionEntries: Set<DiscussionEntry>?
    @NSManaged public var previewUrl: URL?
    @NSManaged public var url: URL?

    @NSManaged public var mediaComment: MediaComment?

    public var excused: Bool? {
        get { return excusedRaw?.boolValue }
        set { excusedRaw = NSNumber(value: newValue) }
    }

    public var latePolicyStatus: LatePolicyStatus? {
        get { return LatePolicyStatus(rawValue: latePolicyStatusRaw ?? "") }
        set { latePolicyStatusRaw = newValue?.rawValue }
    }

    public var pointsDeducted: Double? {
        get { return pointsDeductedRaw?.doubleValue }
        set { pointsDeductedRaw = NSNumber(value: newValue) }
    }

    public var score: Double? {
        get { return scoreRaw?.doubleValue }
        set { scoreRaw = NSNumber(value: newValue) }
    }

    public var type: SubmissionType? {
        get { return SubmissionType(rawValue: typeRaw ?? "") }
        set { typeRaw = newValue?.rawValue }
    }

    public var workflowState: SubmissionWorkflowState {
        get { return SubmissionWorkflowState(rawValue: workflowStateRaw) ?? .unsubmitted }
        set { workflowStateRaw = newValue.rawValue }
    }

    public var discussionEntriesOrdered: [DiscussionEntry] {
        return discussionEntries?.sorted(by: { $0.id < $1.id }) ?? []
    }
}

extension Submission: WriteableModel {
    public typealias JSON = APISubmission

    @discardableResult
    static public func save(_ item: APISubmission, in client: PersistenceClient) throws -> Submission {
        let predicate = NSPredicate(
            format: "%K == %@ AND %K == %@ AND %K == %d",
            #keyPath(Submission.assignmentID),
            item.assignment_id.value,
            #keyPath(Submission.userID),
            item.user_id.value,
            #keyPath(Submission.attempt),
            item.attempt ?? 1
        )
        let model: Submission = client.fetch(predicate).first ?? client.insert()
        model.id = item.id.value
        model.assignmentID = item.assignment_id.value
        model.userID = item.user_id.value
        model.body = item.body
        model.grade = item.grade
        model.score = item.score
        model.submittedAt = item.submitted_at
        model.late = item.late
        model.excused = item.excused
        model.missing = item.missing
        model.workflowState = item.workflow_state
        model.latePolicyStatus = item.late_policy_status
        model.pointsDeducted = item.points_deducted
        model.attempt = item.attempt ?? 1
        model.type = item.submission_type
        model.url = item.url
        model.previewUrl = item.preview_url

        model.attachments = Set(try item.attachments?.map { attachment in
            return try File.save(attachment, in: client)
        } ?? [])

        model.discussionEntries = Set(item.discussion_entries?.map { entry in
            return DiscussionEntry.save(entry, in: client)
        } ?? [])

        if let mediaComment = item.media_comment {
            model.mediaComment = try MediaComment.save(mediaComment, in: client)
        }

        if let comments = item.submission_comments {
            let allPredicate = NSPredicate(format: "%K == %@", #keyPath(SubmissionComment.submissionID), item.id.value)
            let all: [SubmissionComment] = client.fetch(allPredicate)
            try client.delete(all)
            for comment in comments {
                SubmissionComment.save(comment, forSubmission: item.id.value, in: client)
            }
        }
        if item.submission_type != nil, item.submission_type != .none, item.submission_type != .not_graded, item.submission_type != .on_paper {
            SubmissionComment.save(item, in: client)
        }

        if let submissionHistory = item.submission_history {
            for var submission in submissionHistory {
                submission.user = item.user
                try Submission.save(submission, in: client)
            }
        }

        let assignmentPredicate = NSPredicate(format: "%K == %@", #keyPath(Assignment.id), item.assignment_id.value)
        if let assignment: Assignment = client.fetch(assignmentPredicate).first {
            assignment.submission = model // trigger assignment change notification
        }

        return model
    }
}

extension Submission {
    public var icon: UIImage? {
        guard let type = type else { return nil }
        switch type {
        case .basic_lti_launch, .external_tool:
            return UIImage.icon(.lti)
        case .discussion_topic:
            return UIImage.icon(.discussion)
        case .media_recording:
            return UIImage.icon(mediaComment?.mediaType == .audio ? .audio : .video)
        case .online_quiz:
            return UIImage.icon(.quiz)
        case .online_text_entry:
            return UIImage.icon(.text)
        case .online_upload:
            return attachments?.first?.icon
        case .online_url:
            return UIImage.icon(.link)
        case .none, .not_graded, .on_paper:
            return nil
        }
    }

    public var subtitle: String? {
        guard let type = type else { return nil }
        switch type {
        case .basic_lti_launch, .external_tool, .online_quiz:
            return String.localizedStringWithFormat(
                NSLocalizedString("Attempt %d", bundle: .core, comment: ""),
                attempt
            )
        case .discussion_topic:
            return discussionEntriesOrdered.first?.message?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        case .media_recording:
            return mediaComment?.mediaType == .audio
                ? NSLocalizedString("Audio", bundle: .core, comment: "")
                : NSLocalizedString("Video", bundle: .core, comment: "")
        case .online_text_entry:
            return body?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        case .online_upload:
            return (attachments?.first?.size).flatMap {
                ByteCountFormatter.string(fromByteCount: Int64($0), countStyle: .file)
            }
        case .online_url:
            return url?.absoluteString
        case .none, .not_graded, .on_paper:
            return nil
        }
    }
}
