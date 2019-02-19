//
// Copyright (C) 2018-present Instructure, Inc.
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

import Core

// https://canvas.instructure.com/doc/api/quizzes.html#method.quizzes/quizzes_api.create
struct PostQuizRequest: APIRequestable {
    typealias Response = APIQuiz
    struct Body: Codable {
        struct Quiz: Codable {
            let title: String
            let description: String?
            // let quiz_type: QuizType?
            // let assignment_group_id: String?
            // let time_limit: Int?
            // let shuffle_answers: Bool?
            // let hide_results: QuizHideResults
            // let show_correct_answers: Bool?
            // let show_correct_answers_last_attempt: Bool?
            // let show_correct_answers_at: Date?
            // let hide_correct_answers_at: Date?
            // let allowed_attempts: Int?
            // let scoring_policy: QuizScoringPolicy?
            // let one_question_at_a_time: Bool?
            // let cant_go_back: Bool?
            // let access_code: String?
            // let ip_filter: String?
            // let due_at: Date?
            // let lock_at: Date?
            // let unlock_at: Date?
            let published: Bool?
            // let one_time_results: Bool?
            // let only_visible_to_overrides: Bool?
        }

        let quiz: Quiz
    }

    let courseID: String
    let body: Body?

    var path: String {
        return "\(ContextModel(.course, id: courseID).pathComponent)/quizzes"
    }

    let method = APIMethod.post
}

// https://canvas.instructure.com/doc/api/quiz_questions.html#method.quizzes/quiz_questions.create
public struct PostQuizQuestionRequest: APIRequestable {
    public typealias Response = APIQuizQuestion
    public struct Body: Codable {
        public struct Question: Codable {
            public let question_name: String?
            public let question_text: String?
            // public let quiz_group_id: String?
            public let question_type: QuizQuestionType?
            // public let position: Int?
            public let points_possible: Int?
            // public let correct_comments: String?
            // public let incorrect_comments: String?
            // public let neutral_comments: String?
            // public let text_after_answers: String?
            // public let answers: [APIQuizAnswer]?
        }

        public let question: Question
    }

    public let courseID: String
    public let quizID: String
    public let body: Body?

    public var path: String {
        return "\(ContextModel(.course, id: courseID).pathComponent)/quizzes/\(quizID)/questions"
    }

    public let method = APIMethod.post
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
        return "\(ContextModel(.course, id: courseID).pathComponent)/quizzes/\(quizID)/submissions"
    }

    let method = APIMethod.post
}

// https://canvas.instructure.com/doc/api/quiz_submission_questions.html#method.quizzes/quiz_submission_questions.answer
struct PostQuizSubmissionQuestionRequest: APIRequestable {
    struct Response: Codable {
        let quiz_submission_questions: [APIQuizSubmissionQuestion]
    }
    struct Body: Codable {
        struct Question: Codable {
            let id: String
            let answer: APIQuizAnswerValue
        }

        let attempt: UInt
        let validation_token: String
        let access_code: String?
        let quiz_questions: [Question]
    }

    let quizSubmissionID: String
    let body: Body?

    var path: String {
        return "quiz_submissions/\(quizSubmissionID)/questions"
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
        return "\(ContextModel(.course, id: courseID).pathComponent)/quizzes/\(quizID)/submissions/\(quizSubmissionID)/complete"
    }

    let method = APIMethod.post
}
