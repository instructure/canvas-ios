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

import CoreData
import Foundation
import MobileCoreServices
import UIKit
import CryptoKit
import UniformTypeIdentifiers

public typealias RubricAssessments = [String: RubricAssessment]

public final class SubmissionList: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged var submissionsRaw: NSOrderedSet
    public var submissions: [Submission] {
        get { submissionsRaw.array.compactMap { $0 as? Submission } }
        set { submissionsRaw = NSOrderedSet(array: newValue) }
    }
}

final public class Submission: NSManagedObject, Identifiable {
    @NSManaged public var assignment: Assignment?
    @NSManaged public var assignmentID: String
    @NSManaged public var attachments: Set<File>?
    @NSManaged public var attempt: Int
    @NSManaged public var body: String?
    @NSManaged public var discussionEntries: Set<DiscussionEntry>?
    @NSManaged public var enteredGrade: String?
    @NSManaged var enteredScoreRaw: NSNumber?
    @NSManaged var excusedRaw: NSNumber?
    @NSManaged public var externalToolURL: URL?
    @NSManaged public var grade: String?
    @NSManaged public var gradedAt: Date?
    @NSManaged public var gradeMatchesCurrentSubmission: Bool
    @NSManaged public var groupID: String?
    @NSManaged public var groupName: String?
    @NSManaged public var id: String
    @NSManaged public var isLatest: Bool
    @NSManaged public var late: Bool
    @NSManaged var latePolicyStatusRaw: String?
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

    public var rubricAssessments: RubricAssessments? {
        if let assessments = rubricAssesmentRaw, assessments.count > 0 {
            var map = RubricAssessments()
            assessments.forEach { map[$0.id] = $0 }
            return map
        }
        return nil
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
        model.enteredGrade = item.entered_grade
        model.enteredScore = item.entered_score
        model.excused = item.excused
        model.externalToolURL = item.external_tool_url?.rawValue
        model.grade = item.grade
        model.gradedAt = item.graded_at
        model.gradeMatchesCurrentSubmission = item.grade_matches_current_submission
        model.groupID = item.group?.id?.value
        model.groupName = item.group?.name
        model.id = item.id.value
        model.late = item.late == true
        model.latePolicyStatus = item.late_policy_status
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

        let assignmentPredicate = NSPredicate(format: "%K == %@", #keyPath(Assignment.id), item.assignment_id.value)
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
    public var icon: UIImage? {
        guard let type = type else { return nil }
        switch type {
        case .basic_lti_launch, .external_tool:
            return UIImage.ltiLine
        case .discussion_topic:
            return UIImage.discussionLine
        case .media_recording:
            return mediaComment?.mediaType == .audio ? UIImage.audioLine : UIImage.videoLine
        case .online_quiz:
            return UIImage.quizLine
        case .online_text_entry:
            return UIImage.textLine
        case .online_upload:
            return attachments?.first?.icon
        case .online_url:
            return UIImage.linkLine
        case .student_annotation:
            return UIImage.annotateLine
        case .wiki_page:
            return UIImage.documentLine
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
            return attachments?.first?.size.humanReadableFileSize
        case .online_url:
            return url?.absoluteString
        case .none, .not_graded, .on_paper, .wiki_page, .student_annotation:
            return nil
        }
    }

    /// See canvas-lms submission.rb `def needs_grading?`
    public var needsGrading: Bool {
        return excused != true &&
            (type != nil && (workflowState == .pending_review ||
                                ([.graded, .submitted].contains(workflowState) &&
                                    (score == nil || !gradeMatchesCurrentSubmission))
            ))
    }

    public var isGraded: Bool {
        return excused == true || (score != nil && workflowState == .graded)
    }

    public var status: SubmissionStatus {
        if late { return .late }
        if missing { return .missing }
        if submittedAt != nil { return .submitted}
        return .notSubmitted
    }
}

public enum SubmissionStatus {
    case late
    case missing
    case submitted
    case notSubmitted

    public var text: String {
        switch self {
        case .late:
            return NSLocalizedString("Late", bundle: .core, comment: "")
        case .missing:
            return NSLocalizedString("Missing", bundle: .core, comment: "")
        case .submitted:
            return NSLocalizedString("Submitted", bundle: .core, comment: "")
        case .notSubmitted:
            return NSLocalizedString("Not Submitted", bundle: .core, comment: "")
        }
    }

    public var color: UIColor {
        switch self {
        case .late:
            return .textWarning
        case .missing:
            return .textDanger
        case .submitted:
            return .textSuccess
        case .notSubmitted:
            return .textDark
        }
    }

    public var icon: UIImage {
        switch self {
        case .submitted:
            return .completeSolid
        case .late:
            return .clockSolid
        case .missing, .notSubmitted:
            return .noSolid
        }
    }
}

public enum SubmissionType: String, Codable {
    case discussion_topic
    case external_tool
    case media_recording
    case none
    case not_graded
    case online_quiz
    case online_text_entry
    case online_upload
    case online_url
    case on_paper
    case basic_lti_launch
    case wiki_page
    case student_annotation

    public var localizedString: String {
        switch self {
        case .discussion_topic:
            return NSLocalizedString("Discussion Comment", bundle: .core, comment: "")
        case .external_tool, .basic_lti_launch:
            return NSLocalizedString("External Tool", bundle: .core, comment: "")
        case .media_recording:
            return NSLocalizedString("Media Recording", bundle: .core, comment: "")
        case .none:
            return NSLocalizedString("No Submission", bundle: .core, comment: "")
        case .not_graded:
            return NSLocalizedString("Not Graded", bundle: .core, comment: "")
        case .online_quiz:
            return NSLocalizedString("Quiz", bundle: .core, comment: "")
        case .online_text_entry:
            return NSLocalizedString("Text Entry", bundle: .core, comment: "")
        case .online_upload:
            return NSLocalizedString("File Upload", bundle: .core, comment: "")
        case .online_url:
            return NSLocalizedString("Website URL", bundle: .core, comment: "")
        case .on_paper:
            return NSLocalizedString("On Paper", bundle: .core, comment: "")
        case .wiki_page:
            return NSLocalizedString("Page", bundle: .core, comment: "")
        case .student_annotation:
            return NSLocalizedString("Student Annotation", bundle: .core, comment: "")

        }
    }
}

extension Array where Element == SubmissionType {
    var isOnline: Bool {
        if contains(.on_paper) || contains(.not_graded) || contains(.none) {
            return false
        }
        return true
    }

    public var allowedMediaTypes: [String] {
        var types  = [UTType.movie.identifier]

        if contains(.media_recording) && !contains(.online_upload) {
            types.append(UTType.audio.identifier)
        } else {
            types.append(UTType.image.identifier)
        }
        return types
    }

    public func allowedUTIs(allowedExtensions: [String] = []) -> [UTI] {
        var utis: [UTI] = []

        if contains(.online_upload) {
            if allowedExtensions.isEmpty {
                utis += [.any]
            } else {
                utis += UTI.from(extensions: allowedExtensions)
            }
        }

        if contains(.media_recording) {
            utis += [.video, .audio]
        }

        if contains(.online_text_entry) {
            utis += [.text]
        }

        if contains(.online_url) {
            utis += [.url]
        }

        return utis
    }
}

public enum SubmissionWorkflowState: String, Codable {
    case submitted, unsubmitted, graded, pending_review, complete
}
