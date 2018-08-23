//
// Copyright (C) 2017-present Instructure, Inc.
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
@testable import CanvasCore

class QuizModelTests: XCTestCase {
    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    func testDecodableTimeLimit() {
        let time = try! decoder.decode([QuizModel.TimeLimit].self, from: "[10]".data(using: .utf8)!)
        XCTAssertEqual(time.first?.to(.seconds), 10 * 60)
    }

    func testEncodableTimeLimit() {
        let time = QuizModel.TimeLimit(minutes: 5)
        let data = try! encoder.encode([time])
        XCTAssertEqual(String(data: data, encoding: .utf8), "[5]")
    }

    func testQuestionCountText() {
        var quiz = QuizModel.make([ "question_count": 1 ])
        XCTAssertEqual(quiz.questionCountText, "1 Question")

        quiz = QuizModel.make([ "question_count": 2 ])
        XCTAssertEqual(quiz.questionCountText, "2 Questions")
    }

    func testPointsPossibleText() {
        var quiz = QuizModel.make([ "points_possible": nil ])
        XCTAssertEqual(quiz.pointsPossibleText, nil)

        quiz = QuizModel.make([ "points_possible": 1 ])
        XCTAssertEqual(quiz.pointsPossibleText, "1 pt")

        quiz = QuizModel.make([ "points_possible": 2 ])
        XCTAssertEqual(quiz.pointsPossibleText, "2 pts")
    }

    func testDueAtText() {
        var quiz = QuizModel.make([ "due_at": nil ])
        XCTAssertEqual(quiz.dueAtText, "No Due Date")

        quiz = QuizModel.make([
            "due_at": Calendar.current.date(from: DateComponents(year: 2018, month: 8, day: 6)),
            "lock_at": Calendar.current.date(from: DateComponents(year: 2018, month: 8, day: 5)),
        ])
        XCTAssertEqual(quiz.dueAtText, "Aug 6, 2018 at 12:00 AM")

        quiz = QuizModel.make([
            "due_at": Calendar.current.date(from: DateComponents(year: 2018, month: 8, day: 6)),
            "lock_at": nil,
        ])
        XCTAssertEqual(quiz.dueAtText, "Due Aug 6, 2018 at 12:00 AM")
    }

    func testStatusText() {
        var quiz = QuizModel.make([ "due_at": nil ])
        XCTAssertEqual(quiz.statusText, nil)

        quiz = QuizModel.make([
            "due_at": Date(fromISOString: "2018-08-06T20:00:00Z")!,
            "lock_at": Date(fromISOString: "2018-08-06T20:00:00Z")!,
        ])
        XCTAssertEqual(quiz.statusText, "Closed")
    }
}
