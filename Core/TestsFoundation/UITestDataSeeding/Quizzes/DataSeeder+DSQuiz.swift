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

    public func createQuiz(courseId: String, quizBody: CreateDSQuizRequest.RequestedDSQuiz) -> DSQuiz {
        let requestedBody = CreateDSQuizRequest.Body(quiz: quizBody)
        let request = CreateDSQuizRequest(body: requestedBody, courseId: courseId)
        return makeRequest(request)
    }

    public func getQuiz(courseId: String, quizId: String) -> DSQuiz {
        let request = GetDSQuizRequest(courseId: courseId, quizId: quizId)
        return makeRequest(request)
    }

    public func updateQuiz(courseId: String, quizId: String, published: Bool) -> DSQuiz {
        let requestedBody = UpdateDSQuizRequest.Body(quiz: .init(published: published))
        let request = UpdateDSQuizRequest(body: requestedBody, courseId: courseId, quizId: quizId)
        return makeRequest(request)
    }
}
