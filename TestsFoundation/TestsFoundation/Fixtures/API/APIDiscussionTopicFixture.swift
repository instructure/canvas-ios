//
// Copyright (C) 2019-present Instructure, Inc.
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

@testable import Core

extension APIDiscussionTopic: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "title": "my discussion topic",
            "message": "message",
            "discussion_subentry_count": 1,
            "published": true,
            "author": APIDiscussionAuthor.fixture(),
        ]
    }
}

extension APIDiscussionAuthor: Fixture {
    public static var template: Template {
        return [
            "id": "1",
            "display_name": "Bob",
            "html_url": "/users/1",
        ]
    }
}
