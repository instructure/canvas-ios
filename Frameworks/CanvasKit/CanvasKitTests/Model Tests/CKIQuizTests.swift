//
// Copyright (C) 2016-present Instructure, Inc.
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

import UIKit
import XCTest

class CKIQuizTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJSONModelConversion() {
        let quizDictionary = Helpers.loadJSONFixture("quiz") as NSDictionary
        let quiz = CKIQuiz(fromJSONDictionary: quizDictionary)
        
        XCTAssertEqual(quiz.id!, "5", "Quiz id was not parsed correctly")
        XCTAssertEqual(quiz.title!, "Hamlet Act 3 Quiz", "Quiz title was not parsed correctly")
        XCTAssertEqual(quiz.htmlURL!, NSURL(string: "http://canvas.example.edu/courses/1/quizzes/2")!, "Quiz html url was not parsed correctly")
        XCTAssertEqual(quiz.mobileURL!, NSURL(string: "http://canvas.example.edu/courses/1/quizzes/2?persist_healdess=1&force_user=1")!, "Quiz mobile url was not parsed correctly")
        XCTAssertEqual(quiz.description, "This is a quiz on Act 3 of Hamlet", "Quiz description url was not parsed correctly")
        XCTAssertEqual(quiz.quizType!, "assignment", "Quiz quiz type was not parsed correctly")
        XCTAssertEqual(quiz.assignmentGroupID!, "3", "Quiz assignment group id was not parsed correctly")
        XCTAssertEqual(quiz.timeLimitMinutes, 5, "Quiz time limit was not parsed correctly")
        XCTAssert(!quiz.shuffleAnswers, "Quiz shuffle answers was not parsed correctly")
        XCTAssertEqual(quiz.hideResults!, "always", "Quiz hide results was not parsed correctly")
        XCTAssert(quiz.showCorrectAnswers, "Quiz show correct answers was not parsed correctly")
        XCTAssertEqual(quiz.scoringPolicy!, "keep_highest", "Quiz scoring policy was not parsed correctly")
        XCTAssertEqual(quiz.allowedAttempts, 3, "Quiz allowed attempts was not parsed correctly")
        XCTAssert(!quiz.oneQuestionAtATime, "Quiz one question at a time was not parsed correctly")
        XCTAssertEqual(quiz.questionCount, 12, "Quiz question count was not parsed correctly")
        XCTAssertEqual(quiz.pointsPossible, 20, "Quiz points possible was not parsed correctly")
        XCTAssert(!quiz.cantGoBack, "Quiz cant go back was not parsed correctly")
        XCTAssertEqual(quiz.accessCode!, "2beornot2be", "Quiz access code was not parsed correctly")
        XCTAssertEqual(quiz.ipFilter!, "123.123.123.123", "Quiz ip filter was not parsed correctly")
        
        var formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2013-01-23T23:59:00-07:00")
        
        XCTAssertEqual(quiz.dueAt!, date, "Quiz due at date was not parsed correctly")
        
        XCTAssert(quiz.published, "Quiz published not parsed correctly")
        XCTAssertEqual(quiz.path!, "/api/v1/quizzes/5", "Group path was not parsed correctly")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
