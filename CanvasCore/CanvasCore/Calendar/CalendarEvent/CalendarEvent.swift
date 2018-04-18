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

import Marshal


public enum EventWorkflowState: String {
    case active = "active"
    case locked = "locked"
    case deleted = "deleted"
}

public enum EventType: String {
    case quiz = "quiz"
    case assignment = "assignment"
    case discussion = "discussion"
    case calendarEvent = "event"
    case error = "error"
}

public struct EventSubmissionTypes: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let onPaper           = EventSubmissionTypes(rawValue: 1<<0)
    public static let discussionTopic   = EventSubmissionTypes(rawValue: 1<<1)
    public static let quiz              = EventSubmissionTypes(rawValue: 1<<2)
    public static let externalTool      = EventSubmissionTypes(rawValue: 1<<3)
    public static let text              = EventSubmissionTypes(rawValue: 1<<4)
    public static let url               = EventSubmissionTypes(rawValue: 1<<5)
    public static let upload            = EventSubmissionTypes(rawValue: 1<<6)
    public static let mediaRecording    = EventSubmissionTypes(rawValue: 1<<7)
    public static let none              = EventSubmissionTypes(rawValue: 1<<8)

    public static func fromStrings(_ strings: [String]) -> EventSubmissionTypes {
        return strings.map(EventSubmissionTypes.typeForString).reduce([]) { $0.union($1) }
    }

    fileprivate static func typeForString(_ typeString: String) -> EventSubmissionTypes {
        switch typeString.lowercased() {
        case "discussion_topic":    return .discussionTopic
        case "online_quiz":         return .quiz
        case "on_paper":            return .onPaper
        case "external_tool":       return .externalTool
        case "online_text_entry":   return .text
        case "online_url":          return .url
        case "online_upload":       return .upload
        case "media_recording":     return .mediaRecording
        case "none":                return .none
        default:                    return []
        }
    }

    static let OnlineSubmissions: EventSubmissionTypes = [.discussionTopic, .quiz, .text, .url, .upload, .mediaRecording, .externalTool, .none]
    public var onlineSubmission: Bool {
        return !intersection(.OnlineSubmissions).isEmpty
    }

    public var canSubmit: Bool {
        return !isEmpty
    }
}

public struct EventSubmissionStatus: OptionSet {
    public let rawValue: Int64
    public init(rawValue: Int64) { self.rawValue = rawValue}

    public static let late      = EventSubmissionStatus(rawValue: 1)
    public static let excused   = EventSubmissionStatus(rawValue: 2)
    public static let submitted = EventSubmissionStatus(rawValue: 4)
    public static let graded    = EventSubmissionStatus(rawValue: 8)
    public static let pendingReview = EventSubmissionStatus(rawValue: 16)
    public static let unsubmitted = EventSubmissionStatus(rawValue: 32)
}

public final class CalendarEvent: NSManagedObject {

    public static var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()

    public static var sectionTitleDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        return dateFormatter
    }()

    public static var dueDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        return dateFormatter
    }()

    public static var dateRangeFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .full
        return formatter
    }()

    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var parentEventID: String?
    @NSManaged internal (set) public var title: String?
    @NSManaged internal (set) public var startAt: Date?
    @NSManaged internal (set) public var endAt: Date?
    @NSManaged internal (set) public var htmlDescription: String?
    @NSManaged internal (set) public var locationName: String?
    @NSManaged internal (set) public var locationAddress: String?
    @NSManaged internal (set) public var contextCode: String
    @NSManaged internal (set) public var effectiveContextCode: String?
    @NSManaged internal var rawWorkflowState: String
    @NSManaged internal (set) public var hidden: Bool
    @NSManaged internal (set) public var url: URL?
    @NSManaged internal (set) public var htmlURL: URL?
    @NSManaged internal (set) public var allDayDate: String
    @NSManaged internal (set) public var allDay: Bool
    @NSManaged internal (set) public var createdAt: Date
    @NSManaged internal (set) public var updatedAt: Date
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
    @NSManaged internal (set) public var submittedAt: Date?
    @NSManaged internal (set) public var submissionExcused: Bool
    @NSManaged internal (set) public var gradedAt: Date?
    @NSManaged internal (set) public var rawStatus: Int64
    @NSManaged internal (set) public var muted: Bool

    var workflowState: EventWorkflowState {
        return EventWorkflowState(rawValue: rawWorkflowState)!
    }

    public var status: EventSubmissionStatus {
        get {
            return EventSubmissionStatus(rawValue: rawStatus)
        } set {
            rawStatus = newValue.rawValue
        }
    }

    internal (set) public var submissionTypes: EventSubmissionTypes {
        get {
            return EventSubmissionTypes(rawValue: Int(rawSubmissionTypes))
        } set {
            rawSubmissionTypes = Int32(newValue.rawValue)
        }
    }

    public var type: EventType {
        if let type = EventType(rawValue: rawType) {
            if let _ = quizID, type == .assignment {
                return .quiz
            }

            return type
        }

        return EventType.error
    }

    public var locationInfo: String {
        if (locationName == nil && locationAddress == nil) { return "" }
        if let name = locationName,
            let address = locationAddress,
            !name.isEmpty, !address.isEmpty {
            return [name, address].joined(separator: ", ")
        }
        
        if let address = locationAddress, !address.isEmpty { return address }
        return (locationName ?? "")
    }
    
    public var pastStartDate: Bool {
        guard let startAt = startAt else {
            return false
        }

        return Date().compare(startAt) == ComparisonResult.orderedDescending
    }

    public var pastEndDate: Bool {
        guard let endAt = endAt else {
            return false
        }

        return Date().compare(endAt) == ComparisonResult.orderedDescending
    }

    public var routingURL: URL? {
        switch type {
        case .calendarEvent:
            return URL(string: "/calendar_events/" + (parentEventID ?? id))
        case .assignment:
            if submissionTypes.contains(.discussionTopic) {
                guard let discussionTopicID = discussionTopicID, let courseID = courseID else { ❨╯°□°❩╯⌢"Cannot create routingID without discussionTopicID" }
                return URL(string: "/courses/" + courseID + "/discussion_topics/" + discussionTopicID)
            } else if submissionTypes.contains(.quiz) {
                guard let quizID = quizID, let courseID = courseID else { ❨╯°□°❩╯⌢"Cannot create routingID without quizID" }
                return URL(string: "/courses/" + courseID + "/quizzes/" + quizID)
            } else {
                guard let assignmentID = assignmentID, let courseID = courseID else { ❨╯°□°❩╯⌢"Cannot create routingID without assignmentID" }
                return URL(string: "/courses/" + courseID + "/assignments/" + assignmentID)
            }
        case .quiz:
            guard let quizID = quizID, let courseID = courseID else { ❨╯°□°❩╯⌢"Cannot create routingID without quizID" }
            return URL(string: "/courses/" + courseID + "/quizzes/" + quizID)
        default:
            return nil
        }
    }
}

extension CalendarEvent: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")
        parentEventID = try json.stringID("parent_event_id")
        title = try json <| ("title")
        startAt = try json <| "start_at"
        endAt = try json <| "end_at"
        htmlDescription = try json <| "description"
        locationName = try json <| "location_name"
        locationAddress = try json <| "location_address"
        contextCode = try json <| ("context_code")
        effectiveContextCode = try json <| "effective_context_code"
        rawWorkflowState = try json <| "workflow_state"
        hidden = (try json <| "hidden") ?? false
        url = try json <| "url"
        htmlURL = try json <| "html_url"
        allDay = (try json <| "all_day") ?? false

        if allDay, let allDayDate: String = try json <| "all_day_date" {
            self.allDayDate = allDayDate
            startAt = CalendarEvent.dayDateFormatter.date(from: allDayDate)
        } else if let startAt = startAt {
            allDayDate = CalendarEvent.dayDateFormatter.string(from: startAt)
        } else {
            allDayDate = "Unknown"
        }

        createdAt = try json <| "created_at"
        updatedAt = try json <| "updated_at"
        rawType = try json <| "type"

        var status: EventSubmissionStatus = []
        var submissionState = ""
        if let assignmentJSON: JSONObject = try json <| "assignment" {
            pointsPossible      = try assignmentJSON <| "points_possible"
            assignmentID        = try assignmentJSON.stringID("id")
            courseID            = try assignmentJSON.stringID("course_id")
            discussionTopicID   = try assignmentJSON.stringID("discussion_topic.id")
            quizID              = try assignmentJSON.stringID("quiz_id")
            let types: [String] = try assignmentJSON <| "submission_types"
            submissionTypes     = EventSubmissionTypes.fromStrings(types)
            muted               = (try assignmentJSON <| "muted") ?? false

            if let submissionJSON: JSONObject = try assignmentJSON <| "submission" {
                let attempt: Int = (try submissionJSON <| "attempt") ?? 0
                hasSubmitted        = attempt > 0

                // Can't simply check that there is a submission, SpeedGrader on Web creates one if they try
                // and grade without a submission.
                if hasSubmitted {
                    status.insert(.submitted)
                }

                currentGrade        = try submissionJSON <| "grade"
                currentScore        = try submissionJSON <| "score"
                submissionLate      = (try submissionJSON <| "late") ?? false
                submittedAt         = try submissionJSON <| "submitted_at"
                submissionExcused   = (try submissionJSON <| "excused") ?? false
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
            status.insert(.late)
        }
        if submissionExcused {
            status.insert(.excused)
        }
        if submissionState == "graded" {
            status.insert(.graded)
        }
        if submissionState == "pending_review" {
            status.insert(.pendingReview)
        }
        
        self.status = status
    }
}

