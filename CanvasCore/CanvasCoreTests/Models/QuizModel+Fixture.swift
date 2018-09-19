//
// Copyright (C) 2017-present Instructure, Inc.
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

import CanvasCore

extension QuizModel: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "title": "Do you has what it takes?",
            "description": "To join the Homestarmy",
            "quiz_type": "graded_survey",
            "shuffle_answers": false,
            "one_time_results": false,
            "one_question_at_a_time": false,
            "question_count": 3,
            "published": true,
            "unpublishable": false,
            "locked_for_user": false,
            "version_number": 1,
        ]
    }
}

extension QuizModel.Permissions: Fixture {
    public static var template: Template {
        return [
            "read": false,
            "submit": false,
            "create": false,
            "manage": false,
            "read_statistics": false,
            "review_grades": false,
            "update": false,
        ]
    }
}
