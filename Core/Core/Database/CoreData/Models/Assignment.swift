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

public class Assignment: NSManagedObject {
    @NSManaged public var allowedExtensions: [String]
    @NSManaged public var courseID: String
    @NSManaged public var quizID: String?
    @NSManaged public var details: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var gradedIndividually: Bool
    @NSManaged var gradingTypeRaw: String
    @NSManaged public var htmlURL: URL
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged var pointsPossibleRaw: NSNumber?
    @NSManaged public var submission: Submission?
    @NSManaged var submissionTypesRaw: [String]
    @NSManaged public var position: Int
    @NSManaged public var lockAt: Date?
    @NSManaged public var unlockAt: Date?
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var url: URL?
    @NSManaged public var dueAtOrder: String
    @NSManaged public var discussionTopic: DiscussionTopic?
    @NSManaged public var rubric: Set<Rubric>?
    @NSManaged public var useRubricForGrading: Bool

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
    func update(fromApiModel item: APIAssignment, in client: PersistenceClient, updateSubmission: Bool) throws {
        id = item.id.value
        name = item.name
        courseID = item.course_id.value
        quizID = item.quiz_id?.value
        details = item.description
        pointsPossible = item.points_possible
        dueAt = item.due_at
        dueAtOrder = item.due_at == nil ? "z" : "a"
        htmlURL = item.html_url
        gradingType = item.grading_type
        gradedIndividually = item.grade_group_students_individually ?? true
        submissionTypes = item.submission_types
        allowedExtensions = item.allowed_extensions ?? []
        position = item.position
        unlockAt = item.unlock_at
        lockAt = item.lock_at
        lockedForUser = item.locked_for_user ?? false
        url = item.url
        useRubricForGrading = item.use_rubric_for_grading ?? false

        if let topic = item.discussion_topic {
            discussionTopic = try DiscussionTopic.save(topic, in: client)
        } else if let topic = discussionTopic {
            try client.delete(topic)
            self.discussionTopic = nil
        }

        if let exitstingRubrics = rubric {
            try client.delete(Array(exitstingRubrics))
            self.rubric = nil
        }

        if let apiRubrics = item.rubric, apiRubrics.count > 0 {
            self.rubric = Set<Rubric>()
            for (index, var r) in apiRubrics.enumerated() {
                r.assignmentID = item.id.value
                r.position = index
                let rubricModel = try Rubric.save(r, in: client)
                self.rubric?.insert(rubricModel)
            }
        }

        if updateSubmission {
            if let submissionItem = item.submission {
                let sub = try Submission.save(submissionItem, in: client)
                submission = sub
            } else if let submission = submission {
                try client.delete(submission)
                self.submission = nil
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
            guard let score = submission.score else { return nil }
            return score == 0
                ? NSLocalizedString("Incomplete", bundle: .core, comment: "")
                : NSLocalizedString("Complete", bundle: .core, comment: "")

        case .points:
            guard let score = submission.score, let pointsPossible = pointsPossible else { return nil }
            return NumberFormatter.localizedString(from: NSNumber(value: score / pointsPossible * 100), number: .decimal)

        case .letter_grade, .percent, .not_graded:
            return submission.grade
        }
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
