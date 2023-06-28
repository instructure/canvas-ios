//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

    public func createQuiz(courseId: String, quizBody: CreateDSQuizRequest.RequestedDSQuiz) throws -> DSQuiz {
        let requestedBody = CreateDSQuizRequest.Body(quiz: quizBody)
        let request = CreateDSQuizRequest(body: requestedBody, courseId: courseId)
        return try makeRequest(request)
    }

    public func getQuiz(courseId: String, quizId: String) throws -> DSQuiz {
        let request = GetDSQuizRequest(courseId: courseId, quizId: quizId)
        return try makeRequest(request)
    }
}
