//
// Copyright (C) 2016-present Instructure, Inc.
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

public struct QuizModel: Codable {
    // MARK: - API Model Properties
    let id: String
    let title: String
    let html_url: URL?
    let mobile_url: URL?
    let preview_url: URL?
    let description: String
    let quiz_type: QuizModel.QuizType
    let assignment_group_id: String?
    let time_limit: QuizModel.TimeLimit?
    let shuffle_answers: Bool
    let hide_results: QuizModel.HideResults?
    let show_correct_answers: Bool?
    let show_correct_answers_last_attempt: Bool?
    let show_correct_answers_at: Date?
    let hide_correct_answers_at: Date?
    let one_time_results: Bool
    let scoring_policy: QuizModel.ScoringPolicy?
    let allowed_attempts: Int?
    let one_question_at_a_time: Bool
    let question_count: Int
    let points_possible: Int?
    let cant_go_back: Bool?
    let access_code: String?
    let ip_filter: String?
    let due_at: Date?
    let lock_at: Date?
    let unlock_at: Date?
    let published: Bool
    let unpublishable: Bool
    let locked_for_user: Bool
    // let lock_info: LockInfoModel?
    let lock_explanation: String?
    let speedgrader_url: URL?
    let quiz_extensions_url: URL?
    let permissions: QuizModel.Permissions?
    let all_dates: [Date]?
    let version_number: Int
    let question_types: [QuizModel.QuestionType]?
    let anonymous_submissions: Bool?

    // MARK: - View Computed Properties

    var questionCountText: String {
        let questionsFormat = NSLocalizedString("plural_questions", bundle: .core, comment: "")
        return String.localizedStringWithFormat(questionsFormat, question_count)
    }

    var pointsPossibleText: String? {
        guard let points = points_possible else { return nil }
        let pointsFormat = NSLocalizedString("plural_pts", bundle: .core, comment: "")
        return String.localizedStringWithFormat(pointsFormat, points)
    }

    var dueAtText: String {
        guard let due = due_at else { return NSLocalizedString("No Due Date", bundle: .core, comment: "") }
        let dateString = DateFormatter.localizedString(from: due, dateStyle: .medium, timeStyle: .short)
        if let lock = lock_at, Date() > lock {
            return dateString
        }
        return String.localizedStringWithFormat(NSLocalizedString("Due %@", bundle: .core, comment: ""), dateString)
    }

    var statusText: String? {
        if due_at != nil, let lock = lock_at, Date() > lock {
            return NSLocalizedString("Closed", bundle: .core, comment: "")
        }
        return nil
    }

    // MARK: - Nested Types

    public enum QuizType: String, Codable {
        case practice_quiz, assignment, graded_survey, survey
    }

    public enum HideResults: String, Codable {
        case always, until_after_last_attempt
    }

    public enum ScoringPolicy: String, Codable {
        case keep_highest, keep_latest
    }

    public enum QuestionType: String, Codable {
        case
            true_false_question,
            multiple_choice_question,
            short_answer_question,
            fill_in_multiple_blanks_question,
            multiple_answers_question,
            multiple_dropdowns_question,
            matching_question,
            numerical_question,
            calculated_question,
            essay_question,
            file_upload_question,
            text_only_question
    }

    public struct Permissions: Codable, Equatable {
        let read: Bool
        let submit: Bool
        let create: Bool
        let manage: Bool
        let read_statistics: Bool
        let review_grades: Bool
        let update: Bool
    }

    public struct TimeLimit: Codable, Equatable {
        let measurement: Measurement<UnitDuration>

        public init(minutes: Double) {
            measurement = Measurement(value: minutes, unit: UnitDuration.minutes)
        }

        public init(from decoder: Decoder) throws {
            self.init(minutes: try Double(from: decoder))
        }

        public func encode(to encoder: Encoder) throws {
            try measurement.value.encode(to: encoder)
        }

        public func to(_ unit: UnitDuration) -> Double {
            return measurement.converted(to: unit).value
        }
    }
}
