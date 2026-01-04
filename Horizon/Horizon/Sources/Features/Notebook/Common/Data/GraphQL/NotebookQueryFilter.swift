//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct NotebookQueryFilter {
    /// The cursor used to start pagination in the backward direction.
    let startCursor: String?
    let reactions: [String]?
    let courseId: String?
    var pageId: String?

    init(
        startCursor: String? = nil,
        reactions: [String]? = nil,
        courseId: String? = nil,
        pageId: String? = nil
    ) {
        self.startCursor = startCursor
        self.reactions = reactions
        self.courseId = courseId
        self.pageId = pageId
    }
}
