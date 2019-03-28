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

import Foundation
@testable import Core

extension APIModule: Fixture {
    public static let template: Template = [
        "id": "1",
        "name": "Module 1",
        "position": 1,
        "published": true,
        "workflow_state": "active"
    ]
}

extension APIModuleItem: Fixture {
    public static let template: Template = [
        "id": "1",
        "module_id": "1",
        "position": 1,
        "title": "Module Item 1",
        "indent": 0,
        "type": "Assignment",
        "content_id": "1",
        "html_url": "https://canvas.example.edu/courses/222/modules/items/768",
        "url": "https://canvas.example.edu/api/v1/courses/222/assignments/987"
    ]
}
