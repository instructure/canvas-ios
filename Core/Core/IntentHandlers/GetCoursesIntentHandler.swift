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

public class GetCoursesIntentHandler: NSObject, CanvasIntentHandler, GetCoursesIntentHandling {
    public func resolveEnrollmentTypeFilter(for intent: GetCoursesIntent, with completion: @escaping (EnrollmentTypeFilterResolutionResult) -> Void) {
        completion(EnrollmentTypeFilterResolutionResult.success(with: intent.enrollmentTypeFilter))
    }
    
    public func resolveEnrollmentStateFilter(for intent: GetCoursesIntent, with completion: @escaping (EnrollmentStateFilterResolutionResult) -> Void) {
        completion(EnrollmentStateFilterResolutionResult.success(with: intent.enrollmentStateFilter))
    }
    
    public func resolveCourseStateFilter(for intent: GetCoursesIntent, with completion: @escaping (CourseStateFilterResolutionResult) -> Void) {
        completion(CourseStateFilterResolutionResult.success(with: intent.courseStateFilter))
    }
    
    public func confirm(intent: GetCoursesIntent, completion: (GetCoursesIntentResponse) -> Void) {
        guard isLoggedIn else {
            completion(GetCoursesIntentResponse.init(code: .failureRequiringAppLaunch, userActivity: nil))
            return
        }

        completion(GetCoursesIntentResponse.init(code: .ready, userActivity: nil))
    }

    public func handle(intent: GetCoursesIntent, completion: @escaping (GetCoursesIntentResponse) -> Void) {
        setupLastLoginCredentials()

        let enrollmentStateFilter: GetCoursesRequest.EnrollmentState? = {
            switch intent.enrollmentStateFilter {
            case .active:
                return GetCoursesRequest.EnrollmentState.active
            case .completed:
                return GetCoursesRequest.EnrollmentState.completed
            case .invitedOrPending:
                return GetCoursesRequest.EnrollmentState.invited_or_pending
            default:
                return nil
            }
        }()

        let enrollmentTypeFilter: GetCoursesRequest.EnrollmentType? = {
            switch intent.enrollmentTypeFilter {
            case .student:
                return GetCoursesRequest.EnrollmentType.student
            case .teacher:
                return GetCoursesRequest.EnrollmentType.teacher
            case .observer:
                return GetCoursesRequest.EnrollmentType.observer
            case .ta:
                return GetCoursesRequest.EnrollmentType.ta
            case .designer:
                return GetCoursesRequest.EnrollmentType.designer
            default:
                return nil
            }
        }()
        
        let courseStateFilter: [GetCoursesRequest.State]? = {
            switch intent.courseStateFilter {
            case .available:
                return [GetCoursesRequest.State.available]
            case .completed:
                return [GetCoursesRequest.State.completed]
            case .currentAndConcluded:
                return [GetCoursesRequest.State.current_and_concluded]
            case .unpublished:
                return [GetCoursesRequest.State.unpublished]
            default:
                return nil
            }
        }()

        let request = GetCoursesRequest(enrollmentState: enrollmentStateFilter, enrollmentType: enrollmentTypeFilter, state: courseStateFilter, perPage: 100, studentID: LoginSession.mostRecent?.userID, include: [])

        env.api.makeRequest(request) { courses, response, error in
            guard error == nil && courses != nil else {
                completion(GetCoursesIntentResponse(code: .failure, userActivity: nil))
                return
            }

            let studentCourses = (courses ?? []).map { (course: APICourse) -> INCourse? in
                guard !(course.course_code ?? "").isEmpty || !(course.name ?? "").isEmpty else { return nil }

                let inCourse = INCourse(identifier: course.id.rawValue, display: [course.course_code, course.name].compactMap({$0}).joined(separator: " - "))
                inCourse.name = course.name
                inCourse.code = course.course_code
                inCourse.color = course.course_color
                return inCourse
            }.compactMap({$0})
            
            let response = GetCoursesIntentResponse(code: .success, userActivity: nil)
            response.courses = studentCourses

            completion(response)
        }
    }
}
