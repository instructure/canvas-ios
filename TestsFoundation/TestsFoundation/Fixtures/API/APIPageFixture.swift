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

extension APIPage {
    public static func make(
        body: String? = nil,
        editing_roles: String? = nil,
        front_page: Bool = false,
        html_url: URL = URL(string: "/courses/42/pages/answers-page")!,
        page_id: ID = ID("42"),
        published: Bool = false,
        title: String = "Answers Page",
        updated_at: Date = Date(),
        url: String = "answers-page"
	) -> APIPage {
        return APIPage(
            url: url,
            updated_at: updated_at,
            front_page: front_page,
            page_id: page_id,
            title: title,
            html_url: html_url,
            published: published,
            body: body,
            editing_roles: editing_roles
        )
    }
}
