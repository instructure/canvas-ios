//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

// https://canvas.instructure.com/doc/api/quizzes.html#Quiz
public struct APIQuiz: Codable, Equatable {
    let id: String
    let title: String
    let html_url: URL
    // let mobile_url: URL
    // let preview_url: URL
    let description: String?
    let quiz_type: QuizType
    // let assignment_group_id: String?
    // let time_limit: Double? // minutes
    // let shuffle_answers: Bool
    // let hide_results: QuizHideResults?
    // let show_correct_answers: Bool?
    // let show_correct_answers_last_attempt: Bool?
    // let show_correct_answers_at: Date?
    // let hide_correct_answers_at: Date?
    // let one_time_results: Bool
    // let scoring_policy: ScoringPolicy?
    // let allowed_attempts: Int?
    // let one_question_at_a_time: Bool
    let question_count: Int
    let points_possible: Double?
    // let cant_go_back: Bool?
    // let access_code: String?
    // let ip_filter: String?
    let due_at: Date?
    let lock_at: Date?
    // let unlock_at: Date?
    // let published: Bool
    // let unpublishable: Bool
    // let locked_for_user: Bool
    // let lock_info: LockInfoModel?
    // let lock_explanation: String?
    // let speedgrader_url: URL?
    // let quiz_extensions_url: URL?
    // let permissions: APIQuizPermissions?
    // let all_dates: [Date]?
    // let version_number: Int
    // let question_types: [QuestionType]?
    // let anonymous_submissions: Bool?
}
