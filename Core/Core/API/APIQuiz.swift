//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation

// https://canvas.instructure.com/doc/api/quizzes.html#Quiz
public struct APIQuiz: Codable, Equatable {
    let access_code: String?
    let allowed_attempts: Int
    let assignment_id: ID?
    let cant_go_back: Bool?
    let description: String?
    let due_at: Date?
    let has_access_code: Bool
    let hide_results: QuizHideResults?
    let html_url: URL
    let id: ID
    let ip_filter: String?
    let lock_at: Date?
    let lock_explanation: String?
    let locked_for_user: Bool
    let mobile_url: URL
    let one_question_at_a_time: Bool
    let points_possible: Double?
    let question_count: Int
    let question_types: [QuizQuestionType]?
    let quiz_type: QuizType
    let require_lockdown_browser_for_results: Bool
    let require_lockdown_browser: Bool
    let shuffle_answers: Bool
    let time_limit: Double? // minutes
    let title: String
    let unlock_at: Date?
    // let all_dates: [Date]?
    // let anonymous_submissions: Bool?
    // let assignment_group_id: String?
    // let hide_correct_answers_at: Date?
    // let lock_info: LockInfoModel?
    // let one_time_results: Bool
    // let permissions: APIQuizPermissions?
    // let preview_url: URL
    // let published: Bool
    // let quiz_extensions_url: URL?
    // let scoring_policy: ScoringPolicy?
    // let show_correct_answers_at: Date?
    // let show_correct_answers_last_attempt: Bool?
    // let show_correct_answers: Bool?
    // let speedgrader_url: URL?
    // let unpublishable: Bool
    // let version_number: Int
}

// https://canvas.instructure.com/doc/api/quiz_submissions.html#QuizSubmission
public struct APIQuizSubmission: Codable {
    let attempt: Int?
    let attempts_left: Int
    let end_at: Date?
    let extra_time: Double?
    let finished_at: Date?
    let id: ID
    let quiz_id: ID
    let started_at: Date?
    let submission_id: ID
    let user_id: ID
    let validation_token: String?
    let workflow_state: QuizSubmissionWorkflowState
    // let extra_attempts: Int?
    // let fudge_points: Int?
    // let has_seen_results: Bool
    // let kept_score: Double?
    // let manually_unlocked: Bool
    // let overdue_and_needs_submission: Bool
    // let score_before_regrade: Double?
    // let score: Double?
    // let time_spent: TimeInterval?
}

// https://canvas.instructure.com/doc/api/quizzes.html#method.quizzes/quizzes_api.index
public struct GetQuizzesRequest: APIRequestable {
    public typealias Response = [APIQuiz]

    let courseID: String

    public init (courseID: String) {
        self.courseID = courseID
    }

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/quizzes?per_page=100"
    }
}

// https://canvas.instructure.com/doc/api/quizzes.html#method.quizzes/quizzes_api.show
public struct GetQuizRequest: APIRequestable {
    public typealias Response = APIQuiz

    let courseID: String
    let quizID: String

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/quizzes/\(quizID)"
    }
}

// https://canvas.instructure.com/doc/api/quiz_submissions.html#method.quizzes/quiz_submissions_api.submission
public struct GetQuizSubmissionRequest: APIRequestable {
    public struct Response: Codable {
        let quiz_submissions: [APIQuizSubmission]
    }

    let courseID: String
    let quizID: String

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/quizzes/\(quizID)/submission"
    }
}

// https://canvas.instructure.com/doc/api/quiz_submissions.html#method.quizzes/quiz_submissions_api.index
public struct GetAllQuizSubmissionsRequest: APIRequestable {
    public struct Response: Codable {
        let quiz_submissions: [APIQuizSubmission]
        let submissions: [APISubmission]?

        init(quiz_submissions: [APIQuizSubmission], submissions: [APISubmission]? = nil) {
            self.quiz_submissions = quiz_submissions
            self.submissions = submissions
        }
    }

    public enum Include: String {
        case submission
    }

    let courseID: String
    let quizID: String
    let includes: [Include]
    let perPage: Int?

    init(courseID: String, quizID: String, includes: [Include] = [], perPage: Int? = nil) {
        self.courseID = courseID
        self.quizID = quizID
        self.includes = includes
        self.perPage = perPage
    }

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/quizzes/\(quizID)/submissions"
    }

    public var query: [APIQueryItem] {
        [
            .include(includes.map { $0.rawValue }),
            .perPage(perPage),
        ]
    }
}
