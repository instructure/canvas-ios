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

import CombineExt

struct AssistState: Codable, Equatable {
    var courseID: String?
    var fileID: String?
    var pageID: String?
    var textSelection: String?

    init(
        courseID: String? = nil,
        fileID: String? = nil,
        pageID: String? = nil,
        textSelection: String? = nil
    ) {
        self.courseID = courseID
        self.fileID = fileID
        self.pageID = pageID
        self.textSelection = textSelection
    }
}
