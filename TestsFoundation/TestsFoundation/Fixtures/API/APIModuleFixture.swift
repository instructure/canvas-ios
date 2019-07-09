//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
