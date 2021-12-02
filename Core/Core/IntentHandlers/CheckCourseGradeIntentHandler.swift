//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import Intents
import Fuse

extension INCourse: Fuseable {
    public var properties: [FuseProperty] {
        [FuseProperty(name: name ?? ""), FuseProperty(name: code ?? "")]
    }
}

public class CheckCourseGradeIntentHandler: NSObject, CanvasIntentHandler, CheckCourseGradeIntentHandling {
    public func resolveCourse(for intent: CheckCourseGradeIntent, with completion: @escaping (INCourseResolutionResult) -> Void) {
        guard let studentCourse = intent.course else {
            completion(.needsValue())
            return
        }
        completion(.success(with: studentCourse))
    }

    @available(iOSApplicationExtension, introduced: 13.0, deprecated: 14.0, message: "")
    public func provideCourseOptions(for intent: CheckCourseGradeIntent, with completion: @escaping ([INCourse]?, Error?) -> Void) {
        guard isLoggedIn else {
            completion(nil, INIntentError(_nsError: NSError.instructureError("Please log in via the application")))
            return
        }

        setupLastLoginCredentials()

        let request = GetCoursesRequest(enrollmentState: .active, enrollmentType: .student, state: [.current_and_concluded], perPage: 20, studentID: LoginSession.mostRecent?.userID, includes: [])

        env.api.makeRequest(request) { courses, _, error in
            guard let courses = courses, error == nil else { return }

            completion(courses.map {INCourse($0)}.compactMap({$0}), nil)
            return
        }
    }

    @available(iOSApplicationExtension 14.0, *)
    public func provideCourseOptionsCollection(for intent: CheckCourseGradeIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<INCourse>?, Error?) -> Void) {
        guard isLoggedIn else {
            completion(nil, INIntentError(_nsError: NSError.instructureError("Please log in via the application")))
            return
        }

        setupLastLoginCredentials()

        let request = GetCoursesRequest(enrollmentState: .active, enrollmentType: .student, state: [.current_and_concluded], perPage: 20, studentID: LoginSession.mostRecent?.userID, includes: [])

        env.api.makeRequest(request) { courses, _, error in
            guard let courses = courses else { return }
            guard error == nil else { return }

            let studentCourses = courses.map {INCourse($0)}.compactMap({$0})

            let search = searchTerm ?? ""

            guard !search.isEmpty else {
                completion(INObjectCollection(items: studentCourses), nil)
                return
            }

            let fuse = Fuse()
            completion(INObjectCollection(items: fuse.search(search, in: studentCourses).map { index, _, _ in
                studentCourses[index]
            }), nil)
            return
        }
    }

    public func confirm(intent: CheckCourseGradeIntent, completion: @escaping (CheckCourseGradeIntentResponse) -> Void) {
        guard isLoggedIn else {
            completion(CheckCourseGradeIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil))
            return
        }
        completion(CheckCourseGradeIntentResponse(code: .ready, userActivity: nil))
    }

    public func handle(intent: CheckCourseGradeIntent, completion: @escaping (CheckCourseGradeIntentResponse) -> Void) {
        guard let courseID = intent.course?.identifier else { return }

        setupLastLoginCredentials()

        let request = GetCourseRequest(courseID: courseID, include: [.currentGradingPeriodScores, .totalScores])

        env.api.makeRequest(request) { course, response, error in
            guard let course = course else { return }
            guard error == nil else { return }

            let (scoreValue, grade, scoreString) = CheckCourseGradeIntentHandler.displayGrade(course, studentID: LoginSession.mostRecent?.userID ?? "")
            let userActivity = NSUserActivity(activityType: "CheckCourseGradeIntent")
            userActivity.addUserInfoEntries(from: ["url": "/courses/\(course.id.rawValue)/grades"])

            guard scoreValue != nil || grade != nil || scoreString != nil else {
                completion(CheckCourseGradeIntentResponse(code: .noGrade, userActivity: userActivity))
                return
            }
            let response = CheckCourseGradeIntentResponse(code: .success, userActivity: userActivity)
            response.gradePercentage = scoreValue
            response.gradeDescription = grade
            response.formattedGradePercentage = scoreString
            response.combinedGradeOutput = "\(scoreString ?? "")\(grade != nil ? " (\(grade ?? ""))" : "")"
            completion(response)
        }
    }

    private static func displayGrade(_ course: APICourse?, studentID: String) -> (NSNumber?, String?, String?) {
        guard let enrollment = course?.enrollments?.first(where: { $0.user_id.rawValue == studentID && $0.type.lowercased().contains("student") }) else {
            return (nil, nil, nil)
        }

        var grade = enrollment.computed_current_grade
        var score = enrollment.computed_current_score

        if enrollment.multiple_grading_periods_enabled ?? false && enrollment.current_grading_period_id != nil {
            grade = enrollment.current_period_computed_current_grade
            score = enrollment.current_period_computed_current_score
        } else if enrollment.multiple_grading_periods_enabled ?? false && enrollment.totals_for_all_grading_periods_option ?? false {
            grade = enrollment.computed_final_grade
            score = enrollment.computed_final_score
        } else if enrollment.multiple_grading_periods_enabled ?? false && enrollment.totals_for_all_grading_periods_option == false {
            return (nil, nil, NSLocalizedString("N/A", comment: ""))
        }

        guard let scoreValue = score == nil ? nil : NSNumber(value: score), let scoreString = Course.scoreFormatter.string(from: scoreValue) else {
            return (nil, grade, nil)
        }

        if let grade = grade {
            return (scoreValue, grade, scoreString)
        }
        return (scoreValue, nil, scoreString)
    }
}
