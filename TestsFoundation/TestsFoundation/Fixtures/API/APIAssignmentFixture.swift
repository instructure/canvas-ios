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

extension APIAssignment: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "course_id": "1",
            "name": "some assignment",
            "description": "<p>Do the following:</p>...",
            "points_possible": 10,
            "due_at": nil,
            "html_url": "https://canvas.instructure.com/courses/1/assignments/1",
            "grading_type": "points",
            "submission_types": ["online_text_entry"],
            "submission": APISubmission.fixture([
                "workflow_state": "unsubmitted",
            ]),
            "position": 0,
            "lockedForUser": false,
        ]
    }
}

extension APIAssignmentNoSubmission: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "course_id": "1",
            "name": "some assignment",
            "description": "<p>Do the following:</p>...",
            "points_possible": 10,
            "due_at": nil,
            "html_url": "https://canvas.instructure.com/courses/1/assignments/1",
            "grading_type": "points",
            "submission_types": ["online_text_entry"],
            "position": 0,
            "lockedForUser": false,
        ]
    }
}
