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

    public func postGrade(courseId: String, assignmentId: String, userId: String, requestBody: CreateDSGradesRequest.RequestDSGrades) {
        let requestedBody = CreateDSGradesRequest.Body(submission: requestBody)
        let request = CreateDSGradesRequest(body: requestedBody, courseId: courseId, assignmentId: assignmentId, userId: userId)
        try! makeRequest(request)
    }
}
