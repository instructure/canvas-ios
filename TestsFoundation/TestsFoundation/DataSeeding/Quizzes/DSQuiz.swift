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

public struct DSQuiz: Codable {
    public let id: String
    public let title: String
    public let quiz_type: String
    public let description: String
    public let published: Bool
    public let question_count: Int
    public let assignment_group_id: String?
    public let assignment_id: String?
    public let assessment_question_id: String?
    public let points_possible: Float?
    public let allowed_attempts: Int?
}

public enum DSQuizType: String {
    case practiceQuiz = "practice_quiz"
    case assignment = "assignment"
    case gradedSurvey = "graded_survey"
    case survey = "survey"
}
