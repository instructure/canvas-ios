//
//  AssignmentTests.swift
//  Assignments
//
//  Created by Nathan Lambson on 6/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
import TooLegit
import Marshal
import DoNotShipThis
import MobileCoreServices
@testable import AssignmentKit


class AssignmentTests: UnitTestCase {
    
    func testUpdateAssignmentWithJSON() {
        attempt{
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment(inContext: context)
            
            try assignment.updateValues(validJSON, inContext:context)
            let dueStatus: DueStatus = DueStatus(assignment: assignment)
            
            XCTAssertNotNil(assignment)
            XCTAssertEqual("9091235", assignment.id)
            XCTAssertEqual("1140383", assignment.courseID)
            XCTAssertEqual("LOOOOOONG Everything", assignment.name)
            XCTAssertEqual("<p>Far far away</p>", assignment.details)
            XCTAssertEqual(987654321987654000000000000000000000, assignment.pointsPossible)
            XCTAssertEqual("points", assignment.rawGradingType)
            XCTAssertEqual(false, assignment.useRubricForGrading)
            XCTAssertNotNil(assignment.submissionTypes)
            XCTAssertEqual("https://mobiledev.instructure.com/courses/1140383/assignments/9091235", assignment.htmlURL.absoluteString)
            XCTAssertEqual("1273086", assignment.assignmentGroupID)
            XCTAssertNil(assignment.assignmentGroup)
            XCTAssertEqual("None",assignment.assignmentGroupName)
            XCTAssertEqual(true, assignment.hasSubmitted)
            XCTAssertEqual("87654321987653900000000000000000000/987654321987654000000000000000000000", assignment.grade)
            XCTAssertEqual(false, assignment.submissionLate)
            XCTAssertEqual(false, assignment.submissionExcused)
            XCTAssertNotNil(assignment.submittedAt)
            XCTAssertNotNil(assignment.gradedAt)
            XCTAssertEqual(SubmissionStatus.Submitted, assignment.status)
            XCTAssert(assignment.submissionTypes.contains(SubmissionTypes.Quiz))
            XCTAssert(assignment.submissionTypes.contains(SubmissionTypes.DiscussionTopic) == false)
            XCTAssertNotNil(assignment.icon)
            XCTAssert(assignment.allowsSubmissions)
            XCTAssertEqual(DueStatus.Undated.rawValue, assignment.rawDueStatus)
            XCTAssertNotNil(dueStatus)
            XCTAssertEqual(DueStatus.Undated.description, dueStatus.description)
        }
    }
    
    func testUpdateOverdueAssignmentWithJSON() {
        attempt{
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment(inContext: context)
            
            var json = validJSON
            
            json["submission_types"] = ["external_tool"]
            json["has_submitted_submissions"] = false
            json["submission"] = submissionWithNoAttemptsJSON
            json["locked_for_user"] = false
            json["due_at"] = "2015-10-27T05:59:00Z"
            
            try assignment.updateValues(json, inContext:context)
            let dueStatus: DueStatus = DueStatus(assignment: assignment)
            
            XCTAssertEqual(DueStatus.Overdue.rawValue, assignment.rawDueStatus)
            XCTAssertNotNil(dueStatus)
            XCTAssertEqual(DueStatus.Overdue.description, dueStatus.description)
        }
    }
    
    func testUpdatePastAssignmentWithJSON() {
        attempt{
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment(inContext: context)
            
            var json = validJSON
            
            json["due_at"] = "2015-10-27T05:59:00Z"
            
            try assignment.updateValues(json, inContext:context)
            let dueStatus: DueStatus = DueStatus(assignment: assignment)
            
            XCTAssertEqual(DueStatus.Past.rawValue, assignment.rawDueStatus)
            XCTAssertNotNil(dueStatus)
            XCTAssertEqual(DueStatus.Past.description, dueStatus.description)
        }
    }
    
    func testUpdateUpcomingAssignmentWithJSON() {
        attempt{
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment(inContext: context)
            
            var json = validJSON
            
            json["due_at"] = "2099-10-27T05:59:00Z"
            
            try assignment.updateValues(json, inContext:context)
            let dueStatus: DueStatus = DueStatus(assignment: assignment)
            
            XCTAssertEqual(DueStatus.Upcoming.rawValue, assignment.rawDueStatus)
            XCTAssertNotNil(dueStatus)
            XCTAssertEqual(DueStatus.Upcoming.description, dueStatus.description)
        }
    }
    
    func testUpdateAssignmentWithURLSubmissionJSON() {
        attempt{
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment(inContext: context)
            
            var json = validJSON
            
            json["submission_types"] = ["external_tool"]
            
            try assignment.updateValues(json, inContext:context)
            
            XCTAssert(assignment.submissionTypes.contains(SubmissionTypes.ExternalTool))
            XCTAssertNotNil(assignment.icon)
        }
    }
    
    func testUpdateAssignmentWithDiscussionTopicSubmissionJSON() {
        attempt{
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment(inContext: context)
            
            var json = validJSON
            
            json["submission_types"] = ["discussion_topic"]
            
            try assignment.updateValues(json, inContext:context)
            
            XCTAssert(assignment.submissionTypes.contains(SubmissionTypes.DiscussionTopic))
            XCTAssertNotNil(assignment.icon)
        }
    }
    
    func testUpdateAssignmentWithQuizSubmissionJSON() {
        attempt{
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment(inContext: context)
            
            var json = validJSON
            
            json["submission_types"] = ["online_quiz"]
            
            try assignment.updateValues(json, inContext:context)
            
            XCTAssert(assignment.submissionTypes.contains(SubmissionTypes.Quiz))
            XCTAssertNotNil(assignment.icon)
        }
    }
    
    func testUpdateAssignmentWithQuizNoURLSubmissionJSON() {
        attempt{
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment(inContext: context)
            
            var json = validJSON
            
            json["submission_types"] = ["online_quiz"]
            json["html_url"] = ""
            
            try assignment.updateValues(json, inContext:context)
            
            XCTAssert(assignment.submissionTypes.contains(SubmissionTypes.Quiz))
        }
    }
    
    func testUpdateOverridesWithAssignmentJSON() {
        attempt{
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment(inContext: context)
            
            var json = validJSON
            
            json["only_visible_to_overrides"] = true
            json["overrides"] = [overridesJSON]

            
            try assignment.updateValues(json, inContext:context)
            
            XCTAssert(assignment.submissionTypes.contains(SubmissionTypes.Quiz))
        }
    }

    func testUpdateDueDateOverrideWithJSON() {
        attempt {
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let dueDateOverride = DueDateOverride(inContext: context)

            try dueDateOverride.updateValues(overridesJSON, inContext: context)

            XCTAssertEqual(dueDateOverride.id, "618319")
        }
    }

    func testAllowsAllFiles() {
        attempt {
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment.build(context, submissionTypes: [SubmissionTypes.Upload])
            XCTAssert(assignment.allowsAllFiles)

            let pdfOnlyAssignment = Assignment.build(context, submissionTypes: [SubmissionTypes.Upload], allowedExtensions: ["pdf"])
            XCTAssert(!(pdfOnlyAssignment.allowsAllFiles))
        }
    }

    func testAllowsPhotos() {
        attempt {
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment.build(context, submissionTypes: [SubmissionTypes.Upload], allowedExtensions: ["jpg"])
            XCTAssert(assignment.allowsPhotos)
        }
    }

    func testAllowsVideo() {
        attempt {
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment.build(context, submissionTypes: [SubmissionTypes.Upload], allowedExtensions: ["mp4"])
            XCTAssert(assignment.allowsVideo)
        }
    }

    func testAllowsAudio() {
        attempt {
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment.build(context, submissionTypes: [SubmissionTypes.Upload], allowedExtensions: ["mp3"])
            XCTAssert(assignment.allowsAudio)
        }
    }

    func testAllowedImagePickerMediaTypes() {
        attempt {
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let imageOnlyAssignment = Assignment.build(context, submissionTypes: [SubmissionTypes.Upload], allowedExtensions: ["jpg"])
            XCTAssert(imageOnlyAssignment.allowedImagePickerControllerMediaTypes == [kUTTypeImage])

            let videoOnlyAssignment = Assignment.build(context, submissionTypes: [SubmissionTypes.Upload], allowedExtensions: ["mp4"])
            XCTAssert(videoOnlyAssignment.allowedImagePickerControllerMediaTypes == [kUTTypeMovie])

            let imageAndVideoAssignment = Assignment.build(context, submissionTypes: [SubmissionTypes.Upload], allowedExtensions: ["mp4", "jpg"])
            XCTAssert(imageAndVideoAssignment.allowedImagePickerControllerMediaTypes.count == 2)
            XCTAssert(imageAndVideoAssignment.allowedImagePickerControllerMediaTypes.contains(kUTTypeMovie as String))
            XCTAssert(imageAndVideoAssignment.allowedImagePickerControllerMediaTypes.contains(kUTTypeImage as String))
        }
    }

    private var overridesJSON: JSONObject {
        return [
            "id": 618319,
            "assignment_id": 9091235,
            "title": "trigger overrides section",
            "due_at": "2017-10-27T05:59:59Z",
            "all_day": true,
            "all_day_date": "2017-10-26",
            "unlock_at": "2016-06-13T06:00:00Z",
            "lock_at": "2019-01-20T06:59:00Z",
            "course_section_id": 2128655
        ]
    }
    
    private var submissionWithNoAttemptsJSON: JSONObject {
        return [
            "id": 84738044,
            "body": "<div></div>Another ",
            "grade": "87654321987653939153957947499872256",
            "score": 8.76543219876539e+34,
            "submitted_at": "2016-06-01T16:39:04Z",
            "assignment_id": 9091235,
            "user_id": 4301217,
            "submission_type": "online_text_entry",
            "workflow_state": "submitted",
            "grade_matches_current_submission": false,
            "graded_at": "2016-05-26T21:01:18Z",
            "grader_id": 4301214,
            "attempt": 0,
            "excused": false,
            "late": true,
            "preview_url": "https://mobiledev.instructure.com/courses/1140383/assignments/9091235/submissions/4301217?preview=1&version=5"
        ]
    }
    
    var validJSON: JSONObject {
        let bundle = NSBundle(forClass: AssignmentTests.self)
        let path = bundle.pathForResource("valid_assignment", ofType: "json")!
        return try! JSONParser.JSONObjectWithData(NSData(contentsOfFile: path)!)
    }
    
    
}