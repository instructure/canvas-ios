//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

import Marshal


import ReactiveSwift

public struct EnrollmentRoles: OptionSet {
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

private let percentageFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.multiplier = 1.0
    formatter.maximumFractionDigits = 2
    formatter.locale = Locale.current
    return formatter
}()

public final class Course: Enrollment {

    @NSManaged internal (set) public var originalName: String?
    @NSManaged internal (set) public var code: String
    @NSManaged internal (set) public var startAt: Date?
    @NSManaged internal (set) public var endAt: Date?
    @NSManaged internal (set) public var hideFinalGrades: Bool
    @NSManaged internal (set) public var rawDefaultView: String
    @NSManaged internal (set) public var rawRoles: Int64
    @NSManaged internal (set) public var syllabusBody: String?
    @NSManaged internal (set) public var currentGradingPeriodID: String?
    @NSManaged internal (set) public var multipleGradingPeriodsEnabled: Bool // default: false
    @NSManaged internal (set) public var totalForAllGradingPeriodsEnabled: Bool // default: false

    @NSManaged internal (set) public var grades: Set<Grade>

    public override var hasGrades: Bool { return true }

    fileprivate var inMGPLimbo: Bool {
        return multipleGradingPeriodsEnabled && currentGradingPeriodID == nil
    }

    @objc public var gradesAreVisible: Bool {
        return !inMGPLimbo || totalForAllGradingPeriodsEnabled
    }

    @objc public var currentGrade: Grade? {
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

    @objc public func visibleGradingPeriodGrade(_ gradingPeriodID: String?) -> String? {
        return grades.filter { $0.gradingPeriodID == gradingPeriodID }.first?.currentGrade
    }

    @objc public func visibleGradingPeriodScore(_ gradingPeriodID: String?) -> String? {
        return grades.filter { $0.gradingPeriodID == gradingPeriodID }.first?.currentScore.flatMap {
            percentageFormatter.string(from: $0)
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
        return "\(contextID.pathComponent)/\(defaultView.pathComponent)"
    }

    public override var contextID: Context {
        return Context(.course, id: id)
    }
    
    public override var shortName: String {
        return code
    }

    public override func markAsFavorite(_ favorite: Bool, session: Session) -> SignalProducer<Void, NSError> {
        let path = "api/v1/users/self/favorites/courses/\(id)"
        let request = attemptProducer {
            favorite ? try session.POST(path) : try session.DELETE(path)
        }
        return super.markAsFavorite(favorite, session: session)
            .flatMap(.concat, { request })
            .flatMap(.concat, session.JSONSignalProducer)
            .map { _ in () }
            .on(failed: { [weak self] _ in
                self?.isFavorite = !favorite
                _ = try? self?.managedObjectContext?.saveFRD()
            })
            .observe(on: UIScheduler())
    }
}

extension Course: SynchronizedModel {
    @objc public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    @objc public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("id")
        name            = try json <| "name"
        originalName    = try json <| "original_name"
        code            = try json <| "course_code"
        isFavorite      = (try json <| "is_favorite") ?? false
        startAt         = try json <| "start_at"
        endAt           = try json <| "end_at"
        hideFinalGrades = try json <| "hide_final_grades"
        syllabusBody    = try json <| "syllabus_body"

        rawDefaultView  = (try json <| "default_view") ?? "assignments"

        let enrollmentsJSON: [JSONObject] = try json <| "enrollments"
        var roles: EnrollmentRoles = []
        for eJSON in enrollmentsJSON {
            let type: String = try eJSON <| "type"
            switch type {
            case "student":
                roles.insert(.Student)
                currentGradingPeriodID = try eJSON.stringID("current_grading_period_id")
                multipleGradingPeriodsEnabled = (try eJSON <| "multiple_grading_periods_enabled") ?? false
                let grade = currentGrade ?? Grade(inContext: context)
                grade.course = self
                grade.gradingPeriodID = currentGradingPeriodID

                if multipleGradingPeriodsEnabled {
                    totalForAllGradingPeriodsEnabled = (try eJSON <| "totals_for_all_grading_periods_option") ?? false
                }
                if multipleGradingPeriodsEnabled && currentGradingPeriodID != nil {
                    grade.currentGrade = try eJSON <| "current_period_computed_current_grade"
                    grade.currentScore = try eJSON <| "current_period_computed_current_score"
                    grade.finalGrade = try eJSON <| "current_period_computed_final_grade"
                    grade.finalScore = try eJSON <| "current_period_computed_final_score"
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
        
        if let tabs: [JSONObject] = (try json <| "tabs") {
            let contextID = Context.course(id)
            let request = NSFetchRequest<Tab>(entityName: "Tab")
            request.predicate = NSPredicate(format: "%K == %@", "rawContextID", contextID.canvasContextID)
            var currentTabs = try context.fetch(request)
            
            for tabJSON in tabs {
                let tabID: String = try tabJSON.stringID("id")
                let tab = currentTabs.filter({ $0.id == tabID }).first ?? Tab(inContext: context)
                try tab.updateValues(tabJSON, inContext: context)
                if let index = currentTabs.firstIndex(of: tab) {
                    currentTabs.remove(at: index)
                }
            }
            
            currentTabs.forEach { $0.delete(inContext: context) }
        }
    }
}
