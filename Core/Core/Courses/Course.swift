//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

final public class Course: NSManagedObject, WriteableModel {
    public typealias JSON = APICourse

    @NSManaged public var courseCode: String?
    @NSManaged var defaultViewRaw: String?
    @NSManaged public var id: String
    @NSManaged public var imageDownloadURL: URL?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var enrollments: Set<Enrollment>?
    @NSManaged public var syllabusBody: String?
    @NSManaged public var grades: Set<Grade>?
    @NSManaged public var hideFinalGrades: Bool
    @NSManaged var planner: Planner?
    @NSManaged public var isPastEnrollment: Bool

    public var defaultView: CourseDefaultView? {
        get { return CourseDefaultView(rawValue: defaultViewRaw ?? "") }
        set { defaultViewRaw = newValue?.rawValue }
    }

    public var canvasContextID: String {
        Context(.course, id: id).canvasContextID
    }

    @discardableResult
    public static func save(_ item: APICourse, in context: NSManagedObjectContext) -> Course {
        let model: Course = context.first(where: #keyPath(Course.id), equals: item.id.value) ?? context.insert()
        model.id = item.id.value
        model.name = item.name
        model.isFavorite = item.is_favorite ?? false
        model.courseCode = item.course_code
        model.imageDownloadURL = URL(string: item.image_download_url ?? "")
        model.syllabusBody = item.syllabus_body
        model.defaultViewRaw = item.default_view?.rawValue
        model.enrollments?.forEach { enrollment in
            // we only want to delete dangling enrollments created from
            // the minimal enrollments attached to an APICourse
            if enrollment.id == nil {
                context.delete(enrollment)
            }
        }
        model.enrollments = nil
        model.hideFinalGrades = item.hide_final_grades ?? false
        model.isPastEnrollment = (
            item.workflow_state == .completed ||
            (item.end_at ?? .distantFuture) < Clock.now ||
            (item.term?.end_at ?? .distantFuture) < Clock.now
        )

        if let apiEnrollments = item.enrollments {
            let enrollmentModels: [Enrollment] = apiEnrollments.map { apiItem in
                let e: Enrollment = context.insert()
                e.update(fromApiModel: apiItem, course: model, in: context)
                return e
            }
            model.enrollments = Set(enrollmentModels)
        }

        return model
    }
}

extension Course {
    public var color: UIColor {
        let request = NSFetchRequest<ContextColor>(entityName: String(describing: ContextColor.self))
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(ContextColor.canvasContextID), canvasContextID)
        let color = try? managedObjectContext?.fetch(request).first
        return color?.color ?? .named(.ash)
    }

    static let scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.decimalSeparator = "."
        formatter.multiplier = 1
        formatter.maximumFractionDigits = 3
        formatter.roundingMode = .down
        return formatter
    }()

    public var displayGrade: String {
        guard let enrollments = self.enrollments, let enrollment = enrollments.filter({ $0.isStudent }).first else {
            return ""
        }

        var grade = enrollment.computedCurrentGrade
        var score = enrollment.computedCurrentScore

        if enrollment.multipleGradingPeriodsEnabled && enrollment.currentGradingPeriodID != nil {
            grade = enrollment.currentPeriodComputedCurrentGrade
            score = enrollment.currentPeriodComputedCurrentScore
        } else if enrollment.multipleGradingPeriodsEnabled && enrollment.totalsForAllGradingPeriodsOption {
            grade = enrollment.computedFinalGrade
            score = enrollment.computedFinalScore
        } else if enrollment.multipleGradingPeriodsEnabled && enrollment.totalsForAllGradingPeriodsOption == false {
            return NSLocalizedString("N/A", bundle: .core, comment: "")
        }

        guard let scoreNotNil = score, let scoreString = Course.scoreFormatter.string(from: NSNumber(value: scoreNotNil)) else {
            return grade ?? NSLocalizedString("N/A", bundle: .core, comment: "")
        }

        if let grade = grade {
            return "\(scoreString) - \(grade)"
        }

        return scoreString
    }

    public func showColorOverlay(hideOverlaySetting: Bool) -> Bool {
        if imageDownloadURL == nil {
            return true
        }
        return !hideOverlaySetting
    }

    public var hasStudentEnrollment: Bool {
        return enrollments?.first { $0.isStudent } != nil
    }
}
