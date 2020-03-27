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

@testable import Core
import PactConsumerSwift

extension Date: PactEncodable {
    static let iso8601Regex = #"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z"#
    func pactEncode(to encoder: PactEncoder) throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        let dateStr = formatter.string(from: self)
        try encoder.encode(dateStr, matching: Date.iso8601Regex)
    }
}

extension URL: PactEncodable {
    func pactEncode(to encoder: PactEncoder) throws {
        try encoder.encode(absoluteString)
    }
}

extension APIUser: PactShapeEncodable { }
extension EnrollmentState: PactCaseEncodable { }
extension APIEnrollment: PactShapeEncodable { }
extension APIEnrollment.Grades: PactShapeEncodable { }
extension APICourse: PactShapeEncodable { }
extension APIQuiz: PactShapeEncodable { }
extension QuizType: PactCaseEncodable { }
extension QuizQuestionType: PactCaseEncodable { }
extension QuizHideResults: PactCaseEncodable { }
extension APIDiscussionParticipant: PactShapeEncodable { }
extension APIDiscussionEntry: PactShapeEncodable { }

extension APIDiscussionTopic: PactSimpleEncodable {
    var pactFields: [String: PactSimpleFieldHandling] {
        // Can't pact test for "String?"
        [ "message": .ignore ]
    }
}

extension APIDiscussionFullTopic: PactSimpleEncodable {
    var pactFields: [String: PactSimpleFieldHandling] {
        [
            "participants": .eachLike(),
            "unread_entries": .eachLike(),
            "entry_ratings": .ignore, // dynamic-keyed dictionaries can't yet be encoded in pact
            "forced_entries": .eachLike(min: 0),
            "view": .eachLike(min: 0),
        ]
    }
}
