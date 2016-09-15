//
//  Assignment+Factory.swift
//  Assignments
//
//  Created by Nathan Armstrong on 5/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import AssignmentKit
import CoreData

extension Assignment {
    static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      courseID: String = "1",
                      name: String = "Simple Assignment",
                      due: NSDate? = nil,
                      details: String = "",
                      url: NSURL = NSURL(string: "")!,
                      htmlURL: NSURL = NSURL(string: "")!,
                      submissionTypes: SubmissionTypes = [],
                      rawDueStatus: String = DueStatus.Undated.rawValue,
                      hasSubmitted: Bool = false,
                      allowedExtensions: [String]? = nil,
                      pointsPossible: Double = 10,
                      gradingType: GradingType = .PassFail,
                      useRubricForGrading: Bool = true,
                      assignmentGroupID: String = "1",
                      gradingPeriodID: String? = nil,
                      currentGrade: String = "A",
                      currentScore: NSNumber? = nil,
                      submissionLate: Bool = false,
                      submittedAt: NSDate? = nil,
                      submissionExcused: Bool = false,
                      gradedAt: NSDate? = nil,
                      status: SubmissionStatus = .Unsubmitted,
                      needsGradingCount: Int32 = 0,
                      published: Bool = true,
                      dueDateOverrides: Set<DueDateOverride>? = nil,
                      lockedForUser: Bool = false,
                      lockExplanation: String? = nil,
                      unlockAt: NSDate? = nil,
                      discussionTopicID: String? = nil,
                      quizID: String? = nil,
                      rubric: Rubric? = nil,
                      submissionUploads: Set<SubmissionUpload> = [],
                      assignmentGroup: AssignmentGroup? = nil
    ) -> Assignment {
        let assignment = Assignment.create(inContext: context)
        assignment.id = id
        assignment.courseID = courseID
        assignment.name = name
        assignment.due = due
        assignment.details = details
        assignment.url = url
        assignment.htmlURL = htmlURL
        assignment.submissionTypes = submissionTypes
        assignment.rawDueStatus = rawDueStatus
        assignment.hasSubmitted = hasSubmitted
        assignment.allowedExtensions = allowedExtensions
        assignment.pointsPossible = pointsPossible
        assignment.gradingType = gradingType
        assignment.useRubricForGrading = useRubricForGrading
        assignment.assignmentGroupID = assignmentGroupID
        assignment.gradingPeriodID = gradingPeriodID
        assignment.currentGrade = currentGrade
        assignment.currentScore = currentScore
        assignment.submissionLate = submissionLate
        assignment.submittedAt = submittedAt
        assignment.submissionExcused = submissionExcused
        assignment.gradedAt = gradedAt
        assignment.status = status
        assignment.needsGradingCount = needsGradingCount
        assignment.published = published
        assignment.dueDateOverrides = dueDateOverrides
        assignment.lockedForUser = lockedForUser
        assignment.unlockAt = unlockAt
        assignment.discussionTopicID = discussionTopicID
        assignment.quizID = quizID
        assignment.rubric = rubric
        assignment.submissionUploads = submissionUploads
        assignment.assignmentGroup = assignmentGroup
        return assignment
    }
}
