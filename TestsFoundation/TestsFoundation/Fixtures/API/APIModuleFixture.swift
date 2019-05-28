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

extension APIModule {
    public static func make(
        id: ID = "1",
        name: String = "Module 1",
        position: Int = 1,
        published: Bool = true,
        items: [APIModuleItem]? = nil
    ) -> APIModule {
        return APIModule(
            id: id,
            name: name,
            position: position,
            published: published,
            items: items
        )
    }
}

extension APIModuleItem {
    public static func make(
        id: ID = "1",
        module_id: ID = "1",
        position: Int = 1,
        title: String = "Module Item 1",
        indent: Int = 0,
        content: ModuleItemType = .assignment("1"),
        html_url: URL? = URL(string: "https://canvas.example.edu/courses/222/modules/items/768"),
        url: URL? = URL(string: "https://canvas.example.edu/api/v1/courses/222/assignments/987"),
        published: Bool? = nil,
        content_details: ContentDetails = .make()
    ) -> APIModuleItem {
        return APIModuleItem(
            id: id,
            module_id: module_id,
            position: position,
            title: title,
            indent: indent,
            content: content,
            html_url: html_url,
            url: url,
            published: published,
            content_details: content_details
        )
    }
}

extension APIModuleItem.ContentDetails {
    public static func make(
        due_at: Date? = nil
    ) -> APIModuleItem.ContentDetails {
        return APIModuleItem.ContentDetails(
            due_at: due_at
        )
    }
}
