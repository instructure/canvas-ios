//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension DataSeeder {

    public func createCourse(name: String = "DataSeed iOS \(Int(Date().timeIntervalSince1970))",
                             syllabus_body: String? = nil) -> DSCourse {
        let requestedBody = CreateDSCourseRequest.Body(course: .init(name: name, syllabus_body: syllabus_body))
        let request = CreateDSCourseRequest(body: requestedBody)
        return makeRequest(request)
    }

    public func updateCourseWithGradingScheme(courseId: String, gradingStandardId: Int) {
        let requestedBody = UpdateDSCourseRequest.Body(course: .init(grading_standard_id: gradingStandardId))
        let request = UpdateDSCourseRequest(body: requestedBody, courseId: courseId)
        makeRequest(request)
    }
}
