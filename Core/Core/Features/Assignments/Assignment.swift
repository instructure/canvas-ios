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
import SwiftUI

public class Assignment: NSManagedObject {
    @NSManaged public var allDates: Set<AssignmentDate>
    @NSManaged public var allowedAttempts: Int // 0 is flag disabled, -1 is unlimited
    @NSManaged public var allowedExtensionsRaw: String
    /**
     The ID of the file to be annotated by students in case of a student_annotation type assignment, nil otherwise.
     */
    @NSManaged public var annotatableAttachmentID: String?
    @NSManaged public var anonymizeStudents: Bool
    @NSManaged public var anonymousSubmissions: Bool
    @NSManaged public var assignmentGroup: AssignmentGroup?
    @NSManaged public var assignmentGroupID: String?
    @NSManaged public var assignmentGroupPosition: Int
    @NSManaged public var canSubmit: Bool
    @NSManaged public var canUnpublish: Bool
    @NSManaged public var courseID: String
    @NSManaged public var details: String?
    @NSManaged public var discussionTopic: DiscussionTopic?
    @NSManaged public var dueAt: Date?
    @NSManaged public var dueAtSortNilsAtBottom: Date?
    @NSManaged public var externalToolContentID: String?
    @NSManaged public var freeFormCriterionCommentsOnRubric: Bool
    @NSManaged public var gradedIndividually: Bool
    @NSManaged public var gradingPeriod: GradingPeriod?
    @NSManaged public var gradingTypeRaw: String
    @NSManaged public var groupCategoryID: String?
    @NSManaged public var hasSubmittedSubmissions: Bool
    @NSManaged public var hasOverrides: Bool
    @NSManaged public var hideRubricPoints: Bool
    @NSManaged public var htmlURL: URL?
    @NSManaged public var id: String
    @NSManaged public var inClosedGradingPeriod: Bool
    @NSManaged public var isQuizLTI: Bool
    @NSManaged public var lastUpdatedAt: Date?
    @NSManaged public var lockAt: Date?
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?
    @NSManaged public var masteryPathAssignment: MasteryPathAssignment?
    @NSManaged public var moderatedGrading: Bool
    @NSManaged public var name: String
    @NSManaged public var needsGradingCount: Int
    @NSManaged public var onlyVisibleToOverrides: Bool
    @NSManaged public var overrides: Set<AssignmentOverride>
    @NSManaged public var pointsPossibleRaw: NSNumber?
    @NSManaged public var position: Int
    @NSManaged public var published: Bool
    @NSManaged public var quizID: String?
    @NSManaged public var rubricPointsPossibleRaw: NSNumber?
    @NSManaged public var rubricRaw: NSOrderedSet?
    @NSManaged public var scoreStatistics: ScoreStatistics?
    @NSManaged public var submissionTypesRaw: String
    @NSManaged public var syllabus: Syllabus?
    @NSManaged public var todo: Todo?
    @NSManaged public var unlockAt: Date?
    @NSManaged public var url: URL?
    @NSManaged public var useRubricForGrading: Bool
    @NSManaged public var hideInGradeBook: Bool

    /**
     Use this property (vs. submissions) when you want the most recent submission
     commonly for a student (i.e. Student app, all submissions returned are for 1 particular student)
     - Returns: most recent submission from student
     */
    public var submission: Submission? {
        get {
            return submissions?.first
        }

        set {
            if let v = newValue {
                self.submissions = Set<Submission>( [v] )
            } else {
                self.submissions = nil
            }
        }
    }
    /**
     Use this property (vs. submission) when you have an assignment with submissions
     from multiple students (i.e. Parent app when user is observer role)
     - Returns: all submissions related to assignment that may be for various different students
     */
    @NSManaged public var submissions: Set<Submission>?

    public var hideQuantitativeData: Bool {
        let course: Course? = managedObjectContext?.first(where: #keyPath(Course.id), equals: courseID)
        return course?.hideQuantitativeData ?? false
    }

    public var gradingScheme: GradingScheme? {
        guard let course: Course = managedObjectContext?.first(where: #keyPath(Course.id),
                                                               equals: courseID)
        else { return nil }

        return course.gradingScheme
    }

    public var allowedExtensions: [String] {
        get { return allowedExtensionsRaw.split(separator: ",").map { String($0) } }
        set { allowedExtensionsRaw = newValue.joined(separator: ",") }
    }

    public var gradingType: GradingType {
        get { return GradingType(rawValue: gradingTypeRaw) ?? .points }
        set { gradingTypeRaw = newValue.rawValue }
    }

    public var pointsPossible: Double? {
        get { return pointsPossibleRaw?.doubleValue }
        set { pointsPossibleRaw = NSNumber(value: newValue) }
    }

    public var rubric: [CDRubricCriterion]? {
        get { rubricRaw?.array as? [CDRubricCriterion] }
        set { rubricRaw = newValue.map { NSOrderedSet(array: $0) } }
    }

    public var rubricPointsPossible: Double? {
        get { return rubricPointsPossibleRaw?.doubleValue }
        set { rubricPointsPossibleRaw = NSNumber(value: newValue) }
    }

    public var submissionTypes: [SubmissionType] {
        get { return submissionTypesRaw.components(separatedBy: ",").compactMap { SubmissionType(rawValue: $0) } }
        set { submissionTypesRaw = newValue.map { $0.rawValue } .joined(separator: ",") }
    }

    public var submissionTypesWithQuizLTIMapping: [SubmissionType] {
        guard isQuizLTI else { return submissionTypes }

        var types = submissionTypes
        types.removeAll { $0 == .online_quiz }
        types.replace([.external_tool], with: [.online_quiz])
        return types
    }

    public var hasMultipleDueDates: Bool {
        allDates.count > 1
    }

    @objc public var assignmentGroupSectionName: String? {
        guard let assignmentGroup = assignmentGroup else { return nil }
        return assignmentGroup.name
    }

    public var isMasteryPathAssignment: Bool { masteryPathAssignment != nil }

    @discardableResult
    public static func save(_ item: APIAssignment, in context: NSManagedObjectContext, updateSubmission: Bool, updateScoreStatistics: Bool) -> Assignment {
        let assignment: Assignment = context.first(where: (\Assignment.id).string, equals: item.id.value) ?? context.insert()
        assignment.update(fromApiModel: item, in: context, updateSubmission: updateSubmission, updateScoreStatistics: updateScoreStatistics)
        return assignment
    }
}

extension Assignment {
    func update(fromApiModel item: APIAssignment, in client: NSManagedObjectContext, updateSubmission: Bool, updateScoreStatistics: Bool) {
        allowedAttempts = item.allowed_attempts ?? 0
        allowedExtensions = item.allowed_extensions ?? []
        annotatableAttachmentID = item.annotatable_attachment_id
        anonymizeStudents = item.anonymize_students == true
        anonymousSubmissions = item.anonymous_submissions == true
        assignmentGroupID = item.assignment_group_id?.value
        canSubmit = !(item.can_submit == false)
        canUnpublish = item.unpublishable == true
        courseID = item.course_id.value
        details = item.description
        dueAt = item.due_at
        dueAtSortNilsAtBottom = item.due_at ?? Date.distantFuture
        externalToolContentID = item.external_tool_tag_attributes?.content_id?.rawValue
        gradedIndividually = item.grade_group_students_individually ?? true
        gradingType = item.grading_type
        groupCategoryID = item.group_category_id?.value
        hasSubmittedSubmissions = item.has_submitted_submissions ?? false
        hasOverrides = item.has_overrides == true
        htmlURL = item.html_url
        id = item.id.value
        inClosedGradingPeriod = item.in_closed_grading_period ?? false
        isQuizLTI = item.is_quiz_lti_assignment ?? false
        lastUpdatedAt = Date()
        lockAt = item.lock_at
        lockedForUser = item.locked_for_user ?? false
        lockExplanation = item.lock_explanation
        moderatedGrading = item.moderated_grading == true
        name = item.name
        needsGradingCount = item.needs_grading_count ?? 0
        onlyVisibleToOverrides = item.only_visible_to_overrides ?? false
        pointsPossible = item.points_possible
        position = item.position ?? Int.max
        published = item.published != false
        quizID = item.quiz_id?.value
        submissionTypes = item.submission_types
        unlockAt = item.unlock_at
        url = item.url
        useRubricForGrading = item.use_rubric_for_grading ?? false
        hideInGradeBook = item.hide_in_gradebook ?? false

        if anonymousSubmissions == true {
            anonymizeStudents = true
        }

        if let topic = item.discussion_topic {
            discussionTopic = DiscussionTopic.save(topic, in: client)
        } else if discussionTopic != nil {
            self.discussionTopic = nil
        }

        if let exitstingRubrics = rubric {
            client.delete(Array(exitstingRubrics))
            self.rubric = nil
        }

        if let apiRubrics = item.rubric, !apiRubrics.isEmpty {
            rubric = apiRubrics.map { CDRubricCriterion.save($0, assignmentID: item.id.value, in: client) }
        }

        freeFormCriterionCommentsOnRubric = item.rubric_settings?.free_form_criterion_comments == true
        hideRubricPoints = item.rubric_settings?.hide_points == true || hideQuantitativeData
        rubricPointsPossible = item.rubric_settings?.points_possible

        if let assignmentGroupID = item.assignment_group_id?.value,
            let assignmentGroup: AssignmentGroup = client.first(where: #keyPath(AssignmentGroup.id), equals: assignmentGroupID) {
            self.assignmentGroup = assignmentGroup
        } else {
            assignmentGroup = nil
        }

        if updateSubmission {
            if let values = item.submission?.values, values.count > 0 {
                self.submissions = Set<Submission>()
                let newSubs = values.map { Submission.save($0, in: client) }
                self.submissions = Set<Submission>(newSubs)
            } else if let submissions = submissions {
                client.delete(Array(submissions))
                self.submissions = nil
            }
        }

        if updateScoreStatistics {
            if let newStatistics = item.score_statistics {
                let replacementStats = scoreStatistics ?? client.insert()
                replacementStats.update(fromApiModel: newStatistics, in: client)
                self.scoreStatistics = replacementStats
            } else if let scoreStatistics = scoreStatistics {
                client.delete(scoreStatistics)
                self.scoreStatistics = nil
            }
        }

        if let dates = item.all_dates {
            allDates = Set(dates.map {
                AssignmentDate.save($0, assignmentID: id, in: client)
            })
        }

        if let items = item.overrides {
            overrides = Set(items.map { AssignmentOverride.save($0, in: client) })
        }
    }

    public var canMakeSubmissions: Bool {
        if submissionTypes == [.wiki_page] { return false }
        return submissionTypes.count > 0 &&
            !submissionTypes.contains(.none) && !submissionTypes.contains(.on_paper)
    }

    public var isLTIAssignment: Bool {
        return submissionTypes.count == 1 &&
            (submissionTypes.contains(.basic_lti_launch) || submissionTypes.contains(.external_tool))
    }

    public var attemptPossible: Bool {
        return canMakeSubmissions && !isLTIAssignment
    }

    public var isDiscussion: Bool {
        return submissionTypes.count == 1 &&
            submissionTypes.contains(.discussion_topic)
    }

    public var isOnline: Bool {
        return submissionTypes.isOnline
    }

    public var usedAttempts: Int {
        return submission?.attempt ?? 0
    }

    public var hasAttemptsLeft: Bool {
        let latestAttempt = submission?.attempt ?? 0
        return (
            allowedAttempts <= 0 ||
            latestAttempt < allowedAttempts
        )
    }

    public func isOpenForSubmissions(referenceDate: Date = Clock.now) -> Bool {
        var open = !lockedForUser
        if let lockAt = lockAt {
            open = open && lockAt > referenceDate
        }
        if let unlockAt = unlockAt {
            open = open && referenceDate >= unlockAt
        }
        return open
    }

    public var lockStatus: LockStatus {
        if let unlockAt = unlockAt, Clock.now < unlockAt, lockedForUser {
            return .before
        } else if let lockAt = lockAt, Clock.now >= lockAt, lockedForUser {
            return .after
        } else {
            return .unlocked
        }
    }

    public var submissionStatus: SubmissionStatus {
        return submission?.status ?? .notSubmitted
    }

    public var icon: UIImage {
        if lockedForUser {
            .lockLine
        } else if quizID != nil || isQuizLTI {
            .quizLine
        } else if submissionTypes.contains(.discussion_topic) {
            .discussionLine
        } else if submissionTypes.contains(.external_tool) || submissionTypes.contains(.basic_lti_launch) {
            .ltiLine
        } else {
            .assignmentLine
        }
    }

    public func requiresLTILaunch(toViewSubmission submission: Submission) -> Bool {
        // If it's an online_upload with an attachment
        // we would rather show the attachment than launch the LTI (ex: Google Cloud Assignments)
        let onlineUploadWithAttachment = submission.type == .online_upload && submission.attachments?.isEmpty == false
        return submissionTypes.contains(.external_tool) && !onlineUploadWithAttachment
    }
}

extension Assignment: DueViewable, GradeViewable, SubmissionViewable {
    public var viewableScore: Double? {
        return submission?.score
    }
    public var viewableGrade: String? {
        return submission?.grade
    }
    public var viewableEnteredScore: Double? {
        return submission?.enteredScore
    }

    public var descriptionHTML: String {
        let fallback = "<i>\(String(localized: "No Content", bundle: .core))</i>"
        if isDiscussion {
            return discussionTopic.map { DiscussionHTML.string(for: $0) } ?? fallback
        }
        return details ?? fallback
    }
}

public enum LockStatus: String {
    case unlocked, before, after
}

public final class AssignmentDate: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var base: Bool
    @NSManaged public var title: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var unlockAt: Date?
    @NSManaged public var lockAt: Date?

    @discardableResult
    public static func save(_ item: APIAssignmentDate, assignmentID: String, in context: NSManagedObjectContext) -> AssignmentDate {
        let id = item.id?.value ?? "base-\(assignmentID)"
        let model: AssignmentDate = context.first(where: #keyPath(AssignmentDate.id), equals: id) ?? context.insert()
        model.id = id
        model.base = item.base == true
        model.title = item.title
        model.dueAt = item.due_at
        model.unlockAt = item.unlock_at
        model.lockAt = item.lock_at
        return model
    }

    @discardableResult
    public static func save(_ item: APIAssignmentDate, quizID: String, in context: NSManagedObjectContext) -> AssignmentDate {
        let id = item.id?.value ?? "base-quiz-\(quizID)"
        let model: AssignmentDate = context.first(where: #keyPath(AssignmentDate.id), equals: id) ?? context.insert()
        model.id = id
        model.base = item.base == true
        model.title = item.title
        model.dueAt = item.due_at
        model.unlockAt = item.unlock_at
        model.lockAt = item.lock_at
        return model
    }
}

public final class AssignmentOverride: NSManagedObject, WriteableModel {
    @NSManaged public var assignmentID: String
    @NSManaged public var courseSectionID: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var id: String
    @NSManaged public var groupID: String?
    @NSManaged public var lockAt: Date?
    @NSManaged var studentIDsRaw: String?
    @NSManaged public var title: String
    @NSManaged public var unlockAt: Date?

    public var studentIDs: [String]? {
        get { studentIDsRaw?.components(separatedBy: ",") }
        set { studentIDsRaw = newValue?.joined(separator: ",") }
    }

    @discardableResult
    public static func save(_ item: APIAssignmentOverride, in context: NSManagedObjectContext) -> AssignmentOverride {
        let model: AssignmentOverride = context.first(where: #keyPath(AssignmentOverride.id), equals: item.id.value) ?? context.insert()
        model.assignmentID = item.assignment_id.value
        model.courseSectionID = item.course_section_id?.value
        model.dueAt = item.due_at
        model.groupID = item.group_id?.value
        model.id = item.id.value
        model.lockAt = item.lock_at
        model.studentIDs = item.student_ids?.map { $0.value }
        model.title = item.title
        model.unlockAt = item.unlock_at
        return model
    }
}

public final class ScoreStatistics: NSManagedObject {
    @NSManaged internal(set) public var mean: Double
    @NSManaged internal(set) public var min: Double
    @NSManaged internal(set) public var max: Double
    @NSManaged internal(set) public var assignment: Assignment

    public func update(fromApiModel item: APIAssignmentScoreStatistics, in client: NSManagedObjectContext) {
        mean = item.mean
        min = item.min
        max = item.max
    }
}

public enum GradingType: String, Codable, CaseIterable {
    case percent, pass_fail, points, letter_grade, gpa_scale, not_graded

    var string: String {
        switch self {
        case .percent:
            return String(localized: "Percentage", bundle: .core)
        case .pass_fail:
            return String(localized: "Complete/Incomplete", bundle: .core)
        case .points:
            return String(localized: "Points", bundle: .core)
        case .letter_grade:
            return String(localized: "Letter Grade", bundle: .core)
        case .gpa_scale:
            return String(localized: "GPA Scale", bundle: .core)
        case .not_graded:
            return String(localized: "Not Graded", bundle: .core)
        }
    }
}
