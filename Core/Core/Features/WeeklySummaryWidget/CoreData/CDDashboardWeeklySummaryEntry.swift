//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import CoreData

public final class CDDashboardWeeklySummaryEntry: NSManagedObject {

    public enum Category: String {
        case missing
        case due
        case newGrades
    }

    public enum SubmissionStatus: String {
        case graded
        case submitted
    }

    /// Sentinel `weekStart` value for `.missing` entries, which are not tied to any specific week.
    public static let missingWeekStart: Date = .distantPast

    /// The unique identifier for this entry. For sub-assignments this is the sub-assignment's own ID,
    /// which differs from the parent assignment ID stored in ``routeAssignmentId``.
    @NSManaged public var assignmentId: String

    public var isSubAssignment: Bool { routeAssignmentId != assignmentId }

    /// The assignment ID to use when building a navigation route. For regular assignments this equals
    /// ``assignmentId``. For sub-assignments the Canvas API only exposes routes for the parent
    /// assignment, so this holds the parent ID while ``assignmentId`` retains the sub-assignment's
    /// own ID as the CoreData identity key.
    @NSManaged public var routeAssignmentId: String
    @NSManaged public var weekStart: Date
    @NSManaged public var courseId: String
    @NSManaged public var title: String
    /// The due date for `.missing` and `.due` entries, or the graded-at date for `.newGrades` entries.
    @NSManaged public var date: Date?
    @NSManaged public var isQuizLti: Bool
    @NSManaged public var grade: String?
    @NSManaged public var excused: Bool
    @NSManaged public var gradingType: String?
    @NSManaged public var restrictQuantitativeData: Bool
    @NSManaged public var course: Course?

    @NSManaged fileprivate var categoryRaw: String
    public var category: Category? {
        get { Category(rawValue: categoryRaw) }
        set { categoryRaw = newValue?.rawValue ?? "" }
    }

    @NSManaged private var pointsPossibleRaw: NSNumber?
    public var pointsPossible: Double? {
        get { pointsPossibleRaw?.doubleValue }
        set { pointsPossibleRaw = newValue.map { NSNumber(value: $0) } }
    }

    @NSManaged private var gradeWeightRaw: NSNumber?
    public var gradeWeight: Double? {
        get { gradeWeightRaw?.doubleValue }
        set { gradeWeightRaw = newValue.map { NSNumber(value: $0) } }
    }

    @NSManaged private var scoreRaw: NSNumber?
    public var score: Double? {
        get { scoreRaw?.doubleValue }
        set { scoreRaw = newValue.map { NSNumber(value: $0) } }
    }

    @NSManaged public var submissionStatusRaw: String?
    public var submissionStatus: SubmissionStatus? {
        get { submissionStatusRaw.flatMap { SubmissionStatus(rawValue: $0) } }
        set { submissionStatusRaw = newValue?.rawValue }
    }

    @NSManaged private var submissionTypesRaw: String
    public var submissionTypes: [SubmissionType] {
        get {
            submissionTypesRaw
                .split(separator: ",")
                .compactMap { SubmissionType(rawValue: String($0)) }
        }
        set { submissionTypesRaw = newValue.map { $0.rawValue }.joined(separator: ",") }
    }

    // MARK: - Helpers

    public static func findOrCreate(
        weekStart: Date,
        category: Category,
        id: String,
        in context: NSManagedObjectContext
    ) -> CDDashboardWeeklySummaryEntry {
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(CDDashboardWeeklySummaryEntry.weekStart), weekStart as NSDate),
            NSPredicate(key: #keyPath(CDDashboardWeeklySummaryEntry.categoryRaw), equals: category.rawValue),
            NSPredicate(key: #keyPath(CDDashboardWeeklySummaryEntry.assignmentId), equals: id)
        ])
        let model: CDDashboardWeeklySummaryEntry = context.first(scope: Scope(predicate: predicate, order: [])) ?? context.insert()
        model.assignmentId = id
        return model
    }
}

extension Scope {
    public static func weeklySummaryEntries(weekStart: Date, category: CDDashboardWeeklySummaryEntry.Category) -> Scope {
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(CDDashboardWeeklySummaryEntry.weekStart), weekStart as NSDate),
            NSPredicate(key: #keyPath(CDDashboardWeeklySummaryEntry.categoryRaw), equals: category.rawValue)
        ])
        return Scope(
            predicate: predicate,
            order: [
                NSSortDescriptor(key: #keyPath(CDDashboardWeeklySummaryEntry.date), ascending: true),
                NSSortDescriptor(key: #keyPath(CDDashboardWeeklySummaryEntry.assignmentId), ascending: true)
            ]
        )
    }
}
