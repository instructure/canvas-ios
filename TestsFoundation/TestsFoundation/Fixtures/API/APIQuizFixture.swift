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
        id: ID = "123",
        title: String = "What kind of pokemon are you?",
        html_url: URL = URL(string: "/courses/1/quizzes/123")!,
        description: String? = nil,
        quiz_type: QuizType = .survey,
        time_limit: Double? = nil,
        allowed_attempts: Int = 1,
        question_count: Int = 5,
        points_possible: Double? = 11.1,
        due_at: Date? = nil,
        lock_at: Date? = nil
    ) -> APIQuiz {
        return APIQuiz(
            id: id,
            title: title,
            html_url: html_url,
            description: description,
            quiz_type: quiz_type,
            time_limit: time_limit,
            allowed_attempts: allowed_attempts,
            question_count: question_count,
            points_possible: points_possible,
            due_at: due_at,
            lock_at: lock_at
        )
    }
}

extension APIQuizSubmission {
    public static func make(
        id: ID = "1",
        quiz_id: ID = "1",
        user_id: ID = "1",
        submission_id: ID = "1",
        started_at: Date? = nil,
        finished_at: Date? = nil,
        end_at: Date? = nil,
        attempt: Int = 1,
        attempts_left: Int = -1,
        workflow_state: QuizSubmissionWorkflowState = .untaken
    ) -> APIQuizSubmission {
        return APIQuizSubmission(
            id: id,
            quiz_id: quiz_id,
            user_id: user_id,
            submission_id: submission_id,
            started_at: started_at,
            finished_at: finished_at,
            end_at: end_at,
            attempt: attempt,
            attempts_left: attempts_left,
            workflow_state: workflow_state
        )
    }
}
