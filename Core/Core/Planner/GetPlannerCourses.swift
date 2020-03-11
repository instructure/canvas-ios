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
            orderBy: #keyPath(Course.courseCode),
            ascending: true,
            naturally: true
        )
    }

    var request: GetCoursesRequest {
        GetCoursesRequest(enrollmentState: .active, state: [.available], include: [.observed_users], perPage: 100, studentID: studentID)
    }

    init(studentID: String?) {
        self.studentID = studentID
    }

    func reset(context: NSManagedObjectContext) {
        if let planner: Planner = context.first(where: #keyPath(Planner.studentID), equals: studentID) {
            planner.courses = []
        }
    }

    func write(response: [APICourse]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        let planner: Planner = client.first(where: #keyPath(Planner.studentID), equals: studentID) ?? client.insert()
        planner.studentID = studentID
        for apiCourse in response {
            let course = Course.save(apiCourse, in: client)
            planner.courses.insert(course)
        }
    }
}
