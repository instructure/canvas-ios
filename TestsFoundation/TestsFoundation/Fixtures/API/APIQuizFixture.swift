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
