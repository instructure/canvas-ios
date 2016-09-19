//
//  Course.swift
//  Enrollments
//
//  Created by Brandon Pluim on 1/15/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import Marshal
import TooLegit
import SoLazy
import ReactiveCocoa

public struct EnrollmentRoles: OptionSetType {
    public let rawValue: Int64
    public init(rawValue: Int64) { self.rawValue = rawValue}

    public static let Student  = EnrollmentRoles(rawValue: 1)
    public static let Teacher  = EnrollmentRoles(rawValue: 2)
    public static let Observer = EnrollmentRoles(rawValue: 4)
    public static let TA       = EnrollmentRoles(rawValue: 8)
    public static let Designer = EnrollmentRoles(rawValue: 16)
}

public enum DefaultCourseView: String {
    case Feed = "feed"
    case Wiki = "wiki"
    case Modules = "modules"
    case Assignments = "assignments"
    case Syllabus = "syllabus"
    
    var pathComponent: String {
        switch self {
        case .Feed:
            return "activity_stream"
        case .Wiki:
            return "front_page"
        default:
            return rawValue
        }
    }
}

private let percentageFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .PercentStyle
    formatter.multiplier = 1.0
    formatter.maximumFractionDigits = 2
    formatter.locale = NSLocale.currentLocale()
    return formatter
}()

public final class Course: Enrollment {

    @NSManaged internal (set) public var originalName: String?
    @NSManaged internal (set) public var code: String
    @NSManaged internal (set) public var startAt: NSDate?
    @NSManaged internal (set) public var endAt: NSDate?
    @NSManaged internal (set) public var hideFinalGrades: Bool
    @NSManaged internal (set) public var rawDefaultView: String
    @NSManaged internal (set) public var rawRoles: Int64
    @NSManaged internal (set) public var syllabusBody: String?
    @NSManaged internal (set) public var currentGradingPeriodID: String?
    @NSManaged internal (set) public var multipleGradingPeriodsEnabled: Bool // default: false
    @NSManaged internal (set) public var totalForAllGradingPeriodsEnabled: Bool // default: false

    @NSManaged internal (set) public var grades: Set<Grade>

    public override var hasGrades: Bool { return true }

    private var inMGPLimbo: Bool {
        return multipleGradingPeriodsEnabled && currentGradingPeriodID == nil
    }

    private var gradesAreVisible: Bool {
        return !inMGPLimbo || totalForAllGradingPeriodsEnabled
    }

    public var currentGrade: Grade? {
        return grades.filter { $0.gradingPeriodID == currentGradingPeriodID }.first
    }

    public override var visibleGrade: String? {
        guard gradesAreVisible else { return nil }
        return visibleGradingPeriodGrade(currentGradingPeriodID)
    }

    public override var visibleScore: String? {
        guard gradesAreVisible else { return nil }
        return visibleGradingPeriodScore(currentGradingPeriodID)
    }

    public func visibleGradingPeriodGrade(gradingPeriodID: String?) -> String? {
        return grades.filter { $0.gradingPeriodID == gradingPeriodID }.first?.currentGrade
    }

    public func visibleGradingPeriodScore(gradingPeriodID: String?) -> String? {
        return grades.filter { $0.gradingPeriodID == gradingPeriodID }.first?.currentScore.flatMap {
            percentageFormatter.stringFromNumber($0)
        }
    }

    public override var roles: EnrollmentRoles {
        get {
            return EnrollmentRoles(rawValue: rawRoles)
        } set {
            rawRoles = newValue.rawValue
        }
    }

    var defaultView: DefaultCourseView {
        return DefaultCourseView(rawValue: rawDefaultView) ?? .Feed
    }
    
    public override var defaultViewPath: String {
        return contextID.htmlPath / defaultView.pathComponent
    }

    public override var contextID: ContextID {
        return ContextID(id: id, context: .Course)
    }
    
    public override var shortName: String {
        return code
    }

    public override func markAsFavorite(favorite: Bool, session: Session) -> SignalProducer<Void, NSError> {
        let path = api/v1/"users"/"self"/"favorites"/"courses"/id
        let request = attemptProducer {
            favorite ? try session.POST(path) : try session.DELETE(path)
        }
        return super.markAsFavorite(favorite, session: session)
            .flatMap(.Concat, transform: { request })
            .flatMap(.Concat, transform: session.JSONSignalProducer)
            .map { _ in () }
            .on(failed: { [weak self] _ in
                self?.isFavorite = !favorite
                let _ = try? self?.managedObjectContext?.saveFRD()
            })
            .observeOn(UIScheduler())
    }
}

extension Course: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("id")
        name            = try json <| "name"
        originalName    = try json <| "original_name"
        code            = try json <| "course_code"
        isFavorite      = try json <| "is_favorite"
        startAt         = try json <| "start_at"
        endAt           = try json <| "end_at"
        hideFinalGrades = try json <| "hide_final_grades"
        syllabusBody    = try json <| "syllabus_body"

        rawDefaultView  = try json <| "default_view" ?? "assignments"

        let enrollmentsJSON: [JSONObject] = try json <| "enrollments"
        var roles: EnrollmentRoles = []
        for eJSON in enrollmentsJSON {
            let type: String = try eJSON <| "type"
            switch type {
            case "student":
                roles.insert(.Student)
                currentGradingPeriodID = try eJSON.stringID("current_grading_period_id")
                multipleGradingPeriodsEnabled = try eJSON <| "multiple_grading_periods_enabled" ?? false
                let grade = currentGrade ?? Grade(inContext: context)
                grade.course = self
                grade.gradingPeriodID = currentGradingPeriodID

                if multipleGradingPeriodsEnabled {
                    grade.currentGrade = try eJSON <| "current_period_computed_current_grade"
                    grade.currentScore = try eJSON <| "current_period_computed_current_score"
                    grade.finalGrade = try eJSON <| "current_period_computed_final_grade"
                    grade.finalScore = try eJSON <| "current_period_computed_final_score"
                    totalForAllGradingPeriodsEnabled = try eJSON <| "totals_for_all_grading_periods_option"
                } else {
                    grade.currentGrade = try eJSON <| "computed_current_grade"
                    grade.currentScore = try eJSON <| "computed_current_score"
                    grade.finalGrade = try eJSON <| "computed_final_grade"
                    grade.finalScore = try eJSON <| "computed_final_score"
                }
            case "teacher":
                roles.insert(.Teacher)
            case "observer":
                roles.insert(.Observer)
            case "ta":
                roles.insert(.TA)
            case "designer":
                roles.insert(.Designer)
            default:
                break
            }
        }
        self.roles = roles
    }
}
