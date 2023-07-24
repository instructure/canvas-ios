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
    let all_dates: [APIAssignmentDate]?
    /** Nil when `quiz_type` is `quizzes.next`. */
    let allowed_attempts: Int?
    let assignment_id: ID?
    let cant_go_back: Bool?
    let description: String?
    let due_at: Date?
    /** Nil when `quiz_type` is `quizzes.next`. */
    let has_access_code: Bool?
    let hide_correct_answers_at: Date?
    let hide_results: QuizHideResults?
    let html_url: URL
    let id: ID
    let ip_filter: String?
    let lock_at: Date?
    let lock_explanation: String?
    /** Nil when `quiz_type` is `quizzes.next`. */
    let locked_for_user: Bool?
    let mobile_url: URL
    /** Nil when `quiz_type` is `quizzes.next`. */
    let one_question_at_a_time: Bool?
    let points_possible: Double?
    let published: Bool?
    /** Nil when `quiz_type` is `quizzes.next`. */
    let question_count: Int?
    let question_types: [QuizQuestionType]?
    let quiz_type: QuizType
    let require_lockdown_browser_for_results: Bool
    let require_lockdown_browser: Bool
    let scoring_policy: ScoringPolicy?
    let show_correct_answers: Bool?
    let show_correct_answers_at: Date?
    let show_correct_answers_last_attempt: Bool?
    /** Nil when `quiz_type` is `quizzes.next`. */
    let shuffle_answers: Bool?
    let time_limit: Double? // minutes
    let title: String
    let unlock_at: Date?
    let unpublishable: Bool?
    // let anonymous_submissions: Bool?
    // let assignment_group_id: String?
    // let lock_info: LockInfoModel?
    // let one_time_results: Bool
    // let permissions: APIQuizPermissions?
    // let preview_url: URL
    // let quiz_extensions_url: URL?
    // let speedgrader_url: URL?
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
    let score: Double?
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
    // let time_spent: TimeInterval?
}

// https://canvas.instructure.com/doc/api/quiz_questions.html#QuizQuestion
public struct APIQuizQuestion: Codable {
    public let id: String
    public let quiz_id: String
    public let position: Int?
    public let question_name: String
    public let question_type: QuizQuestionType
    public let question_text: String
    public let points_possible: Int
    public let correct_comments: String
    public let incorrect_comments: String
    public let neutral_comments: String
    public let answers: [APIQuizAnswer]?
    public let answer: APIQuizAnswerValue?
}

// https://canvas.instructure.com/doc/api/quiz_submission_questions.html#QuizSubmissionQuestion
public struct APIQuizSubmissionQuestion: Codable {
    public let id: String
    public let flagged: Bool
    public let answer: APIQuizAnswerValue?
    // public let answers: [APIQuizAnswer]?
}

// Not documented
public struct APIQuizAnswer: Codable {
    public let id: String
    public let text: String
    public let html: String
}

// https://canvas.instructure.com/doc/api/quiz_submission_questions.html#Question+Answer+Formats-appendix
public enum APIQuizAnswerValue: Codable, Equatable {
    case double(Double)
    case string(String)
    case hash([String: String])
    case list([String])
    case matching([[String: String]])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: String].self) {
            self = .hash(value)
        } else if let value = try? container.decode([String].self) {
            self = .list(value)
        } else {
            self = .matching(try container.decode([[String: String]].self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .hash(let value):
            try container.encode(value)
        case .list(let value):
            try container.encode(value)
        case .matching(let value):
            try container.encode(value)
        }
    }
}

#if DEBUG
extension APIQuiz {
    public static func make(
        access_code: String? = nil,
        all_dates: [APIAssignmentDate]? = nil,
        allowed_attempts: Int = 1,
        assignment_id: ID? = nil,
        cant_go_back: Bool? = nil,
        description: String? = nil,
        due_at: Date? = nil,
        has_access_code: Bool = false,
        hide_correct_answers_at: Date? = nil,
        hide_results: QuizHideResults? = nil,
        html_url: URL = URL(string: "/courses/1/quizzes/123")!,
        id: ID = "123",
        ip_filter: String? = nil,
        lock_at: Date? = nil,
        lock_explanation: String? = nil,
        locked_for_user: Bool = false,
        mobile_url: URL = URL(string: "/courses/1/quizzes/123")!,
        one_question_at_a_time: Bool = false,
        points_possible: Double? = 11.1,
        published: Bool? = true,
        question_count: Int = 5,
        question_types: [QuizQuestionType]? = nil,
        quiz_type: QuizType = .survey,
        require_lockdown_browser_for_results: Bool = false,
        require_lockdown_browser: Bool = false,
        scoring_policy: ScoringPolicy? = nil,
        show_correct_answers: Bool? = nil,
        show_correct_answers_at: Date? = nil,
        show_correct_answers_last_attempt: Bool? = nil,
        shuffle_answers: Bool = false,
        time_limit: Double? = nil,
        title: String = "What kind of pokemon are you?",
        unlock_at: Date? = nil,
        unpublishable: Bool = false
    ) -> APIQuiz {
        APIQuiz(
            access_code: access_code,
            all_dates: all_dates,
            allowed_attempts: allowed_attempts,
            assignment_id: assignment_id,
            cant_go_back: cant_go_back,
            description: description,
            due_at: due_at,
            has_access_code: has_access_code,
            hide_correct_answers_at: hide_correct_answers_at,
            hide_results: hide_results,
            html_url: html_url,
            id: id,
            ip_filter: ip_filter,
            lock_at: lock_at,
            lock_explanation: lock_explanation,
            locked_for_user: locked_for_user,
            mobile_url: mobile_url,
            one_question_at_a_time: one_question_at_a_time,
            points_possible: points_possible,
            published: published,
            question_count: question_count,
            question_types: question_types,
            quiz_type: quiz_type,
            require_lockdown_browser_for_results: require_lockdown_browser_for_results,
            require_lockdown_browser: require_lockdown_browser,
            scoring_policy: scoring_policy,
            show_correct_answers: show_correct_answers,
            show_correct_answers_at: show_correct_answers_at,
            show_correct_answers_last_attempt: show_correct_answers_last_attempt,
            shuffle_answers: shuffle_answers,
            time_limit: time_limit,
            title: title,
            unlock_at: unlock_at,
            unpublishable: unpublishable
        )
    }
}

extension APIQuizSubmission {
    public static func make(
        attempt: Int = 1,
        attempts_left: Int = -1,
        end_at: Date? = nil,
        extra_time: Double? = nil,
        finished_at: Date? = nil,
        id: ID = "1",
        quiz_id: ID = "1",
        score: Double? = nil,
        started_at: Date? = nil,
        submission_id: ID = "1",
        user_id: ID = "1",
        validation_token: String? = "token",
        workflow_state: QuizSubmissionWorkflowState = .untaken
    ) -> APIQuizSubmission {
        APIQuizSubmission(
            attempt: attempt,
            attempts_left: attempts_left,
            end_at: end_at,
            extra_time: extra_time,
            finished_at: finished_at,
            id: id,
            quiz_id: quiz_id,
            score: score,
            started_at: started_at,
            submission_id: submission_id,
            user_id: user_id,
            validation_token: validation_token,
            workflow_state: workflow_state
        )
    }
}

extension APIQuizQuestion {
    public static func make(
        id: String = "1",
        quiz_id: String = "1",
        position: Int? = nil,
        question_name: String = "",
        question_type: QuizQuestionType = .multiple_choice_question,
        question_text: String = "A Question",
        points_possible: Int = 1,
        correct_comments: String = "",
        incorrect_comments: String = "",
        neutral_comments: String = "",
        answers: [APIQuizAnswer]? = [],
        answer: APIQuizAnswerValue? = nil
    ) -> APIQuizQuestion {
        APIQuizQuestion(
            id: id,
            quiz_id: quiz_id,
            position: position,
            question_name: question_name,
            question_type: question_type,
            question_text: question_text,
            points_possible: points_possible,
            correct_comments: correct_comments,
            incorrect_comments: incorrect_comments,
            neutral_comments: neutral_comments,
            answers: answers,
            answer: answer
        )
    }
}

extension APIQuizAnswer {
    public static func make(
        id: String = "1",
        text: String = "Answer",
        html: String = ""
    ) -> APIQuizAnswer {
        APIQuizAnswer(
            id: id,
            text: text,
            html: html
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/quizzes.html#method.quizzes/quizzes_api.index
public struct GetQuizzesRequest: APIRequestable {
    public typealias Response = [APIQuiz]

    let courseID: String

    public init (courseID: String) {
        self.courseID = courseID
    }

    public var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/all_quizzes?per_page=100"
    }
}

// https://canvas.instructure.com/doc/api/quizzes.html#method.quizzes/quizzes_api.show
public struct GetQuizRequest: APIRequestable {
    public typealias Response = APIQuiz

    let courseID: String
    let quizID: String

    public var path: String {
        let context = Context(.course, id: courseID)
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
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/quizzes/\(quizID)/submission"
    }
}

// https://canvas.instructure.com/doc/api/quiz_submissions.html#method.quizzes/quiz_submissions_api.index
public struct GetAllQuizSubmissionsRequest: APIRequestable {
    public struct Response: Codable {
        let quiz_submissions: [APIQuizSubmission]
        let submissions: [APISubmission]?
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
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/quizzes/\(quizID)/submissions"
    }

    public var query: [APIQueryItem] {
        [
            .include(includes.map { $0.rawValue }),
            .perPage(perPage),
        ]
    }
}

// https://canvas.instructure.com/doc/api/quiz_submissions.html#method.quizzes/quiz_submissions_api.create
struct PostQuizSubmissionRequest: APIRequestable {
    struct Response: Codable {
        let quiz_submissions: [APIQuizSubmission]
    }
    struct Body: Codable {
        let access_code: String?
        let preview: Bool?
    }

    let courseID: String
    let quizID: String
    let body: Body?

    var path: String {
        return "\(Context(.course, id: courseID).pathComponent)/quizzes/\(quizID)/submissions"
    }

    let method = APIMethod.post
}

// https://canvas.instructure.com/doc/api/quiz_submissions.html#method.quizzes/quiz_submissions_api.complete
struct PostQuizSubmissionCompleteRequest: APIRequestable {
    typealias Response = PostQuizSubmissionRequest.Response
    struct Body: Codable {
        let attempt: UInt
        let validation_token: String
        let access_code: String?
    }

    let courseID: String
    let quizID: String
    let quizSubmissionID: String
    let body: Body?

    var path: String {
        return "\(Context(.course, id: courseID).pathComponent)/quizzes/\(quizID)/submissions/\(quizSubmissionID)/complete"
    }

    let method = APIMethod.post
}

struct APIQuizParameters: Codable, Equatable {
    let access_code: String?
    let allowed_attempts: Int?
    let assignment_group_id: String?
    let cant_go_back: Bool?
    let description: String?
    let one_question_at_a_time: Bool?
    let published: Bool?
    let quiz_type: QuizType?
    let scoring_policy: ScoringPolicy?
    let shuffle_answers: Bool?
    let time_limit: Double?
    let title: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(access_code, forKey: .access_code) // encode null to unset
        try container.encodeIfPresent(allowed_attempts, forKey: .allowed_attempts)
        try container.encodeIfPresent(assignment_group_id, forKey: .assignment_group_id)
        try container.encodeIfPresent(cant_go_back, forKey: .cant_go_back)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(one_question_at_a_time, forKey: .one_question_at_a_time)
        try container.encodeIfPresent(published, forKey: .published)
        try container.encodeIfPresent(quiz_type, forKey: .quiz_type)
        try container.encodeIfPresent(scoring_policy, forKey: .scoring_policy)
        try container.encodeIfPresent(shuffle_answers, forKey: .shuffle_answers)
        try container.encode(time_limit, forKey: .time_limit) // encode null to unset
        try container.encodeIfPresent(title, forKey: .title)
    }
}

// https://canvas.instructure.com/doc/api/quizzes.html#method.quizzes/quizzes_api.update
struct PutQuizRequest: APIRequestable {
    typealias Response = APINoContent
    struct Body: Codable, Equatable {
        let quiz: APIQuizParameters
    }
    let courseID: String
    let quizID: String

    var method: APIMethod { .put }
    var path: String { "courses/\(courseID)/quizzes/\(quizID)" }
    let body: Body?
}
