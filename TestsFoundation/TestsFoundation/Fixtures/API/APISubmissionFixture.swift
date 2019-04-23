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

extension APISubmission: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "assignment_id": "1",
            "user_id": "1",
            "late": false,
            "excused": false,
            "missing": false,
            "workflow_state": "submitted",
            "submitted_at": "2019-03-13T21:00:00Z",
        ]
    }
}

extension APISubmissionComment: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "author_id": "1",
            "author_name": "Steve",
            "author": APISubmissionCommentAuthor.fixture(),
            "comment": "comment",
            "created_at": "2019-03-13T21:00:36Z",
        ]
    }
}

extension APISubmissionCommentAuthor: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "display_name": "Steve",
            "html_url": "/users/1",
        ]
    }
}
