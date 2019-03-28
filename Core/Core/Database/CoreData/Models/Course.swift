//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

final public class Course: NSManagedObject, Context, WriteableModel {
    public typealias JSON = APICourse
    public let contextType = ContextType.course

    @NSManaged public var courseCode: String?
    @NSManaged var defaultViewRaw: String?
    @NSManaged public var id: String
    @NSManaged public var imageDownloadURL: URL?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var enrollments: Set<Enrollment>?

    public var defaultView: CourseDefaultView? {
        get { return CourseDefaultView(rawValue: defaultViewRaw ?? "") }
        set { defaultViewRaw = newValue?.rawValue }
    }

    @discardableResult
    public static func save(_ item: APICourse, in context: PersistenceClient) throws -> Course {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Course.id), item.id)
        let model: Course = context.fetch(predicate).first ?? context.insert()
        model.id = item.id
        model.name = item.name
        model.isFavorite = item.is_favorite ?? false
        model.courseCode = item.course_code
        model.imageDownloadURL = item.image_download_url

        try model.enrollments?.forEach { try context.delete($0) }
        model.enrollments = nil

        if let apiEnrollments = item.enrollments {
            let enrollmentModels: [Enrollment] = try apiEnrollments.map { apiItem in
                let e: Enrollment = context.insert()
                try e.update(fromApiModel: apiItem, course: model, in: context)
                return e
            }
            model.enrollments = Set(enrollmentModels)
        }

        return model
    }
}

extension Course {
    public var color: UIColor {
        let request = NSFetchRequest<Color>(entityName: String(describing: Color.self))
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Color.canvasContextID), canvasContextID)
        let color = try? managedObjectContext?.fetch(request).first
        return color??.color ?? .named(.ash)
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

    public var widgetDisplayGrade: String {
        guard let enrollments = self.enrollments, let enrollment = enrollments.filter({ $0.role == .student }).first else {
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
            return "N/A"
        }

        guard let scoreNotNil = score, let scoreString = Course.scoreFormatter.string(from: NSNumber(value: scoreNotNil)) else {
                return grade ?? "N/A"
        }

        if let grade = grade {
            return "\(scoreString) - \(grade)"
        }

        return scoreString
    }
}

extension Course: Scoped {
    public enum ScopeKeys {
        case details(String)
        case all
        case favorites
    }

    public static func scope(forName name: ScopeKeys) -> Scope {
        switch name {
        case let .details(id):
            return .where(#keyPath(Course.id), equals: id)
        case .all:
            return .all(orderBy: #keyPath(Course.name))
        case .favorites:
            return .where(#keyPath(Course.isFavorite), equals: true, orderBy: #keyPath(Course.name))
        }
    }
}
