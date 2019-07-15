//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

class QuizTests: CanvasUITests {
    func testQuizQuestionsOpenInNativeView() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.quizzes.tap()
        app.find(labelContaining: "Quiz One").tap()
        Quiz.resumeButton.tap()

        Quiz.text(string: "This is question A").waitToExist()
        Quiz.text(string: "True").waitToExist()

        Quiz.text(string: "This is question B").waitToExist()
        Quiz.text(string: "Answer B.1").waitToExist()

        app.swipeUp()

        Quiz.text(string: "This is question C").waitToExist()
        Quiz.text(string: "Answer 1.A").waitToExist()

        Quiz.text(string: "This is question D").waitToExist()
        XCTAssertEqual(XCUIElementWrapper(app.textFields.firstMatch).value, "42.000000")
    }
}
