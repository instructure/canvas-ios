//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

/**
 This use case fetches and returns active courses for a given user. While saving this also updates the Planner entity for the given `studentID`
 to make sure it contains an up-to-date list of available course IDs. Use courses from this UseCase along with the `Planner` entity to determine which
 courses should show up in the calendar's course filter.
 */
class GetPlannerCourses: APIUseCase {
    typealias Model = Course

    let studentID: String?

    var cacheKey: String? { "planner/\(studentID ?? "self")/courses" }

    var scope: Scope {
        let enrollmentPredicate = NSPredicate(format: "ANY %K == %@", #keyPath(Course.enrollments.stateRaw), EnrollmentState.active.rawValue)
        return Scope(predicate: enrollmentPredicate,
                     orderBy: #keyPath(Course.name),
                     ascending: true,
                     naturally: true)
    }

    init(studentID: String?) {
        self.studentID = studentID
    }

    func reset(context: NSManagedObjectContext) {
        if let planner: Planner = context.first(where: #keyPath(Planner.studentID), equals: studentID) {
            planner.availableCourseIDs = []
        }
    }

    var request: GetCoursesRequest {
        GetCoursesRequest(
            enrollmentState: .active,
            state: [.available],
            perPage: 100,
            studentID: studentID
        )
    }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping ([APICourse]?, URLResponse?, Error?) -> Void) {
        if environment.app == .parent {
            getObserverCourses(env: environment, callback: completionHandler)
            return
        }
        environment.api.makeRequest(request, callback: completionHandler)
    }

    func write(response: [APICourse]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let courses = response else { return }
        let planner: Planner = client.first(where: #keyPath(Planner.studentID), equals: studentID) ?? client.insert()
        planner.studentID = studentID

        for apiCourse in courses {
            let course = Course.save(apiCourse, in: client)
            planner.availableCourseIDs.append(course.id)
        }
    }

    func getNext(from response: URLResponse) -> GetNextRequest<[APICourse]>? {
        if AppEnvironment.shared.app == .parent {
            return nil // Parent app exhausts
        }
        return request.getNext(from: response)
    }

    func getObserverCourses(env: AppEnvironment, callback: @escaping ([APICourse]?, URLResponse?, Error?) -> Void) {
        let request = GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .observer,
            state: [.available],
            perPage: 100,
            studentID: nil
        )
        env.api.exhaust(request) { [studentID] response, urlResponse, error in
            guard let courses = response, error == nil else {
                callback(response, urlResponse, error)
                return
            }
            let result = courses.filter { course in
                return course.enrollments?.contains { $0.associated_user_id?.value == studentID } == true
            }
            callback(result, urlResponse, error)
        }
    }
}
