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

import CoreData

public class GetConversationCourses: APIUseCase {
    public init() {}
    public typealias Response = [APIEnrollment]
    public typealias Model = Enrollment

    public var cacheKey: String? = "get-conversation-courses"
    public var request: GetEnrollmentsRequest {
        return GetEnrollmentsRequest(context: ContextModel.currentUser, userID: nil, gradingPeriodID: nil, types: ["ObserverEnrollment"], includes: [.observed_users])
    }

    public var scope: Scope {
        return Scope(
            predicate: NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(Enrollment.type), "ObserverEnrollment", #keyPath(Enrollment.stateRaw), "active"),
            order: [
                NSSortDescriptor(key: #keyPath(Enrollment.observedUser.name), ascending: true),
                NSSortDescriptor(key: #keyPath(Enrollment.course.name), ascending: true),
            ]
        )
    }

    public var fetchedCourses: [APICourse]?
    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping ([APIEnrollment]?, URLResponse?, Error?) -> Void) {
        environment.api.exhaust(request) { (apiEnrollments, response, error) in
            guard let enrollments = apiEnrollments, error == nil else {
                completionHandler(apiEnrollments, response, error)
                return
            }

            let coursesRequestable = GetCoursesRequest(enrollmentState: .active, state: nil, perPage: 99)
            environment.api.exhaust(coursesRequestable) { [weak self] (apiCourses, response, error) in
                if error != nil {
                    completionHandler(enrollments, response, error)
                    return
                }

                self?.fetchedCourses = apiCourses
                completionHandler(enrollments, response, error)
            }
        }
    }

    public func write(response: [APIEnrollment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let enrollments = response, let courses = fetchedCourses else {
            return
        }

        for enrollment in enrollments {
            guard let course = courses.first(where: { $0.id.value == enrollment.course_id }), let enrollmentID = enrollment.id?.value else {
                continue
            }
            let courseModel = Course.save(course, in: client)
            let enrollmentModel: Enrollment = client.first(where: #keyPath(Enrollment.id), equals: enrollmentID) ?? client.insert()
            enrollmentModel.update(fromApiModel: enrollment, course: courseModel, in: client)
        }
    }
}
