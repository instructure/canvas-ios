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

import Foundation

/// Stores properties for a Student Notes entry (aka `teacher_note` in API, `Notes` in web UI, `Student Notes` in mobile UI).
/// There should be only one in the given context, but we support multiple.
/// The `index` is not an ID coming from API, it's just a workaround to identify the entry.
struct StudentNotesEntry: Identifiable {
    let index: Int
    let title: String
    let content: String

    var id: Int { index }
}

#if DEBUG

extension StudentNotesEntry {
    public static func make(
        index: Int = 0,
        title: String = "",
        content: String = ""
    ) -> StudentNotesEntry {
        .init(
            index: index,
            title: title,
            content: content
        )
    }
}

#endif
