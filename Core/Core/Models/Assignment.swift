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
import MobileCoreServices

public class Assignment: NSManagedObject {
    @NSManaged public var allowedExtensions: [String]
    @NSManaged public var courseID: String
    @NSManaged public var quizID: String?
    @NSManaged public var details: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var dueAtSortNilsAtBottom: Date
    @NSManaged public var gradedIndividually: Bool
    @NSManaged var gradingTypeRaw: String
    @NSManaged public var htmlURL: URL
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged var pointsPossibleRaw: NSNumber?
    @NSManaged var submissionTypesRaw: [String]
    @NSManaged public var position: Int
    @NSManaged public var lockAt: Date?
    @NSManaged public var unlockAt: Date?
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?
    @NSManaged public var url: URL?
    @NSManaged public var discussionTopic: DiscussionTopic?
    @NSManaged public var rubric: Set<Rubric>?
    @NSManaged public var useRubricForGrading: Bool
    @NSManaged public var lastUpdatedAt: Date?
    @NSManaged public var hideRubricPoints: Bool
    @NSManaged public var assignmentGroupID: String?
    @NSManaged public var assignmentGroupPosition: Int
    @NSManaged public var gradingPeriodID: String?

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

    public var gradingType: GradingType {
        get { return GradingType(rawValue: gradingTypeRaw) ?? .points }
        set { gradingTypeRaw = newValue.rawValue }
    }

    public var pointsPossible: Double? {
        get { return pointsPossibleRaw?.doubleValue }
        set { pointsPossibleRaw = NSNumber(value: newValue) }
    }

    public var submissionTypes: [SubmissionType] {
        get { return submissionTypesRaw.compactMap { SubmissionType(rawValue: $0) } }
        set { submissionTypesRaw = newValue.map { $0.rawValue } }
    }
}

extension Assignment {
    func update(fromApiModel item: APIAssignment, in client: NSManagedObjectContext, updateSubmission: Bool) {
        id = item.id.value
        name = item.name
        courseID = item.course_id.value
        quizID = item.quiz_id?.value
        details = item.description
        pointsPossible = item.points_possible
        dueAt = item.due_at
        dueAtSortNilsAtBottom = item.due_at ?? Date.distantFuture
        htmlURL = item.html_url
        gradingType = item.grading_type
        gradedIndividually = item.grade_group_students_individually ?? true
        submissionTypes = item.submission_types
        allowedExtensions = item.allowed_extensions ?? []
        position = item.position
        unlockAt = item.unlock_at
        lockAt = item.lock_at
        lockedForUser = item.locked_for_user ?? false
        lockExplanation = item.lock_explanation
        url = item.url
        useRubricForGrading = item.use_rubric_for_grading ?? false
        lastUpdatedAt = Date()
        assignmentGroupID = item.assignment_group_id?.value

        if let topic = item.discussion_topic {
            discussionTopic = DiscussionTopic.save(topic, in: client)
        } else if let topic = discussionTopic {
            client.delete(topic)
            self.discussionTopic = nil
        }

        if let exitstingRubrics = rubric {
            client.delete(Array(exitstingRubrics))
            self.rubric = nil
        }

        if let apiRubrics = item.rubric, apiRubrics.count > 0 {
            self.rubric = Set<Rubric>()
            for (index, var r) in apiRubrics.enumerated() {
                r.assignmentID = item.id.value
                r.position = index
                let rubricModel = Rubric.save(r, in: client)
                self.rubric?.insert(rubricModel)
            }
        }

        hideRubricPoints = item.rubric_settings?.hide_points == true

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
    }

    public var canMakeSubmissions: Bool {
        return submissionTypes.count > 0 &&
            !submissionTypes.contains(.none) && !submissionTypes.contains(.on_paper)
    }

    public var isLTIAssignment: Bool {
        return submissionTypes.count == 1 &&
            (submissionTypes.contains(.basic_lti_launch) || submissionTypes.contains(.external_tool))
    }

    public var isDiscussion: Bool {
        return submissionTypes.count == 1 &&
            submissionTypes.contains(.discussion_topic)
    }

    public var allowedUTIs: [UTI] {
        var utis: [UTI] = []

        if submissionTypes.contains(.online_upload) {
            if allowedExtensions.isEmpty {
                utis += [.any]
            } else {
                utis += allowedExtensions.compactMap(UTI.init)
            }
        }

        if submissionTypes.contains(.media_recording) {
            utis += [.video, .audio]
        }

        if submissionTypes.contains(.online_text_entry) {
            utis += [.text]
        }

        if submissionTypes.contains(.online_url) {
            utis += [.url]
        }

        return utis
    }

    public var allowedMediaTypes: [String] {
        var types  = [kUTTypeMovie as String]

        if submissionTypes.contains(.media_recording) {
            types.append(kUTTypeAudio as String)
        } else {
            types.append(kUTTypeImage as String)
        }
        return types
    }

    public var gradeText: String? {
        guard let submission = submission else {
            return nil
        }
        switch gradingType {
        case .gpa_scale:
            guard let grade = submission.grade else { return nil }
            let format = NSLocalizedString("%@ GPA", bundle: .core, comment: "")
            return String.localizedStringWithFormat(format, grade)

        case .pass_fail:
            guard let grade = submission.grade else { return nil }
            return grade == "incomplete"
                ? NSLocalizedString("Incomplete", bundle: .core, comment: "")
                : NSLocalizedString("Complete", bundle: .core, comment: "")

        case .points:
            guard let score = submission.score, let pointsPossible = pointsPossible else { return nil }
            return NumberFormatter.localizedString(from: NSNumber(value: score / pointsPossible * 100), number: .decimal)

        case .letter_grade, .percent, .not_graded:
            return submission.grade
        }
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

    public var submissionStatus: String {
        guard let s = submission else { return NSLocalizedString("Not Submitted", comment: "") }

        if !submissionTypes.isOnline { return "" }
        if s.excused ?? false { return "" }
        if s.late { return NSLocalizedString("Late", comment: "") }
        if s.missing { return NSLocalizedString("Missing", comment: "") }
        if s.submittedAt != nil { return NSLocalizedString("Submitted", comment: "") }

        return ""
    }

    public var icon: UIImage? {
        var image: UIImage? = .icon(.assignment, .line)
        if quizID != nil {
            image = .icon(.quiz, .line)
        } else if submissionTypes.contains(.discussion_topic) {
            image = .icon(.discussion, .line)
        } else if submissionTypes.contains(.external_tool) || submissionTypes.contains(.basic_lti_launch) {
            image = .icon(.lti, .line)
        }

        if lockedForUser {
            image = .icon(.lock, .line)
        }

        return image
    }

    public func multiUserSubmissionGradeText(studentID: String) -> String? {
        guard let submission = submissions?.filter({ $0.userID == studentID }).first else { return nil }

        if submission.excused ?? false {
            return NSLocalizedString("Excused", comment: "")
        }

        if submission.score == nil {
            return nil
        }

        let score = formattedGradeNumber(submission.score)
        let totalPointsPossible: String = formattedGradeNumber(pointsPossible) ?? ""

        switch gradingType {
        case .pass_fail:
            let status = submission.grade == "incomplete"
                ? NSLocalizedString("Incomplete", bundle: .core, comment: "")
                : NSLocalizedString("Complete", bundle: .core, comment: "")
            return status
        case .points:
            if let score = score {
                let format = NSLocalizedString("%@ out of %@", comment: "")
                return String.localizedStringWithFormat(format, score, totalPointsPossible)
            }
        case .letter_grade, .percent, .gpa_scale:
            if let score = score {
                let format = NSLocalizedString("%@ out of %@ (%@)", comment: "")
                return String.localizedStringWithFormat(format, score, totalPointsPossible, submission.grade ?? "")
            }
        case .not_graded: break
        }
        return nil
    }

    func formattedGradeNumber(_ number: Double?) -> String? {
        guard let number = number else { return nil }
        return NumberFormatter.localizedString(from: NSNumber(value: (number * 100) / 100), number: .decimal)
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

    public var descriptionHTML: String {
        let fallback = "<i>\(NSLocalizedString("No Content", bundle: .core, comment: ""))</i>"
        if isDiscussion {
            return discussionTopic?.html ?? fallback
        }
        return details ?? fallback
    }
}

public enum LockStatus: String {
    case unlocked, before, after
}
