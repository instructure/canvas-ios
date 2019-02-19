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

public class Submission: NSManagedObject {
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

extension Submission: Scoped {
    public enum ScopeKeys {
        case forUserOnAssignment(String, String)
    }

    public static func scope(forName name: Submission.ScopeKeys) -> Scope {
        switch name {
        case let .forUserOnAssignment(assignmentID, userID):
            let assignmentPredicate = Scope.where(#keyPath(Submission.assignmentID), equals: assignmentID).predicate
            let userPredicate = Scope.where(#keyPath(Submission.userID), equals: userID).predicate
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [assignmentPredicate, userPredicate])
            let sort = NSSortDescriptor(key: #keyPath(Submission.attempt), ascending: true)
            return Scope(predicate: compoundPredicate, order: [sort])
        }
    }
}

extension Submission {
    func update(fromApiModel item: APISubmission, in client: PersistenceClient) throws {
        id = item.id.value
        assignmentID = item.assignment_id.value
        userID = item.user_id.value
        body = item.body
        grade = item.grade
        score = item.score
        submittedAt = item.submitted_at
        late = item.late
        excused = item.excused ?? false
        missing = item.missing
        workflowState = item.workflow_state
        latePolicyStatus = item.late_policy_status
        pointsDeducted = item.points_deducted
        attempt = item.attempt ?? 0
        type = item.submission_type
        attachments = nil
        url = item.url
        previewUrl = item.preview_url
        if let files = item.attachments {
            let fileModels: [File] = try files.map { (attachment: APIFile) in
                let file: File = client.fetch(predicate: .id(attachment.id.value), sortDescriptors: nil).first ?? client.insert()
                try file.update(fromApiModel: attachment, in: client)
                return file
            }
            attachments = Set(fileModels)
        }

        if let discussions = item.discussion_entries {
            let discussionModels: [DiscussionEntry] = try discussions.map { (apiEntry: APIDiscussionEntry) in
                let discussionEntry: DiscussionEntry = client.fetch(predicate: .id(apiEntry.id.value), sortDescriptors: nil).first ?? client.insert()
                try discussionEntry.update(fromApiModel: apiEntry, in: client)
                return discussionEntry
            }
            discussionEntries = Set(discussionModels)
        }
    }
}
