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
@testable import Core

// https://canvas.instructure.com/doc/api/quizzes.html
extension APIQuiz {
    public static func make(
        access_code: String? = nil,
        allowed_attempts: Int = 1,
        assignment_id: ID? = nil,
        cant_go_back: Bool? = nil,
        description: String? = nil,
        due_at: Date? = nil,
        has_access_code: Bool = false,
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
        question_count: Int = 5,
        question_types: [QuizQuestionType]? = nil,
        quiz_type: QuizType = .survey,
        require_lockdown_browser_for_results: Bool = false,
        require_lockdown_browser: Bool = false,
        shuffle_answers: Bool = false,
        time_limit: Double? = nil,
        title: String = "What kind of pokemon are you?",
        unlock_at: Date? = nil
    ) -> APIQuiz {
        APIQuiz(
            access_code: access_code,
            allowed_attempts: allowed_attempts,
            assignment_id: assignment_id,
            cant_go_back: cant_go_back,
            description: description,
            due_at: due_at,
            has_access_code: has_access_code,
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
            question_count: question_count,
            question_types: question_types,
            quiz_type: quiz_type,
            require_lockdown_browser_for_results: require_lockdown_browser_for_results,
            require_lockdown_browser: require_lockdown_browser,
            shuffle_answers: shuffle_answers,
            time_limit: time_limit,
            title: title,
            unlock_at: unlock_at
        )
    }
}

// https://canvas.instructure.com/doc/api/quiz_submissions.html
extension APIQuizSubmission {
    public static func make(
        attempt: Int = 1,
        attempts_left: Int = -1,
        end_at: Date? = nil,
        extra_time: Double? = nil,
        finished_at: Date? = nil,
        id: ID = "1",
        quiz_id: ID = "1",
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
