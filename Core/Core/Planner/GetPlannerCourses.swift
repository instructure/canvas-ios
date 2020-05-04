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

class GetPlannerCourses: APIUseCase {
    typealias Model = Course

    let studentID: String?

    var cacheKey: String? {
        let studentKey = studentID ?? "self"
        return "planner/\(studentKey)/courses"
    }

    var scope: Scope {
        .where(
            #keyPath(Course.planner.studentID),
            equals: studentID,
            orderBy: #keyPath(Course.name),
            ascending: true,
            naturally: true
        )
    }

    init(studentID: String?) {
        self.studentID = studentID
    }

    func reset(context: NSManagedObjectContext) {
        if let planner: Planner = context.first(where: #keyPath(Planner.studentID), equals: studentID) {
            planner.courses = []
        }
    }

    var request: GetCoursesRequest {
        GetCoursesRequest(
            enrollmentState: .active,
            state: [.available],
            include: [.observed_users],
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
            planner.courses.insert(course)
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
            include: [],
            perPage: 100,
            studentID: nil
        )
        env.api.exhaust(request) { [studentID] response, urlResponse, error in
            guard let courses = response, error == nil else {
                callback(response, urlResponse, error)
                return
            }
            let result = courses.filter { course in
                return course.enrollments?.contains { $0.associated_user_id == studentID } == true
            }
            callback(result, urlResponse, error)
        }
    }
}
