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
import Core

extension Quiz: Fixture {
    public static var template: Template {
        return [
            "courseID": "1",
            "id": "123",
            "title": "What kind of pokemon are you?",
            "htmlURL": URL(string: "http://canvas.example.edu/courses/1/quizzes/2")!,
            "quizTypeRaw": QuizType.survey.rawValue,
            "questionCount": 5,
            "pointsPossibleRaw": 11.1,
        ]
    }
}
