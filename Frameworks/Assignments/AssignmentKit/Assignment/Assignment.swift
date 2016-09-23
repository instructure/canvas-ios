//
//  Assignment.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/28/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation
import CoreData
import FileKit

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

public final class Assignment: NSManagedObject, LockableModel {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var courseID: String
    @NSManaged internal (set) public var name: String
    @NSManaged internal (set) public var due: NSDate?
    @NSManaged internal (set) public var details: String
    @NSManaged internal (set) public var url: NSURL
    @NSManaged internal (set) public var htmlURL: NSURL
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
    @NSManaged internal (set) public var submittedAt: NSDate?
    @NSManaged internal (set) public var submissionExcused: Bool
    @NSManaged internal (set) public var gradedAt: NSDate?
    @NSManaged private (set) public var rawStatus: Int64
    @NSManaged internal (set) public var muted: Bool
    
    @NSManaged internal (set) public var needsGradingCount: Int32
    @NSManaged internal (set) public var published: Bool
    @NSManaged internal (set) public var dueDateOverrides: Set<DueDateOverride>?

    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?
    @NSManaged public var canView: Bool
    @NSManaged internal (set) public var unlockAt: NSDate?
    
    @NSManaged internal (set) public var discussionTopicID: String?
    @NSManaged internal (set) public var quizID: String?

    @NSManaged internal (set) public var rubric: Rubric?
    @NSManaged internal (set) public var submissionUploads: Set<SubmissionUpload>
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

            return GradingType.Error
        } set {
            rawGradingType = String(newValue.rawValue)
        }
    }
    
    public var icon: UIImage {
        let name: String
        
        switch submissionTypes {
        case [.Quiz]:               name = "icon_quizzes"
        case [.DiscussionTopic]:    name = "icon_discussions"
        case [.ExternalTool]:       name = "icon_tools"
        default:                    name = "icon_assignments"
        }
        
        let bundle = NSBundle(forClass: Assignment.self)
        return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)!
    }

    static let gradeNumberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    public var grade: String {
        let formatter = Assignment.gradeNumberFormatter
        let grade: String
        switch gradingType {
        case .NotGraded:
            grade = "n/a"
        case .LetterGrade, .GPAScale, .PassFail, .Percent:
            grade = currentGrade.isEmpty ? "-" : currentGrade
        case .Points:
            let points: String
            if let d = Double(currentGrade) where !currentGrade.isEmpty {
                points = formatter.stringFromNumber(NSNumber(double: d)) ?? "-"
            } else {
                points = "-"
            }
            let possible = formatter.stringFromNumber(NSNumber(double: pointsPossible)) ?? "-"

            grade = "\(points)/\(possible)"
        case .Error:
            grade = "- error"
        }
        return grade
    }

    var assignmentGroupName: String {
        return assignmentGroup?.name ?? NSLocalizedString("None", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Section header for assignments without an assignment group")
    }
    
    public func getUploadTypesFromSubmissionTypes() -> UploadTypes {
        var uploadTypes: UploadTypes = []
        if self.submissionTypes.contains(.Text) {
            uploadTypes.insert(.Text)
        }
        if self.submissionTypes.contains(.URL) {
            uploadTypes.insert(.URL)
        }
        if self.submissionTypes.contains(.Upload) {
            uploadTypes.insert(.Upload)
        }
        if self.submissionTypes.contains(.MediaRecording) {
            uploadTypes.insert(.MediaRecording)
        }
        if self.submissionTypes.contains(.None) {
            uploadTypes.insert(.None)
        }
        return uploadTypes
    }
}

public enum DueStatus: String, CustomStringConvertible {
    case Overdue = "0"
    case Upcoming = "1"
    case Undated = "2"
    case Past = "3"

    init(assignment: Assignment) {
        guard let due = assignment.due else { self = .Undated; return }

        let now = NSDate()
        if due.compare(now) == .OrderedDescending {
            self = .Upcoming
        } else {
            let types = assignment.submissionTypes
            if types.onlineSubmission && types.canSubmit && !assignment.lockedForUser && !assignment.hasSubmitted {
                self = .Overdue
            } else {
                self = .Past
            }
        }
    }

    public var description: String {
        switch self {
        case .Overdue: return NSLocalizedString("Overdue", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Overdue assignmnets (not turned in)")
        case .Upcoming: return NSLocalizedString("Upcoming", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Upcoming assignments")
        case .Undated: return NSLocalizedString("Undated", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Assignments with no dates")
        case .Past: return NSLocalizedString("Past", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Assignments that have been turned in and are past")
        }
    }
}

public enum GradingType: String {
    case PassFail = "pass_fail", Percent = "percent", GPAScale = "gpa_scale", LetterGrade = "letter_grade", Points = "points", NotGraded = "not_graded", Error = "error"
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
        switch typeString.lowercaseString ?? "" {
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

import SoPersistent
import Marshal
import SoLazy


extension Assignment {
    public var allowsSubmissions: Bool {
        return !submissionTypes.contains(SubmissionTypes.None) && gradingType != GradingType.NotGraded && !lockedForUser
    }
}

extension NSError {
    private static func quizURLFail(url: NSURL, file: String = #file, line: UInt = #line) -> NSError {
        let ErrorTitle = NSLocalizedString("Error Updating Assignment", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Error title for parsing assignment data from server")
        let ErrorDescription = NSLocalizedString("There was a problem updating the Quiz URL", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Error description for failing to compute the URL to a quiz")
        
        return NSError(subdomain: "AssignmentKit", code: 0, sessionID: nil, apiURL: url, title: ErrorTitle, description: ErrorDescription, failureReason: nil, file: file, line: line)
    }
}

extension Assignment: SynchronizedModel {

    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    private func updateRubric(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        if let rubricCriterions: [JSONObject] = try json <| "rubric" ?? [], rubricSettings: JSONObject = try json <| "rubric_settings" {
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
    
    private func updateURL(json: JSONObject) throws {
        switch submissionTypes {
        case [.ExternalTool]: url = try (try json <| "url") ?? (try json <| "html_url")
        case [.DiscussionTopic]: url = try (try json <| "discussion_topic.url") ?? (try json <| "html_url")
        case [.Quiz]:
            let htmlURL: NSURL = try json <| "html_url"
            guard let components = NSURLComponents(URL: htmlURL, resolvingAgainstBaseURL: false) else {
                throw NSError.quizURLFail(htmlURL)
            }
            components.path = "/courses/\(courseID)/quizzes/\(quizID ?? "0")"
            components.query = nil
            
            guard let quizURL = components.URL else {
                throw NSError.quizURLFail(htmlURL)
            }
            
            url = quizURL
        default: url = try json <| "html_url"
        }
    }
    
    private func updateOverrides(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        guard let oJSON: [JSONObject] = try json <| "overrides" else {
            for dateOverride in (dueDateOverrides ?? []) {
                dateOverride.delete(inContext: context)
            }
            dueDateOverrides = nil
            return
        }
        
        // only care about due date overrides for now.
        DueDateOverride.upsert(inContext: context)(jsonArray: oJSON.filter { $0["due_at"] != nil })
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id                  = try json.stringID("id")
        courseID            = try json.stringID("course_id")
        name                = try json <| "name"
        due                 = try json <| "due_at"
        details             = try json <| "description" ?? ""
        pointsPossible      = try json <| "points_possible" ?? 0
        rawGradingType      = try json <| "grading_type" ?? ""
        useRubricForGrading = try json <| "use_rubric_for_grading" ?? false
        let types: [String] = try json <| "submission_types"
        submissionTypes     = SubmissionTypes.fromStrings(types)
        gradingType         = GradingType(rawValue: rawGradingType) ?? GradingType.Error
        unlockAt            = try json <| "unlock_at"
        discussionTopicID   = try json.stringID("discussion_topic.id")
        quizID              = try json.stringID("quiz_id")
        needsGradingCount   = try json <| "needs_grading_count" ?? 0
        htmlURL             = try json <| "html_url"
        muted               = try json <| "muted" ?? false
        assignmentGroupID   = try json.stringID("assignment_group_id")
        assignmentGroup     = try assignmentGroupID.flatMap { try context.findOne(withValue: $0, forKey: "id") }

        try updateSubmission(json, inContext: context)
        try updateURL(json)
        try updateRubric(json, inContext: context)
        try updateOverrides(json, inContext: context)
        try updateLockStatus(json)
    }

    func updateSubmission(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        var status: SubmissionStatus = []
        var submissionState = ""
        if let submissionJSON: JSONObject = try json <| "submission" {
            let attempt: Int = (try submissionJSON <| "attempt") ?? 0
            hasSubmitted        = attempt > 0

            // Can't simply check that there is a submission, SpeedGrader on Web creates one if they try
            // and grade without a submission. So we also check the attempt
            if hasSubmitted {
                status.insert(.Submitted)
            }

            currentGrade        = (try submissionJSON <| "grade") ?? ""
            currentScore        = try submissionJSON <| "score"
            submissionLate      = try submissionJSON <| "late" ?? false
            submittedAt         = try submissionJSON <| "submitted_at"
            submissionExcused   = try submissionJSON <| "excused" ?? false
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
    public static var parameters: [String: AnyObject] { return ["include": ["assignment_visibility", "all_dates", "submission"]] }
}
