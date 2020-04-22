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
        prerequisite_module_ids: [String] = [],
        state: ModuleState? = nil,
        items: [APIModuleItem]? = nil
    ) -> APIModule {
        return APIModule(
            id: id,
            name: name,
            position: position,
            published: published,
            prerequisite_module_ids: prerequisite_module_ids,
            state: state,
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
        content_details: ContentDetails? = nil,
        completion_requirement: CompletionRequirement? = nil
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
            content_details: content_details,
            completion_requirement: completion_requirement
        )
    }
}

extension APIModuleItem.ContentDetails {
    public static func make(
        due_at: Date? = nil,
        points_possible: Double? = nil,
        locked_for_user: Bool? = nil,
        lock_explanation: String? = nil
    ) -> APIModuleItem.ContentDetails {
        return APIModuleItem.ContentDetails(
            due_at: due_at,
            points_possible: points_possible,
            locked_for_user: locked_for_user,
            lock_explanation: lock_explanation
        )
    }
}

extension APIModuleItemSequence.Node {
    public static func make(
        prev: APIModuleItem? = nil,
        current: APIModuleItem? = nil,
        next: APIModuleItem? = nil
    ) -> Self {
        return .init(prev: prev, current: current, next: next)
    }
}

extension APIModuleItemSequence {
    public static func make(
        items: [Node] = [.make()],
        modules: [APIModule] = [.make()]
    ) -> Self {
        return .init(items: items, modules: modules)
    }
}
