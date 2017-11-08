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



public struct SubmissionStatus: OptionSet {
    public let rawValue: Int64
    public init(rawValue: Int64) { self.rawValue = rawValue}

    public static let Late      = SubmissionStatus(rawValue: 1)
    public static let Excused   = SubmissionStatus(rawValue: 2)
    public static let Submitted = SubmissionStatus(rawValue: 4)
    public static let Graded    = SubmissionStatus(rawValue: 8)
    public static let PendingReview = SubmissionStatus(rawValue: 16)
    public static let Unsubmitted = SubmissionStatus(rawValue: 32)
}

public final class Assignment: NSManagedObject, LockableModel {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var courseID: String
    @NSManaged internal (set) public var name: String
    @NSManaged internal (set) public var due: Date?
    @NSManaged internal (set) public var details: String
    @NSManaged internal (set) public var url: URL
    @NSManaged internal (set) public var htmlURL: URL
    @NSManaged internal (set) public var rawSubmissionTypes: Int32
    @NSManaged internal (set) public var rawDueStatus: String
    @NSManaged internal (set) public var hasSubmitted: Bool
    @NSManaged internal (set) public var allowedExtensions: [String]?
    @NSManaged internal (set) public var pointsPossible: Double
    @NSManaged internal (set) public var rawGradingType: String
    @NSManaged internal (set) public var useRubricForGrading: Bool
    @NSManaged internal (set) public var assignmentGroupID: String?
    @NSManaged internal (set) public var gradingPeriodID: String?
    @NSManaged internal (set) public var currentGrade: String
    @NSManaged internal (set) public var currentScore: NSNumber?
    @NSManaged internal (set) public var submissionLate: Bool
    @NSManaged internal (set) public var submittedAt: Date?
    @NSManaged internal (set) public var submissionExcused: Bool
    @NSManaged internal (set) public var gradedAt: Date?
    @NSManaged fileprivate (set) public var rawStatus: Int64
    @NSManaged internal (set) public var muted: Bool
    @NSManaged internal (set) public var groupSetID: String?
    
    @NSManaged internal (set) public var needsGradingCount: Int32
    @NSManaged internal (set) public var published: Bool
    @NSManaged internal (set) public var dueDateOverrides: Set<DueDateOverride>?

    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?
    @NSManaged public var canView: Bool
    @NSManaged internal (set) public var unlockAt: Date?
    
    @NSManaged internal (set) public var discussionTopicID: String?
    @NSManaged internal (set) public var quizID: String?

    @NSManaged internal (set) public var rubric: Rubric?
    @NSManaged internal (set) public var assignmentGroup: AssignmentGroup?

    internal (set) public var submissionTypes: SubmissionTypes {
        get {
            return SubmissionTypes(rawValue: Int(rawSubmissionTypes))
        } set {
            rawSubmissionTypes = Int32(newValue.rawValue)
        }
    }

    public var status: SubmissionStatus {
        get {
            return SubmissionStatus(rawValue: rawStatus)
        } set {
            rawStatus = newValue.rawValue
        }
    }

    public var gradingType: GradingType {
        get {
            if let gradingType = GradingType(rawValue: String(rawGradingType)) {
                return gradingType
            }

            return .error
        } set {
            rawGradingType = String(newValue.rawValue)
        }
    }
    
    public var icon: UIImage {
        switch submissionTypes {
        case [.quiz]:               return .icon(.quiz)
        case [.discussionTopic]:    return .icon(.discussion)
        case [.externalTool]:       return .icon(.lti)
        default:                    return .icon(.assignment)
        }
    }

    static let gradeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    public var grade: String {
        let formatter = Assignment.gradeNumberFormatter
        let grade: String
        switch gradingType {
        case .notGraded:
            grade = "n/a"
        case .letterGrade, .gpaScale, .passFail, .percent:
            grade = currentGrade.isEmpty ? "-" : currentGrade
        case .points:
            let points: String
            if let d = Double(currentGrade), !currentGrade.isEmpty {
                points = formatter.string(from: NSNumber(value: d as Double)) ?? "-"
            } else {
                points = "-"
            }
            let possible = formatter.string(from: NSNumber(value: pointsPossible as Double)) ?? "-"

            grade = "\(points)/\(possible)"
        case .error:
            grade = "-"
        }
        return grade
    }

    public var graded: Bool {
        return status.contains(.Graded)
    }

    var assignmentGroupName: String {
        return assignmentGroup?.name ?? NSLocalizedString("None", tableName: "Localizable", bundle: .core, value: "", comment: "Section header for assignments without an assignment group")
    }
}

public enum DueStatus: String, CustomStringConvertible {
    case Overdue = "0"
    case Upcoming = "1"
    case Undated = "2"
    case Past = "3"

    init(assignment: Assignment) {
        guard let due = assignment.due else { self = .Undated; return }

        let now = Clock.currentTime()
        if due.compare(now) == .orderedDescending {
            self = .Upcoming
        } else {
            let types = assignment.submissionTypes
            if types.onlineSubmission && types.canSubmit && !assignment.lockedForUser && !assignment.hasSubmitted && !assignment.graded {
                self = .Overdue
            } else {
                self = .Past
            }
        }
    }

    public var description: String {
        switch self {
        case .Overdue: return NSLocalizedString("Overdue", tableName: "Localizable", bundle: .core, value: "", comment: "Overdue assignmnets (not turned in)")
        case .Upcoming: return NSLocalizedString("Upcoming", tableName: "Localizable", bundle: .core, value: "", comment: "Upcoming assignments")
        case .Undated: return NSLocalizedString("Undated", tableName: "Localizable", bundle: .core, value: "", comment: "Assignments with no dates")
        case .Past: return NSLocalizedString("Past", tableName: "Localizable", bundle: .core, value: "", comment: "Assignments that have been turned in and are past")
        }
    }
}

public enum GradingType: String {
    case passFail = "pass_fail"
    case percent = "percent"
    case gpaScale = "gpa_scale"
    case letterGrade = "letter_grade"
    case points = "points"
    case notGraded = "not_graded"
    case error = "error"
}

public struct SubmissionTypes: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let onPaper           = SubmissionTypes(rawValue: 1<<0)
    public static let discussionTopic   = SubmissionTypes(rawValue: 1<<1)
    public static let quiz              = SubmissionTypes(rawValue: 1<<2)
    public static let externalTool      = SubmissionTypes(rawValue: 1<<3)
    public static let text              = SubmissionTypes(rawValue: 1<<4)
    public static let url               = SubmissionTypes(rawValue: 1<<5)
    public static let upload            = SubmissionTypes(rawValue: 1<<6)
    public static let mediaRecording    = SubmissionTypes(rawValue: 1<<7)
    public static let none              = SubmissionTypes(rawValue: 1<<8)

    public static func fromStrings(_ strings: [String]) -> SubmissionTypes {
        return strings.map(SubmissionTypes.typeForString).reduce([]) { $0.union($1) }
    }

    fileprivate static func typeForString(_ typeString: String) -> SubmissionTypes {
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

    static let onlineSubmissions: SubmissionTypes = [.discussionTopic, .quiz, .text, .url, .upload, .mediaRecording, .externalTool, .none]
    public var onlineSubmission: Bool {
        return !intersection(.onlineSubmissions).isEmpty
    }

    public var canSubmit: Bool {
        return !isEmpty
    }
}


import Marshal



extension Assignment {
    public var allowsSubmissions: Bool {
        return !submissionTypes.contains(.none) && gradingType != .notGraded && !lockedForUser
    }
}

extension NSError {
    fileprivate static func quizURLFail(_ url: URL, file: String = #file, line: UInt = #line) -> NSError {
        let ErrorTitle = NSLocalizedString("Error Updating Assignment", tableName: "Localizable", bundle: .core, value: "", comment: "Error title for parsing assignment data from server")
        let ErrorDescription = NSLocalizedString("There was a problem updating the Quiz URL", tableName: "Localizable", bundle: .core, value: "", comment: "Error description for failing to compute the URL to a quiz")
        
        return NSError(subdomain: "AssignmentKit", code: 0, sessionID: nil, apiURL: url, title: ErrorTitle, description: ErrorDescription, failureReason: nil, file: file, line: line)
    }
}

extension Assignment: SynchronizedModel {

    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    fileprivate func updateRubric(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        let rubricCriterions: [JSONObject] = (try json <| "rubric") ?? []
        if let rubricSettings: JSONObject = try json <| "rubric_settings" {
            if let rubric: Rubric = try context.findOne(withPredicate: try Rubric.uniquePredicateForObject(self.id)) {
                try rubric.updateValues(rubricCriterions, rubricSettingsJSON: rubricSettings, assignmentID: self.id, inContext: context)
            } else {
                self.rubric = Rubric(inContext: context)
                try self.rubric?.updateValues(rubricCriterions, rubricSettingsJSON: rubricSettings, assignmentID: self.id, inContext: context)
            }
            
            self.rubric?.assignment = self
            self.rubric?.courseID = self.courseID
        } else {
            if let oldRubric = rubric {
                oldRubric.delete(inContext: context)
            }
            
            rubric = nil
        }
    }
    
    fileprivate func updateURL(_ json: JSONObject) throws {
        switch submissionTypes {
        case [.externalTool]: url = try (try json <| "url") ?? (try json <| "html_url")
        case [.discussionTopic]: url = try (try json <| "discussion_topic.url") ?? (try json <| "html_url")
        case [.quiz]:
            let htmlURL: URL = try json <| "html_url"
            guard var components = URLComponents(url: htmlURL, resolvingAgainstBaseURL: false) else {
                throw NSError.quizURLFail(htmlURL)
            }
            components.path = "/courses/\(courseID)/quizzes/\(quizID ?? "0")"
            components.query = nil
            
            guard let quizURL = components.url else {
                throw NSError.quizURLFail(htmlURL)
            }
            
            url = quizURL
        default: url = try json <| "html_url"
        }
    }
    
    fileprivate func updateOverrides(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        guard let oJSON: [JSONObject] = try json <| "overrides" else {
            for dateOverride in (dueDateOverrides ?? []) {
                dateOverride.delete(inContext: context)
            }
            dueDateOverrides = nil
            return
        }
        
        // only care about due date overrides for now.
        let _ = DueDateOverride.upsert(inContext: context, jsonArray: oJSON.filter { $0["due_at"] != nil })
    }
    
    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id                  = try json.stringID("id")
        courseID            = try json.stringID("course_id")
        name                = try json <| "name"
        due                 = try json <| "due_at"
        details             = (try json <| "description") ?? ""
        pointsPossible      = (try json <| "points_possible") ?? 0
        rawGradingType      = (try json <| "grading_type") ?? ""
        useRubricForGrading = (try json <| "use_rubric_for_grading") ?? false
        let types: [String] = try json <| "submission_types"
        submissionTypes     = SubmissionTypes.fromStrings(types)
        gradingType         = GradingType(rawValue: rawGradingType) ?? .error
        unlockAt            = try json <| "unlock_at"
        discussionTopicID   = try json.stringID("discussion_topic.id")
        quizID              = try json.stringID("quiz_id")
        needsGradingCount   = (try json <| "needs_grading_count") ?? 0
        htmlURL             = try json <| "html_url"
        muted               = (try json <| "muted") ?? false
        assignmentGroupID   = try json.stringID("assignment_group_id")
        groupSetID          = try json.stringID("group_category_id")
        
        assignmentGroup     = try assignmentGroupID.flatMap { try context.findOne(withValue: $0, forKey: "id") }

        try updateSubmission(json, inContext: context)
        try updateURL(json)
        try updateRubric(json, inContext: context)
        try updateOverrides(json, inContext: context)
        try updateLockStatus(json)
    }

    func updateSubmission(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        var status: SubmissionStatus = []
        var submissionState = ""

        // "submission" is an array if we are an observer
        let submissions: [JSONObject]? = try? json <| "submission"
        let submission: JSONObject? = try? json <| "submission"
        if let submissionJSON = submissions?.first ?? submission {
            let attempt: Int = (try submissionJSON <| "attempt") ?? 0
            hasSubmitted        = attempt > 0

            // Can't simply check that there is a submission, SpeedGrader on Web creates one if they try
            // and grade without a submission. So we also check the attempt
            if hasSubmitted {
                status.insert(.Submitted)
            }

            currentGrade        = (try submissionJSON <| "grade") ?? ""
            currentScore        = try submissionJSON <| "score"
            submissionLate      = (try submissionJSON <| "late") ?? false
            submittedAt         = try submissionJSON <| "submitted_at"
            submissionExcused   = (try submissionJSON <| "excused") ?? false
            gradedAt            = try submissionJSON <| "graded_at"
            submissionState     = try submissionJSON <| "workflow_state"

            // The API can give us ghost "graded" states if the teacher taps in SpeedGrader in the grade box...
            // let's make sure an actual grade exists, otherwise it's not actually "graded"
            if submissionState == "graded" && (submissionJSON["grade"] == nil || (submissionJSON["grade"] as? NSNull != nil)) {
                submissionState = ""
            }
        } else {
            hasSubmitted = false
            currentGrade = ""
            currentScore = 0
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

        // these must be last as they are derived.
        // they must be part of the mananged object model
        // so that they can be used by the FRC to section
        rawDueStatus = DueStatus(assignment: self).rawValue
    }

    // API parameters
    public static var parameters: [String: Any] { return ["include": ["assignment_visibility", "all_dates", "submission", "observed_users"]] }
}
