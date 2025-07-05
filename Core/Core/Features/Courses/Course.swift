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

import CoreData
import UIKit

final public class Course: NSManagedObject, WriteableModel {
    public typealias JSON = APICourse

    @NSManaged public var accessRestrictedByDate: Bool
    @NSManaged public var bannerImageDownloadURL: URL?
    @NSManaged public var canCreateAnnouncement: Bool
    @NSManaged public var canCreateDiscussionTopic: Bool
    @NSManaged var contextColor: ContextColor?
    @NSManaged public var courseCode: String?
    /** Teacher assigned course color for K5 in hex format. */
    @NSManaged public var courseColor: String?
    @NSManaged var defaultViewRaw: String?
    @NSManaged public var enrollments: Set<Enrollment>?
    @NSManaged public var gradingStandardId: String?
    @NSManaged public var grades: Set<Grade>?
    @NSManaged public var gradingPeriods: Set<GradingPeriod>?
    @NSManaged public var hideFinalGrades: Bool
    @NSManaged public var id: String
    @NSManaged public var imageDownloadURL: URL?
    @NSManaged public var isCourseDeleted: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isHomeroomCourse: Bool
    /** Use with caution! This property doesn't take section dates or the actual enrollment's concluded state into account. */
    @NSManaged public var isPastEnrollment: Bool
    @NSManaged public var isPublished: Bool
    @NSManaged public var name: String?
    @NSManaged public var sections: Set<CourseSection>
    @NSManaged public var syllabusBody: String?
    @NSManaged public var termName: String?
    @NSManaged public var settings: CourseSettings?
    @NSManaged public var gradingSchemeRaw: NSOrderedSet?
    @NSManaged public var roles: String?

    @NSManaged public var scalingFactor: Double
    @NSManaged public var pointsBasedGradingScheme: Bool

    public var gradingSchemeEntries: [GradingSchemeEntry] {
        get { gradingSchemeRaw?.array as? [GradingSchemeEntry] ?? [] }
        set { gradingSchemeRaw = NSOrderedSet(array: newValue) }
    }

    public var gradingScheme: GradingScheme {
        if pointsBasedGradingScheme {
            PointsBasedGradingScheme(
                scaleFactor: scalingFactor,
                entries: gradingSchemeEntries
            )
        } else {
            PercentageBasedGradingScheme(entries: gradingSchemeEntries)
        }
    }

    public var defaultView: CourseDefaultView? {
        get { return CourseDefaultView(rawValue: defaultViewRaw ?? "") }
        set { defaultViewRaw = newValue?.rawValue }
    }

    public var canvasContextID: String {
        Context(.course, id: id).canvasContextID
    }

    public var color: UIColor {
        if AppEnvironment.shared.k5.isK5Enabled {
            return UIColor(hexString: courseColor)?.ensureContrast(against: .backgroundLightest) ?? .textDarkest
        } else {
            return contextColor?.color ?? .textDark
        }
    }

    @discardableResult
    public static func save(_ item: APICourse, in context: NSManagedObjectContext) -> Course {
        let model: Course = context.first(where: #keyPath(Course.id), equals: item.id.value) ?? context.insert()
        model.id = item.id.value
        model.name = item.name
        model.isFavorite = item.is_favorite ?? false
        model.courseCode = item.course_code
        model.courseColor = item.course_color
        model.bannerImageDownloadURL = URL(string: item.banner_image_download_url ?? "")
        model.imageDownloadURL = URL(string: item.image_download_url ?? "")
        model.syllabusBody = item.syllabus_body
        model.defaultViewRaw = item.default_view?.rawValue
        model.enrollments?.forEach { enrollment in
            // We only want to delete enrollments created from
            // the minimal enrollments attached to an APICourse
            if enrollment.id == nil {
                context.delete(enrollment)
            }
        }
        model.enrollments = nil
        if let apiGradingPeriods = item.grading_periods {
            let gradingPeriods: [GradingPeriod] = apiGradingPeriods.map { apiGradingPeriod in
                let gp: GradingPeriod = GradingPeriod.save(apiGradingPeriod, courseID: model.id, in: context)
                return gp
            }
            model.gradingPeriods = Set(gradingPeriods)
        }

        model.gradingStandardId = item.grading_standard_id?.value
        model.scalingFactor = item.scaling_factor ?? 0
        model.pointsBasedGradingScheme = item.points_based_grading_scheme ?? false

        model.hideFinalGrades = item.hide_final_grades ?? false
        model.isCourseDeleted = item.workflow_state == .deleted
        model.isPastEnrollment = (
            item.workflow_state == .completed ||
            (item.end_at ?? .distantFuture) < Clock.now ||
            (item.term?.end_at ?? .distantFuture) < Clock.now
        )
        model.isHomeroomCourse = item.homeroom_course ?? false
        model.isPublished = item.workflow_state == .available || item.workflow_state == .completed
        model.termName = item.term?.name
        model.accessRestrictedByDate = item.access_restricted_by_date ?? false

        if let apiEnrollments = item.enrollments {
            let enrollmentModels: [Enrollment] = apiEnrollments.map { apiItem in
                /// This enrollment contains the grade fields necessary to calculate grades on the dashboard.
                /// This is a special enrollment that has no courseID nor enrollmentID and contains no Grade objects.
                let e: Enrollment = context.insert()
                e.update(fromApiModel: apiItem, course: model, in: context)
                return e
            }
            model.enrollments = Set(enrollmentModels)
        }

        if let contextColor: ContextColor = context.fetch(scope: .where(#keyPath(ContextColor.canvasContextID), equals: model.canvasContextID)).first {
            model.contextColor = contextColor
        }

        if let permissions = item.permissions {
            model.canCreateAnnouncement = permissions.create_announcement
            model.canCreateDiscussionTopic = permissions.create_discussion_topic
        }

        if let sections = item.sections {
            model.sections = Set(sections.map { CourseSection.save($0, courseID: model.id, in: context) })
        }

        if let dashboardCard: DashboardCard = context.fetch(scope: .where(#keyPath(DashboardCard.id), equals: model.id)).first {
            dashboardCard.course = model
        }

        for group: Group in context.fetch(scope: .where(#keyPath(Group.courseID), equals: model.id)) {
            group.course = model
        }

        if let apiSettings = item.settings {
            CourseSettings.save(apiSettings, courseID: item.id.value, in: context)
        } else if let settings: CourseSettings = context.fetch(scope: .where(#keyPath(CourseSettings.courseID), equals: model.id)).first {
            model.settings = settings
        }

        if let gradingScheme = item.grading_scheme {
            model.gradingSchemeEntries = gradingScheme.compactMap {
                guard let apiEntry = APIGradingSchemeEntry(courseGradingScheme: $0) else {
                    return nil
                }
                return GradingSchemeEntry.save(apiEntry, in: context)
            }
        }

        model.roles = item.enrollments.roles

        if let apiTabs = item.tabs {
            let courseContext = Context.course(item.id.value)

            let contextPredicate = NSPredicate(
                format: "%K == %@", #keyPath(Tab.contextRaw),
                courseContext.canvasContextID
            )

            context.delete(context.fetch(contextPredicate) as [Tab])

            // not adding tabs to Course, just saving them
            apiTabs.forEach { apiTab in
                let tab: Tab = context.insert()
                tab.save(apiTab, in: context, context: courseContext)
            }
        }

        return model
    }
}

extension Course {

    public var displayGrade: String {
        /// We want to use the special enrollment that was downloaded along the course because that contains the
        /// computedCurrentGrade, currentPeriodComputedCurrentGrade etc. values. It has no enrollment id so it's easy to identify it.
        guard let enrollment = enrollments?.filter({ $0.isStudent && $0.id == nil }).first else {
            return ""
        }

        var grade = enrollment.computedCurrentGrade
        var score = enrollment.computedCurrentScore

        if enrollment.multipleGradingPeriodsEnabled && enrollment.currentGradingPeriodID != nil {
            grade = enrollment.currentPeriodComputedCurrentGrade
            score = enrollment.currentPeriodComputedCurrentScore
        } else if enrollment.multipleGradingPeriodsEnabled && enrollment.totalsForAllGradingPeriodsOption {
            grade = enrollment.computedCurrentGrade
            score = enrollment.computedCurrentScore
        } else if enrollment.multipleGradingPeriodsEnabled && enrollment.totalsForAllGradingPeriodsOption == false {
            return String(localized: "N/A", bundle: .core)
        }

        if hideQuantitativeData == true {
            return grade ?? enrollment.computedCurrentLetterGrade ?? String(localized: "N/A", bundle: .core)
        }

        guard let scoreNotNil = score,
              let scoreString = gradingScheme.formattedScore(from: scoreNotNil) else {
            return grade ?? String(localized: "N/A", bundle: .core)
        }

        if let grade = grade {
            return "\(scoreString) - \(grade)"
        }

        return scoreString
    }

    public var gradeForWidget: String {
        /// We want to use the special enrollment that was downloaded along the course because that contains the
        /// computedCurrentGrade, currentPeriodComputedCurrentGrade etc. values. It has no enrollment id so it's easy to identify it.
        let noGradesString = String(localized: "No Grades", bundle: .core)

        guard let enrollment = enrollments?.first(where: { $0.isStudent && $0.id == nil }) else {
            return noGradesString
        }

        var grade = enrollment.computedCurrentGrade
        var score = enrollment.computedCurrentScore

        if enrollment.multipleGradingPeriodsEnabled {
            if enrollment.currentGradingPeriodID != nil {
                grade = enrollment.currentPeriodComputedCurrentGrade
                score = enrollment.currentPeriodComputedCurrentScore
            } else if enrollment.totalsForAllGradingPeriodsOption {
                grade = enrollment.computedCurrentGrade
                score = enrollment.computedCurrentScore
            } else if enrollment.totalsForAllGradingPeriodsOption == false {
                return noGradesString
            }
        }

        if hideQuantitativeData == true {
            return grade ?? enrollment.computedCurrentLetterGrade ?? noGradesString
        }

        guard let scoreString = score.flatMap(gradingScheme.formattedScore) else {
            return grade ?? noGradesString
        }

        if let grade {
            return "\(scoreString) - \(grade)"
        }

        return scoreString
    }

    public var hideQuantitativeData: Bool {
        return settings?.restrictQuantitativeData ?? false
    }

    public var hideTotalGrade: Bool {
        let enrollment = enrollments?.filter({ $0.isStudent }).first
        return hideFinalGrades == true || (
            enrollment?.multipleGradingPeriodsEnabled == true &&
            enrollment?.totalsForAllGradingPeriodsOption == false &&
            enrollment?.currentGradingPeriodID == nil
        )
    }

    public func showColorOverlay(hideOverlaySetting: Bool) -> Bool {
        if imageDownloadURL == nil {
            return true
        }
        return !hideOverlaySetting
    }

    public var hasStudentEnrollment: Bool {
        return enrollments?.contains { $0.isStudent } == true
    }

    public var hasTeacherEnrollment: Bool {
        return enrollments?.contains { $0.isTeacher } == true
    }

    public func enrollmentForGrades(userId: String?, includingCompleted: Bool = false) -> Enrollment? {
        func first(of state: EnrollmentState) -> Enrollment? {
            enrollments?.first {
                $0.state == state &&
                $0.userID == userId &&
                $0.type.lowercased().contains("student") &&
                $0.id == nil
            }
        }

        if let enrollment = first(of: .active) {
            return enrollment
        } else if includingCompleted {
            return first(of: .completed)
        } else {
            return nil
        }
    }
}

final public class CourseSettings: NSManagedObject {
    @NSManaged public var courseID: String
    @NSManaged public var syllabusCourseSummary: Bool
    @NSManaged public var usageRightsRequired: Bool
    @NSManaged public var restrictQuantitativeData: Bool
    @NSManaged public var course: Course?

    @discardableResult
    static func save(_ item: APICourseSettings, courseID: String, in context: NSManagedObjectContext) -> CourseSettings {
        let model: CourseSettings = {
            if let settings: CourseSettings = context.first(where: #keyPath(CourseSettings.courseID), equals: courseID) {
                return settings
            }

            let settings: CourseSettings = context.insert()
            settings.courseID = courseID
            settings.syllabusCourseSummary = false
            settings.usageRightsRequired = false
            settings.restrictQuantitativeData = false
            return settings
        }()

        if let syllabus_course_summary = item.syllabus_course_summary {
            model.syllabusCourseSummary = syllabus_course_summary
        }

        if let usage_rights_required = item.usage_rights_required {
            model.usageRightsRequired = usage_rights_required
        }

        if let restrict_quantitative_data = item.restrict_quantitative_data, AppEnvironment.shared.app != .teacher {
            model.restrictQuantitativeData = restrict_quantitative_data
        }

        if let course: Course = context.fetch(scope: .where(#keyPath(Course.id), equals: courseID)).first,
           course.settings == nil {
            course.settings = model
        }

        return model
    }
}
