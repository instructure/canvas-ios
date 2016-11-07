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
import CoreData
import SoPersistent
import Marshal
import SoLazy

public enum EventWorkflowState: String {
    case Active = "active"
    case Locked = "locked"
    case Deleted = "deleted"
}

public enum EventType: String {
    case Quiz = "quiz"
    case Assignment = "assignment"
    case Discussion = "discussion"
    case CalendarEvent = "event"
    case Error = "error"
}

public struct SubmissionTypes: OptionSetType {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let OnPaper           = SubmissionTypes(rawValue: 1<<0)
    public static let DiscussionTopic   = SubmissionTypes(rawValue: 1<<1)
    public static let Quiz              = SubmissionTypes(rawValue: 1<<2)
    public static let ExternalTool      = SubmissionTypes(rawValue: 1<<3)
    public static let Text              = SubmissionTypes(rawValue: 1<<4)
    public static let URL               = SubmissionTypes(rawValue: 1<<5)
    public static let Upload            = SubmissionTypes(rawValue: 1<<6)
    public static let MediaRecording    = SubmissionTypes(rawValue: 1<<7)
    public static let None              = SubmissionTypes(rawValue: 1<<8)

    public static func fromStrings(strings: [String]) -> SubmissionTypes {
        return strings.map(SubmissionTypes.typeForString).reduce([]) { $0.union($1) }
    }

    private static func typeForString(typeString: String) -> SubmissionTypes {
        switch typeString.lowercaseString {
        case "discussion_topic":    return .DiscussionTopic
        case "online_quiz":         return .Quiz
        case "on_paper":            return .OnPaper
        case "external_tool":       return .ExternalTool
        case "online_text_entry":   return .Text
        case "online_url":          return .URL
        case "online_upload":       return .Upload
        case "media_recording":     return .MediaRecording
        case "none":                return .None
        default:                    return []
        }
    }

    static let OnlineSubmissions: SubmissionTypes = [.DiscussionTopic, .Quiz, .Text, .URL, .Upload, .MediaRecording, .ExternalTool, .None]
    public var onlineSubmission: Bool {
        return !intersect(.OnlineSubmissions).isEmpty
    }

    public var canSubmit: Bool {
        return !isEmpty
    }
}

public struct SubmissionStatus: OptionSetType {
    public let rawValue: Int64
    public init(rawValue: Int64) { self.rawValue = rawValue}

    public static let Late      = SubmissionStatus(rawValue: 1)
    public static let Excused   = SubmissionStatus(rawValue: 2)
    public static let Submitted = SubmissionStatus(rawValue: 4)
    public static let Graded    = SubmissionStatus(rawValue: 8)
    public static let PendingReview = SubmissionStatus(rawValue: 16)
    public static let Unsubmitted = SubmissionStatus(rawValue: 32)
}

public final class CalendarEvent: NSManagedObject {

    public static var dayDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()

    public static var sectionTitleDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        return dateFormatter
    }()

    public static var dueDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        return dateFormatter
    }()

    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var title: String?
    @NSManaged internal (set) public var startAt: NSDate?
    @NSManaged internal (set) public var endAt: NSDate?
    @NSManaged internal (set) public var htmlDescription: String?
    @NSManaged internal (set) public var locationName: String?
    @NSManaged internal (set) public var locationAddress: String?
    @NSManaged internal (set) public var contextCode: String
    @NSManaged internal (set) public var effectiveContextCode: String?
    @NSManaged internal var rawWorkflowState: String
    @NSManaged internal (set) public var hidden: Bool
    @NSManaged internal (set) public var url: NSURL
    @NSManaged internal (set) public var htmlURL: NSURL
    @NSManaged internal (set) public var allDayDate: String
    @NSManaged internal (set) public var allDay: Bool
    @NSManaged internal (set) public var createdAt: NSDate
    @NSManaged internal (set) public var updatedAt: NSDate
    @NSManaged internal var rawType: String
    @NSManaged internal (set) public var hasSubmitted: Bool

    @NSManaged internal (set) public var rawSubmissionTypes: Int32
    @NSManaged internal (set) public var assignmentID: String?
    @NSManaged internal (set) public var discussionTopicID: String?
    @NSManaged internal (set) public var quizID: String?
    @NSManaged internal (set) public var courseID: String?
    @NSManaged internal (set) public var currentGrade: String?
    @NSManaged internal (set) public var currentScore: NSNumber?
    @NSManaged internal (set) public var pointsPossible: NSNumber?
    @NSManaged internal (set) public var submissionLate: Bool
    @NSManaged internal (set) public var submittedAt: NSDate?
    @NSManaged internal (set) public var submissionExcused: Bool
    @NSManaged internal (set) public var gradedAt: NSDate?
    @NSManaged internal (set) public var rawStatus: Int64
    @NSManaged internal (set) public var muted: Bool

    var workflowState: EventWorkflowState {
        return EventWorkflowState(rawValue: rawWorkflowState)!
    }

    public var status: SubmissionStatus {
        get {
            return SubmissionStatus(rawValue: rawStatus)
        } set {
            rawStatus = newValue.rawValue
        }
    }

    internal (set) public var submissionTypes: SubmissionTypes {
        get {
            return SubmissionTypes(rawValue: Int(rawSubmissionTypes))
        } set {
            rawSubmissionTypes = Int32(newValue.rawValue)
        }
    }

    public var type: EventType {
        if let type = EventType(rawValue: rawType) {
            if let _ = quizID where type == .Assignment {
                return .Quiz
            }

            return type
        }

        return EventType.Error
    }

    public var pastStartDate: Bool {
        guard let startAt = startAt else {
            return false
        }

        return NSDate().compare(startAt) == NSComparisonResult.OrderedDescending
    }

    public var pastEndDate: Bool {
        guard let endAt = endAt else {
            return false
        }

        return NSDate().compare(endAt) == NSComparisonResult.OrderedDescending
    }

    public var routingURL: NSURL? {
        switch type {
        case .CalendarEvent:
            return NSURL(string: "/calendar_events/" + id)
        case .Assignment:
            if submissionTypes.contains(.DiscussionTopic) {
                guard let discussionTopicID = discussionTopicID, courseID = courseID else { ❨╯°□°❩╯⌢"Cannot create routingID without discussionTopicID" }
                return NSURL(string: "/courses/" + courseID + "/discussion_topics/" + discussionTopicID)
            } else if submissionTypes.contains(.Quiz) {
                guard let quizID = quizID, courseID = courseID else { ❨╯°□°❩╯⌢"Cannot create routingID without quizID" }
                return NSURL(string: "/courses/" + courseID + "/quizzes/" + quizID)
            } else {
                guard let assignmentID = assignmentID, courseID = courseID else { ❨╯°□°❩╯⌢"Cannot create routingID without assignmentID" }
                return NSURL(string: "/courses/" + courseID + "/assignments/" + assignmentID)
            }
        case .Quiz:
            guard let quizID = quizID, courseID = courseID else { ❨╯°□°❩╯⌢"Cannot create routingID without quizID" }
            return NSURL(string: "/courses/" + courseID + "/quizzes/" + quizID)
        default:
            return nil
        }
    }
}

extension CalendarEvent: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")

        title = try json  <| ("title")
        startAt = try json <| "start_at"
        endAt = try json <| "end_at"
        htmlDescription = try json  <| "description"
        locationName = try json  <| "location_name"
        locationAddress = try json  <| "location_address"
        contextCode = try json  <| ("context_code")
        effectiveContextCode = try json  <| "effective_context_code"
        rawWorkflowState = try json  <| "workflow_state"
        hidden = try json  <| ("hidden") ?? false
        url = try json  <| "url"
        htmlURL = try json  <| "html_url"

        if let endAt = endAt {
            allDayDate = CalendarEvent.dayDateFormatter.stringFromDate(endAt)
        } else {
            allDayDate = "Unknown"
        }

        allDay = try json  <| "all_day" ?? false
        createdAt = try json  <| "created_at"
        updatedAt = try json  <| "updated_at"
        rawType = try json  <| "type"

        var status: SubmissionStatus = []
        var submissionState = ""
        if let assignmentJSON: JSONObject = try json <| "assignment" {
            pointsPossible      = try assignmentJSON <| "points_possible"
            assignmentID        = try assignmentJSON.stringID("id")
            courseID            = try assignmentJSON.stringID("course_id")
            discussionTopicID   = try assignmentJSON.stringID("discussion_topic.id")
            quizID              = try assignmentJSON.stringID("quiz_id")
            let types: [String] = try assignmentJSON <| "submission_types"
            submissionTypes     = SubmissionTypes.fromStrings(types)
            muted               = try assignmentJSON <| "muted" ?? false

            if let submissionJSON: JSONObject = try assignmentJSON <| "submission" {
                let attempt: Int = (try submissionJSON <| "attempt") ?? 0
                hasSubmitted        = attempt > 0

                // Can't simply check that there is a submission, SpeedGrader on Web creates one if they try
                // and grade without a submission.
                if hasSubmitted {
                    status.insert(.Submitted)
                }

                currentGrade        = try submissionJSON <| "grade"
                currentScore        = try submissionJSON <| "score"
                submissionLate      = try submissionJSON <| "late" ?? false
                submittedAt         = try submissionJSON <| "submitted_at"
                submissionExcused   = try submissionJSON <| "excused" ?? false
                gradedAt            = try submissionJSON <| "graded_at"
                submissionState  = try submissionJSON <| "workflow_state"

                // The API can give us ghost "graded" states if the teacher taps in SpeedGrader in the grade box...
                // let's make sure an actual grade exists, otherwise it's not actually "graded"
                if submissionState == "graded" && (submissionJSON["grade"] == nil || (submissionJSON["grade"] as? NSNull != nil)) {
                    submissionState = ""
                }
            } else {
                currentGrade = nil
                currentScore = nil
                submissionLate = false
                submissionExcused = false
                hasSubmitted = false
            }
        }

        if submissionLate {
            status.insert(.Late)
        }
        if submissionExcused {
            status.insert(.Excused)
        }
        if submissionState == "graded" {
            status.insert(.Graded)
        }
        if submissionState == "pending_review" {
            status.insert(.PendingReview)
        }
        
        self.status = status
    }
}

