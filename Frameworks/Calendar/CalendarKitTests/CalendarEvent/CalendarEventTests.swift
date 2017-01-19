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
        let types: [EventType] = [.quiz, .assignment, .discussion, .calendarEvent, .error]
        for type in types {
            let event = CalendarEvent.build(self.managedObjectContext, rawType: type.rawValue)

            // switch for brevity
            switch type {
            case .quiz: XCTAssert(eventTypesAreEqual(type, event.type))
            case .assignment: XCTAssert(eventTypesAreEqual(type, event.type))
            case .discussion: XCTAssert(eventTypesAreEqual(type, event.type))
            case .calendarEvent: XCTAssert(eventTypesAreEqual(type, event.type))
            case .error: XCTAssert(eventTypesAreEqual(type, event.type))
            }
        }
    }

    func test_itConvertsAssignmentTypeToQuizWhenQuizIDIsPresent() {
        let type = EventType.assignment
        let event = CalendarEvent.build(self.managedObjectContext, rawType: type.rawValue, quizID: "notnil")

        XCTAssert(eventTypesAreEqual(EventType.quiz, event.type))
    }

    func test_itConvertsStatusProperly() {
        let event = CalendarEvent.build(self.managedObjectContext, rawStatus: SubmissionStatus.excused.rawValue)
        XCTAssertEqual(event.status, SubmissionStatus.excused)
    }

    func test_whenRawTypeIsInvalid_itConvertsItToAnErrorType() {
        let event = CalendarEvent.build(self.managedObjectContext, rawType: "foo")
        XCTAssert(eventTypesAreEqual(.error, event.type))
    }

    func test_itConvertsRawWorkflowStateToWorkflowState() {
        let states: [EventWorkflowState] = [.active, .locked, .deleted]
        for state in states {
            let event = CalendarEvent.build(self.managedObjectContext, rawWorkflowState: state.rawValue)

            // switch for brevity
            switch state {
            case .active: XCTAssert(workflowStatesAreEqual(state, event.workflowState))
            case .locked: XCTAssert(workflowStatesAreEqual(state, event.workflowState))
            case .deleted: XCTAssert(workflowStatesAreEqual(state, event.workflowState))
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
            .discussionTopic,
            .quiz,
            .onPaper,
            .externalTool,
            .text,
            .url,
            .upload,
            .mediaRecording,
            .none
        ]

        XCTAssertEqual(SubmissionTypes.fromStrings(typeStringValues), typeValues)
    }

    func test_submissionTypeForIncorrectString() {
        XCTAssertEqual(SubmissionTypes.fromStrings(["should_be_empty"]), [])
    }

    func test_pastStartDateCalculatedCorrectly() {
        let event = CalendarEvent.build(self.managedObjectContext, startAt: Date(timeIntervalSinceNow: -1))
        XCTAssertEqual(event.pastStartDate, true)
    }

    func test_pastEndDateCalculatedCorrectly() {
        let event = CalendarEvent.build(self.managedObjectContext, endAt: Date(timeIntervalSinceNow: -1))
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
        let event = CalendarEvent.build(self.managedObjectContext, id: "1234567890", rawType: EventType.calendarEvent.rawValue)
        XCTAssertEqual(event.routingURL, URL(string: "/calendar_events/1234567890"))
    }

    func test_routingURLCorrectForQuiz() {
        let event = CalendarEvent.build(self.managedObjectContext, rawType: EventType.quiz.rawValue, quizID: "1234567890", courseID: "1234")
        XCTAssertEqual(event.routingURL, URL(string: "/courses/1234/quizzes/1234567890"))
    }

    func test_routingURLCorrectForDiscussionTopic() {
        let event = CalendarEvent.build(self.managedObjectContext, rawType: EventType.assignment.rawValue, rawSubmissionTypes: Int32(SubmissionTypes.discussionTopic.rawValue), discussionTopicID: "12345", courseID: "1234")
        XCTAssertEqual(event.routingURL, URL(string: "/courses/1234/discussion_topics/12345"))
    }

    func test_routingURLCorrectForAssignmentQuiz() {
        let event = CalendarEvent.build(self.managedObjectContext, rawType: EventType.assignment.rawValue, rawSubmissionTypes: Int32(SubmissionTypes.quiz.rawValue), quizID: "12345", courseID: "1234")
        XCTAssertEqual(event.routingURL, URL(string: "/courses/1234/quizzes/12345"))
    }

    func test_routingURLCorrectForAssignment() {
        let event = CalendarEvent.build(self.managedObjectContext, rawType: EventType.assignment.rawValue, assignmentID: "12345", courseID: "1234")
        XCTAssertEqual(event.routingURL, URL(string: "/courses/1234/assignments/12345"))
    }

    func test_routingURLCorrectForErrorType() {
        let event = CalendarEvent.build(self.managedObjectContext, rawType: EventType.error.rawValue)
        XCTAssertEqual(event.routingURL, nil)
    }

    func test_itCorrectlyCalculatesOnlineSubmission() {
        var type = SubmissionTypes.discussionTopic
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.quiz
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.text
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.quiz
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.url
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.upload
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.mediaRecording
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.externalTool
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.none
        XCTAssertEqual(type.onlineSubmission, true)

        type = SubmissionTypes.onPaper
        XCTAssertEqual(type.onlineSubmission, false)
    }

    func test_itCorrectlyCalculatesCanSubmit() {
        var type = SubmissionTypes.discussionTopic
        XCTAssertEqual(type.canSubmit, true)

        type = []
        XCTAssertEqual(type.canSubmit, false)
    }

    // MARK: Helpers
    // TODO: Move this to EventType and EventWorkflowState

    func eventTypesAreEqual(_ left: EventType, _ right: EventType) -> Bool {
        if case left = right {
            return true
        } else {
            return false
        }
    }

    func workflowStatesAreEqual(_ left: EventWorkflowState, _ right: EventWorkflowState) -> Bool {
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
