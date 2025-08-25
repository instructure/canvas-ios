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
import CryptoKit
import UIKit

final public class Submission: NSManagedObject, Identifiable {
    @NSManaged public var assignment: Assignment?
    @NSManaged public var assignmentID: String
    @NSManaged public var attachments: Set<File>?
    @NSManaged public var attempt: Int
    @NSManaged public var body: String?
    @NSManaged public var customGradeStatusId: String?
    @NSManaged public var customGradeStatusName: String?
    @NSManaged public var discussionEntries: Set<DiscussionEntry>?
    @NSManaged public var dueAt: Date?
    @NSManaged public var enteredGrade: String?
    @NSManaged var enteredScoreRaw: NSNumber?
    @NSManaged var excusedRaw: NSNumber?
    @NSManaged public var externalToolURL: URL?
    @NSManaged public var grade: String?
    @NSManaged public var gradedAt: Date?
    @NSManaged public var gradeMatchesCurrentSubmission: Bool
    @NSManaged public var gradingPeriodId: String?
    @NSManaged public var groupID: String?
    @NSManaged public var groupName: String?
    @NSManaged public var id: String
    @NSManaged public var isLatest: Bool
    @NSManaged public var late: Bool
    @NSManaged var latePolicyStatusRaw: String?
    @NSManaged public var lateSeconds: Int
    @NSManaged public var missing: Bool
    @NSManaged var pointsDeductedRaw: NSNumber?
    @NSManaged public var postedAt: Date?
    @NSManaged public var previewUrl: URL?
    @NSManaged var scoreRaw: NSNumber?
    @NSManaged public var shuffleOrder: String
    @NSManaged public var similarityScore: Double
    @NSManaged public var similarityStatus: String?
    @NSManaged public var similarityURL: URL?
    @NSManaged public var sortableName: String?
    @NSManaged public var submittedAt: Date?
    @NSManaged var typeRaw: String?
    @NSManaged public var url: URL?
    @NSManaged public var userID: String
    @NSManaged public var workflowStateRaw: String

    @NSManaged public var enrollments: Set<Enrollment>
    @NSManaged public var mediaComment: MediaComment?
    @NSManaged public var rubricAssesmentRaw: Set<RubricAssessment>?
    @NSManaged public var user: User?

    /// Transient property to use for group resolving in Teacher's submission list
    public var fetchedGroup: FetchedGroup?
    public var displayGroupName: String? { groupName ?? fetchedGroup?.name }

    public var rubricAssessments: RubricAssessments? {
        if let assessments = rubricAssesmentRaw, assessments.count > 0 {
            var map = RubricAssessments()
            assessments.forEach { map[$0.id] = $0 }
            return map
        }
        return nil
    }

    public var attachmentsSorted: [File] {
        attachments?.sorted(by: File.idCompare) ?? []
    }

    public var enteredScore: Double? {
        get { return enteredScoreRaw?.doubleValue }
        set { enteredScoreRaw = NSNumber(value: newValue) }
    }

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

    /** Returns a score between 1.0 and 0.0 by dividing the submission's score by the assignments total score. */
    public var normalizedScore: Double? {
        guard let pointsPossible = assignment?.pointsPossible,
              let score else {
            return nil
        }

        return score / pointsPossible
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

extension Submission {

    public struct FetchedGroup {
        public let id: String
        public let name: String

        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }
}

extension Submission: WriteableModel {
    public typealias JSON = APISubmission

    @discardableResult
    // swiftlint:disable:next function_body_length
    static public func save(_ item: APISubmission, in client: NSManagedObjectContext) -> Submission {
        let predicate = NSPredicate(
            format: "%K == %@ AND %K == %@ AND %K == %d",
            #keyPath(Submission.assignmentID),
            item.assignment_id.value,
            #keyPath(Submission.userID),
            item.user_id.value,
            #keyPath(Submission.attempt),
            item.attempt ?? 0
        )
        let model: Submission = client.fetch(predicate).first ?? client.insert()
        model.assignmentID = item.assignment_id.value
        model.attempt = item.attempt ?? 0
        model.body = item.body
        model.customGradeStatusId = item.custom_grade_status_id

        if let customStatusId = item.custom_grade_status_id {
            let customStatus: CDCustomGradeStatus? = client.first(
                where: #keyPath(CDCustomGradeStatus.id), equals: customStatusId
            )
            model.customGradeStatusName = customStatus?.name
        }

        model.dueAt = item.cached_due_date
        model.enteredGrade = item.entered_grade
        model.enteredScore = item.entered_score
        model.excused = item.excused
        model.externalToolURL = item.external_tool_url?.rawValue
        model.grade = item.grade
        model.gradedAt = item.graded_at
        model.gradeMatchesCurrentSubmission = item.grade_matches_current_submission
        model.gradingPeriodId = item.grading_period_id?.value
        model.groupID = item.group?.id?.value
        model.groupName = item.group?.name
        model.id = item.id.value
        model.late = item.late == true
        model.latePolicyStatus = item.late_policy_status
        model.lateSeconds = item.seconds_late ?? 0
        model.missing = item.missing == true
        model.pointsDeducted = item.points_deducted
        model.postedAt = item.posted_at
        model.previewUrl = item.preview_url
        model.score = item.score
        model.sortableName = item.group?.name ?? item.user?.sortable_name
        model.submittedAt = item.submitted_at
        model.type = item.submission_type
        model.url = item.url
        model.userID = item.user_id.value
        model.workflowState = item.workflow_state
        if let user = item.user {
            model.user = User.save(user, in: client)
        }
        // Non-cryptographic hash, used only as a deterministic somewhat random sort order
        model.shuffleOrder = item.id.value.data(using: .utf8).flatMap {
            Insecure.MD5.hash(data: $0).map { String(format: "%02x", $0) } .joined()
        } ?? ""

        let turnitin = item.turnitin_data?.rawValue["submission_\(model.id)"]
        model.similarityScore = turnitin?.similarity_score ?? 0
        model.similarityStatus = turnitin?.status
        model.similarityURL = turnitin?.outcome_response?.outcomes_tool_placement_url?.rawValue

        model.attachments = Set(item.attachments?.map { attachment in
            let file = File.save(attachment, in: client)
            let turnitin = item.turnitin_data?.rawValue["attachment_\(attachment.id)"]
            file.similarityScore = turnitin?.similarity_score ?? 0
            file.similarityStatus = turnitin?.status
            file.similarityURL = turnitin?.outcome_response?.outcomes_tool_placement_url?.rawValue
            return file
        } ?? [])

        model.discussionEntries = Set(item.discussion_entries?.map { entry in
            return DiscussionEntry.save(entry, in: client)
        } ?? [])

        if let mediaComment = item.media_comment {
            model.mediaComment = MediaComment.save(mediaComment, in: client)
        }

        if let comments = item.submission_comments {
            let allPredicate = NSPredicate(format: "%K == %@ AND %K == %@",
                #keyPath(SubmissionComment.assignmentID),
                item.assignment_id.value,
                #keyPath(SubmissionComment.userID),
                item.user_id.value
            )
            let all: [SubmissionComment] = client.fetch(allPredicate)
            client.delete(all)
            for comment in comments {
                SubmissionComment.save(comment, for: item, in: client)
            }
        }
        if item.submission_type != nil, item.submission_type != SubmissionType.none, item.submission_type != .not_graded, item.submission_type != .on_paper {
            SubmissionComment.save(item, in: client)
        }

        if let submissionHistory = item.submission_history {
            // don't save histories where attempts are null or else it will overwrite
            // the top level submission. This is the case for submissions with a grade
            // but are still "unsubmitted"
            for var submission in submissionHistory where submission.attempt != nil && submission.attempt != item.attempt {
                submission.user = item.user
                Submission.save(submission, in: client).isLatest = false
            }
            model.isLatest = true
        }

        let assignmentPredicate = NSPredicate(format: "%K == %@", (\Assignment.id).string, item.assignment_id.value)
        if let apiAssignment = item.assignment {
            let assignment: Assignment = client.fetch(assignmentPredicate).first ?? client.insert()
            assignment.update(fromApiModel: apiAssignment, in: client, updateSubmission: false, updateScoreStatistics: false)
            assignment.submission = model
        } else if let assignment: Assignment = client.fetch(assignmentPredicate).first {
            assignment.submission = model
        }

        if let rubricAssessmentMap = item.rubric_assessment {
            let allPredicate = NSPredicate(format: "%K == %@", #keyPath(RubricAssessment.submissionID), item.id.value)
            let all: [RubricAssessment] = client.fetch(allPredicate)
            client.delete(all)
            model.rubricAssesmentRaw = Set()
            for (k, v) in rubricAssessmentMap {
                let i = v as APIRubricAssessment
                let a = RubricAssessment.save(i, in: client, id: k, submissionID: item.id.value)
                model.rubricAssesmentRaw?.insert(a)
            }
        }

        if let courseID = model.assignment?.courseID {
            let enrollments: [Enrollment] = client.fetch(NSPredicate(format: "%K == %@ AND %K == %@",
                #keyPath(Enrollment.canvasContextID), "course_\(courseID)",
                #keyPath(Enrollment.userID), item.user_id.value
            ))
            model.enrollments.formUnion(enrollments)
        }

        return model
    }
}

extension Submission {

    private var typeWithQuizLTIMapping: SubmissionType? {
        if let assignment, assignment.isQuizLTI {
            .online_quiz
        } else {
            type
        }
    }

    public var attemptIcon: UIImage? {
        guard let typeWithQuizLTIMapping else { return nil }

        switch typeWithQuizLTIMapping {
        case .basic_lti_launch, .external_tool:
            return .ltiLine
        case .discussion_topic:
            return .discussionLine
        case .media_recording:
            return mediaComment?.mediaType == .audio ? .audioLine : .videoLine
        case .online_quiz:
            return .quizLine
        case .online_text_entry:
            return .textLine
        case .online_upload:
            return attachments?.first?.icon
        case .online_url:
            return .linkLine
        case .student_annotation:
            return .annotateLine
        case .wiki_page:
            return .documentLine
        case .none, .not_graded, .on_paper:
            return nil
        }
    }

    public var attemptTitle: String? {
        typeWithQuizLTIMapping?.localizedString
    }

    public var attemptSubtitle: String? {
        guard let typeWithQuizLTIMapping else { return nil }

        switch typeWithQuizLTIMapping {
        case .basic_lti_launch, .external_tool, .online_quiz:
            return String.format(attemptNumber: attempt)
        case .discussion_topic:
            return discussionEntriesOrdered.first?.message?.htmlToPlainText(lineBreaks: " ")
        case .media_recording:
            return mediaComment?.mediaType == .audio
                ? String(localized: "Audio", bundle: .core)
                : String(localized: "Video", bundle: .core)
        case .online_text_entry:
            return body?.htmlToPlainText(lineBreaks: " ")
        case .online_upload:
            return attachments?.first?.size.humanReadableFileSize
        case .online_url:
            return url?.absoluteString
        case .none, .not_graded, .on_paper, .wiki_page, .student_annotation:
            return nil
        }
    }

    public var attemptAccessibilityDescription: String? {
        guard let typeWithQuizLTIMapping else { return nil }

        let title = typeWithQuizLTIMapping.localizedString

        let subtitle: String? = switch typeWithQuizLTIMapping {
        case .basic_lti_launch, .external_tool, .online_quiz:
            // omitting attempt number, as it is included elsewhere
            nil
        case .discussion_topic:
            discussionEntriesOrdered.first?.message?
                .htmlToPlainText(lineBreaks: "\n")
                .components(separatedBy: "\n")
                .first
        case .online_text_entry:
            body?
                .htmlToPlainText(lineBreaks: "\n")
                .components(separatedBy: "\n")
                .first
        case .online_upload:
            // omitting file size, as it is included elsewhere for each file
            nil
        default:
            attemptSubtitle
        }

        return [title, subtitle].joined(separator: ", ")
    }
}

private extension String {
    func htmlToPlainText(lineBreaks lineBreakReplacement: String) -> String {
        self
            .replacingOccurrences(of: "<div>", with: lineBreakReplacement)
            .replacingOccurrences(of: "<br>", with: lineBreakReplacement)
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}

extension Submission {

    /// See canvas-lms submission.rb `def needs_grading?`
    public var needsGrading: Bool {
        return excused != true &&
            customGradeStatusId == nil &&
            (type != nil && (workflowState == .pending_review ||
                                ([.graded, .submitted].contains(workflowState) &&
                                    (score == nil || !gradeMatchesCurrentSubmission))
            ))
    }

    public var isGraded: Bool {
        return excused == true
            || customGradeStatusId != nil
            || (score != nil && workflowState == .graded)
    }

    /// Returns the appropriate display properties for submission, with consideration for
    /// `onPaper` & `noSubmission` submission type.
    /// If the submission has been submitted and it's graded already, then it returns `Graded`.
    /// Otherwise it returns the submissions's status.
    /// `Graded` submissions that have been resubmitted will return `Submitted`.
    /// For `onPaper` & `noSubmission`, it would return `Graded` only for when the submission
    /// **has a** grade associated with it.
    public var stateDisplayProperties: SubmissionStateDisplayProperties {
        let desc: SubmissionStateDisplayProperties = {
            if case .notSubmitted = status {
                if let submissionTypes = assignment?.submissionTypes {
                    if submissionTypes.contains(.on_paper) { return .onPaper }
                    if submissionTypes.contains(.none) { return .noSubmission }
                }
                return .usingStatus(.notSubmitted)
            } else {
                return .usingStatus(status)
            }
        }()

        // Graded check
        switch desc {
        case .usingStatus(.submitted):
            return needsGrading == false ? gradedState : desc // Maintaining the old logic
        case .onPaper, .noSubmission:
            return isGraded ? gradedState : desc
        case .usingStatus(.notSubmitted):
            return isGraded ? gradedState : desc
        default:
            return desc
        }
    }

    public var status: SubmissionStatus {
        if late { return .late }
        if missing { return .missing }
        if submittedAt != nil { return .submitted }
        return .notSubmitted
    }

    public var statusIncludingGradedState: SubmissionStatus {
        if isGraded {
            if excused == true { return .excused }
            if customGradeStatusId != nil { return customGradedStatus }
            return .graded
        }
        return status
    }

    private var gradedState: SubmissionStateDisplayProperties {
        if customGradeStatusId != nil,
           let name = customGradeStatusName {
            return .usingStatus(.custom(name))
        }
        return .graded
    }

    private var customGradedStatus: SubmissionStatus {
        if let name = customGradeStatusName {
            return .custom(name)
        }
        return .graded
    }
}

extension Submission: Comparable {

    /// This nearly matching ordering used in GetSubmissions use case.
    public static func < (lhs: Submission, rhs: Submission) -> Bool {
        let lhsSortableName = lhs.sortableName ?? lhs.user?.sortableName
        let rhsSortableName = rhs.sortableName ?? rhs.user?.sortableName

        if let name1 = lhsSortableName, let name2 = rhsSortableName {
            return name1 < name2
        }

        return lhs.userID < rhs.userID
    }
}

extension Submission: DueViewable {}

public enum SubmissionWorkflowState: String, Codable {
    case submitted, unsubmitted, graded, pending_review, complete
}
