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

import XCTest
import TestsFoundation

class QuizzesTests: E2ETestCase {
    func testQuizzes() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let quiz = QuizzesHelper.createQuiz(course: course,
                                            title: "Test Quiz",
                                            description: "Description of Test Quiz",
                                            quiz_type: .practiceQuiz)
        QuizzesHelper.createTestQuizQuestion(course: course, quiz: quiz)
        // MARK: Get the user logged in
        logInDSUser(student)
        print("I don't want this")
    }
}
