
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
@testable import CalendarKit
import SoAutomated
import CoreData
import Marshal
import SoPersistent
import TooLegit

class CalendarEventTests: CalendarKitTests {

    func testIsValid() {
        let event = CalendarEvent.build(managedObjectContext)
        XCTAssert(event.isValid)
    }

    func test_itCanBeUpdatedFromJSON() {
        let json = CalendarEvent.validJSON
        let event = CalendarEvent(inContext: managedObjectContext)
        try! event.updateValues(json, inContext: managedObjectContext)
        XCTAssert(event.isValid)
        XCTAssertEqual("New Event", event.title)
        XCTAssertEqual("", event.locationName)
        XCTAssertEqual("user_6782429", event.contextCode)
        XCTAssertFalse(event.hidden)
        XCTAssertNotNil(event.endAt)

        // ... and so on
    }

    func test_itCanBeUpdatedFromAssignmentJSON() {
        let json = CalendarEvent.validAssignmentJSON
        let event = CalendarEvent(inContext: managedObjectContext)
        try! event.updateValues(json, inContext: managedObjectContext)
        XCTAssert(event.isValid)
        XCTAssertEqual("Upcoming Assignment", event.title)
        XCTAssertEqual("7391844", event.assignmentID)
    }

    func test_itConvertsRawTypeToType() {
        let types: [EventType] = [.Quiz, .Assignment, .Discussion, .CalendarEvent, .Error]
        for type in types {
            let event = CalendarEvent.build(self.managedObjectContext, rawType: type.rawValue)

            // switch for brevity
            switch type {
            case .Quiz: XCTAssert(eventTypesAreEqual(type, event.type))
            case .Assignment: XCTAssert(eventTypesAreEqual(type, event.type))
            case .Discussion: XCTAssert(eventTypesAreEqual(type, event.type))
            case .CalendarEvent: XCTAssert(eventTypesAreEqual(type, event.type))
            case .Error: XCTAssert(eventTypesAreEqual(type, event.type))
            }
        }
    }

    func test_itConvertsAssignmentTypeToQuizWhenQuizIDIsPresent() {
        let type = EventType.Assignment
        let event = CalendarEvent.build(self.managedObjectContext, rawType: type.rawValue, quizID: "notnil")

        XCTAssert(eventTypesAreEqual(EventType.Quiz, event.type))
    }

    func test_itConvertsStatusProperly() {
        let event = CalendarEvent.build(self.managedObjectContext, rawStatus: SubmissionStatus.Excused.rawValue)
        XCTAssertEqual(event.status, SubmissionStatus.Excused)
    }

    func test_whenRawTypeIsInvalid_itConvertsItToAnErrorType() {
        let event = CalendarEvent.build(self.managedObjectContext, rawType: "foo")
        XCTAssert(eventTypesAreEqual(.Error, event.type))
    }

    func test_itConvertsRawWorkflowStateToWorkflowState() {
        let states: [EventWorkflowState] = [.Active, .Locked, .Deleted]
        for state in states {
            let event = CalendarEvent.build(self.managedObjectContext, rawWorkflowState: state.rawValue)

            // switch for brevity
            switch state {
            case .Active: XCTAssert(workflowStatesAreEqual(state, event.workflowState))
            case .Locked: XCTAssert(workflowStatesAreEqual(state, event.workflowState))
            case .Deleted: XCTAssert(workflowStatesAreEqual(state, event.workflowState))
            }
        }
    }

    func test_submissionTypeForString() {
        let typeStringValues = [
            "discussion_topic",
            "online_quiz",
            "on_paper",
            "external_tool",
            "online_text_entry",
            "online_url",
            "online_upload",
            "media_recording",
            "none"
        ]

        let typeValues : SubmissionTypes = [
            .DiscussionTopic,
            .Quiz,
            .OnPaper,
            .ExternalTool,
            .Text,
            .URL,
            .Upload,
            .MediaRecording,
            .None
        ]

        XCTAssertEqual(SubmissionTypes.fromStrings(typeStringValues), typeValues)
    }

    func test_submissionTypeForIncorrectString() {
        XCTAssertEqual(SubmissionTypes.fromStrings(["should_be_empty"]), [])
    }

    func test_pastStartDateCalculatedCorrectly() {
        let event = CalendarEvent.build(self.managedObjectContext, startAt: NSDate(timeIntervalSinceNow: -1))
        XCTAssertEqual(event.pastStartDate, true)
    }

    func test_pastEndDateCalculatedCorrectly() {
        let event = CalendarEvent.build(self.managedObjectContext, endAt: NSDate(timeIntervalSinceNow: -1))
        XCTAssertEqual(event.pastEndDate, true)
    }

    func test_pastStartDateCalculatedCorrectlyNil() {
        let event = CalendarEvent.build(self.managedObjectContext)
        XCTAssertEqual(event.pastStartDate, false)
    }

    func test_pastEndDateCalculatedCorrectlyNil() {
        let event = CalendarEvent.build(self.managedObjectContext)
        XCTAssertEqual(event.pastEndDate, false)
    }

    func test_routingURLCorrectForCalendarEvent() {
        let event = CalendarEvent.build(self.managedObjectContext, id: "1234567890", rawType: EventType.CalendarEvent.rawValue)
        XCTAssertEqual(event.routingURL, NSURL(string: "/calendar_events/1234567890"))
    }

    func test_routingURLCorrectForQuiz() {
        let event = CalendarEvent.build(self.managedObjectContext, quizID: "1234567890", courseID: "1234", rawType: EventType.Quiz.rawValue)
        XCTAssertEqual(event.routingURL, NSURL(string: "/courses/1234/quizzes/1234567890"))
    }

    func test_routingURLCorrectForDiscussionTopic() {
        let event = CalendarEvent.build(self.managedObjectContext, courseID: "1234", discussionTopicID: "12345", rawType: EventType.Assignment.rawValue, rawSubmissionTypes: Int32(SubmissionTypes.DiscussionTopic.rawValue))
        XCTAssertEqual(event.routingURL, NSURL(string: "/courses/1234/discussion_topics/12345"))
    }

    func test_routingURLCorrectForAssignmentQuiz() {
        let event = CalendarEvent.build(self.managedObjectContext, courseID: "1234", quizID: "12345", rawType: EventType.Assignment.rawValue, rawSubmissionTypes: Int32(SubmissionTypes.Quiz.rawValue))
        XCTAssertEqual(event.routingURL, NSURL(string: "/courses/1234/quizzes/12345"))
    }

    func test_routingURLCorrectForAssignment() {
        let event = CalendarEvent.build(self.managedObjectContext, courseID: "1234", assignmentID: "12345", rawType: EventType.Assignment.rawValue)
        XCTAssertEqual(event.routingURL, NSURL(string: "/courses/1234/assignments/12345"))
    }

    func test_routingURLCorrectForErrorType() {
        let event = CalendarEvent.build(self.managedObjectContext, rawType: EventType.Error.rawValue)
        XCTAssertEqual(event.routingURL, nil)
    }

    func test_itCorrectlyCalculatesOnlineSubmission() {
        var type = SubmissionTypes.DiscussionTopic
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.Quiz
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.Text
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.Quiz
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.URL
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.Upload
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.MediaRecording
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.ExternalTool
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.None
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.OnPaper
        XCTAssertEqual(type.onlineSubmission, false)
    }

    func test_itCorrectlyCalculatesCanSubmit() {
        var type = SubmissionTypes.DiscussionTopic
        XCTAssertEqual(type.canSubmit, true)

        type = []
        XCTAssertEqual(type.canSubmit, false)
    }

    // MARK: Helpers
    // TODO: Move this to EventType and EventWorkflowState

    func eventTypesAreEqual(left: EventType, _ right: EventType) -> Bool {
        if case left = right {
            return true
        } else {
            return false
        }
    }

    func workflowStatesAreEqual(left: EventWorkflowState, _ right: EventWorkflowState) -> Bool {
        if case left = right {
            return true
        } else {
            return false
        }
    }

}

class DescribeUniquePredicate: CalendarKitTests {
    func test_itMatchesOnTheID() {
        let predicate = try! CalendarEvent.uniquePredicateForObject(["id": "123"])
        XCTAssertEqual("id == \"123\"", predicate.predicateFormat)
    }

    func test_whenTheIDIsNotANumber_itConvertsItToAString() {
        let expectedPredicate = NSPredicate(format: "%K == %@", "id", "not a number")
        let result = try! CalendarEvent.uniquePredicateForObject(["id": "not a number"])
        XCTAssertEqual(expectedPredicate, result)
    }
}
