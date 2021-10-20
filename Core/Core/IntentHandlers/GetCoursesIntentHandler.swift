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
        completion(.success(with: intent.enrollmentTypeFilter))
    }

    public func resolveEnrollmentStateFilter(for intent: GetCoursesIntent, with completion: @escaping (EnrollmentStateFilterResolutionResult) -> Void) {
        completion(.success(with: intent.enrollmentStateFilter))
    }

    public func resolveCourseStateFilter(for intent: GetCoursesIntent, with completion: @escaping (CourseStateFilterResolutionResult) -> Void) {
        completion(.success(with: intent.courseStateFilter))
    }

    public func confirm(intent: GetCoursesIntent, completion: (GetCoursesIntentResponse) -> Void) {
        guard isLoggedIn else {
            completion(GetCoursesIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil))
            return
        }

        completion(GetCoursesIntentResponse(code: .ready, userActivity: nil))
    }

    public func handle(intent: GetCoursesIntent, completion: @escaping (GetCoursesIntentResponse) -> Void) {
        setupLastLoginCredentials()

        let enrollmentStateFilter: GetCoursesRequest.EnrollmentState? = {
            switch intent.enrollmentStateFilter {
            case .active: return .active
            case .completed: return .completed
            case .invitedOrPending: return .invited_or_pending
            default: return nil
            }
        }()

        let enrollmentTypeFilter: GetCoursesRequest.EnrollmentType? = {
            switch intent.enrollmentTypeFilter {
            case .student: return .student
            case .teacher: return .teacher
            case .observer: return .observer
            case .ta: return .ta
            case .designer: return .designer
            default: return nil
            }
        }()

        let courseStateFilter: [GetCoursesRequest.State]? = {
            switch intent.courseStateFilter {
            case .available: return [.available]
            case .completed: return [.completed]
            case .currentAndConcluded: return [.current_and_concluded]
            case .unpublished: return [.unpublished]
            default: return nil
            }
        }()

        let request = GetCoursesRequest(enrollmentState: enrollmentStateFilter,
                                        enrollmentType: enrollmentTypeFilter,
                                        state: courseStateFilter,
                                        perPage: 100,
                                        studentID: LoginSession.mostRecent?.userID,
                                        includes: [])

        env.api.makeRequest(request) { courses, response, error in
            guard error == nil && courses != nil else {
                completion(GetCoursesIntentResponse(code: .failure, userActivity: nil))
                return
            }

            let response = GetCoursesIntentResponse(code: .success, userActivity: nil)
            response.courses = (courses ?? []).map({INCourse($0)}).compactMap({$0})

            completion(response)
        }
    }
}
