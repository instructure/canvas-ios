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
import MobileCoreServices
import UIKit
import CryptoKit
import UniformTypeIdentifiers
import SwiftUI

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
    @NSManaged public var gradingPeriodId: String?
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
        model.gradingPeriodId = item.grading_period_id?.value
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
            return String.localizedAttemptNumber(attempt)
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
            (type != nil && (workflowState == .pending_review ||
                                ([.graded, .submitted].contains(workflowState) &&
                                    (score == nil || !gradeMatchesCurrentSubmission))
            ))
    }

    public var isGraded: Bool {
        return excused == true || (score != nil && workflowState == .graded)
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
            return needsGrading == false ? .graded : desc // Maintaining the old logic
        case .onPaper, .noSubmission:
            return isGraded ? .graded : desc
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
}

/// This is merely used to properly describe the state of submission in certain contexts.
/// It is not strictly matching `SubmissionStatus` in all cases. And it is not
/// meant to replace status cases, or be used in all related areas of the apps.
/// i.e. use with caution.
public enum SubmissionStateDisplayProperties: Equatable {
    case usingStatus(SubmissionStatus)
    case onPaper
    case noSubmission
    case graded

    public var text: String {
        switch self {
        case .usingStatus(let status):
            return status.text
        case .onPaper:
            return String(localized: "On Paper", bundle: .core)
        case .noSubmission:
            return String(localized: "No Submission", bundle: .core)
        case .graded:
            return String(localized: "Graded", bundle: .core)
        }
    }

    public var color: UIColor {
        switch self {
        case .usingStatus(let status):
            return status.color
        case .onPaper, .noSubmission:
            return .textDark
        case .graded:
            return .textSuccess
        }
    }

    public var icon: UIImage {
        switch self {
        case .usingStatus(let status):
            return status.icon
        case .onPaper, .noSubmission:
            return .noSolid
        case .graded:
            return .completeSolid
        }
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
            return String(localized: "Late", bundle: .core)
        case .missing:
            return String(localized: "Missing", bundle: .core)
        case .submitted:
            return String(localized: "Submitted", bundle: .core)
        case .notSubmitted:
            return String(localized: "Not Submitted", bundle: .core)
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
            return .completeLine
        case .late:
            return .clockSolid
        case .missing, .notSubmitted:
            return .noSolid
        }
    }
}

public enum SubmissionType: String, Codable, CaseIterable {
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
            return String(localized: "Discussion Comment", bundle: .core)
        case .external_tool, .basic_lti_launch:
            return String(localized: "External Tool", bundle: .core)
        case .media_recording:
            return String(localized: "Media Recording", bundle: .core)
        case .none:
            return String(localized: "No Submission", bundle: .core)
        case .not_graded:
            return String(localized: "Not Graded", bundle: .core)
        case .online_quiz:
            return String(localized: "Quiz", bundle: .core)
        case .online_text_entry:
            return String(localized: "Text Entry", bundle: .core)
        case .online_upload:
            return String(localized: "File Upload", bundle: .core)
        case .online_url:
            return String(localized: "Website URL", bundle: .core)
        case .on_paper:
            return String(localized: "On Paper", bundle: .core)
        case .wiki_page:
            return String(localized: "Page", bundle: .core)
        case .student_annotation:
            return String(localized: "Student Annotation", bundle: .core)

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

    public func isStudioAccepted(
        allowedExtensions: [String]
    ) -> Bool {
        guard self.contains(.online_upload) else {
            return false
        }

        if allowedExtensions.isEmpty {
            return true
        }

        for allowedExtension in allowedExtensions {
            guard let fileType = UTType(filenameExtension: allowedExtension) else {
                continue
            }
            if fileType.conforms(to: .audiovisualContent) {
                return true
            }
        }

        return false
    }
}

public enum SubmissionWorkflowState: String, Codable {
    case submitted, unsubmitted, graded, pending_review, complete
}
