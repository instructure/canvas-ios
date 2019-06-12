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

import Foundation
@testable import Core

extension APIQuiz {
    public static func make(
        access_code: String? = nil,
        allowed_attempts: Int = 1,
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
        question_types: [QuizQuestionType] = [],
        quiz_type: QuizType = .survey,
        require_lockdown_browser_for_results: Bool = false,
        require_lockdown_browser: Bool = false,
        shuffle_answers: Bool = false,
        time_limit: Double? = nil,
        title: String = "What kind of pokemon are you?",
        unlock_at: Date? = nil
    ) -> APIQuiz {
        return APIQuiz(
            access_code: access_code,
            allowed_attempts: allowed_attempts,
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
        validation_token: String? = nil,
        workflow_state: QuizSubmissionWorkflowState = .untaken
    ) -> APIQuizSubmission {
        return APIQuizSubmission(
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
