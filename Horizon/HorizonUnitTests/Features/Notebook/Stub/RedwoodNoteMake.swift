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
@testable import Horizon
@testable import Core

extension RedwoodNote {
    static func make(
        id: String = "note-1",
        updatedAt: Date = Date(),
        courseId: String = "ID-1",
        objectId: String = "mockObjectId",
        objectType: String = APIModuleItemType.page.rawValue,
        userText: String = "Mock note content",
        reaction: [String]? = ["Important"],
        highlightData: NotebookHighlight? = .init(
            selectedText: "Selected Text",
            textPosition: .init(
                start: 10,
                end: 100
            ),
            range: .init(
                startContainer: "startContainer",
                startOffset: 10,
                endContainer: "100",
                endOffset: 10
            )
        )
    ) -> RedwoodNote {
        return RedwoodNote(
            id: id,
            updatedAt: updatedAt,
            courseId: courseId,
            objectId: objectId,
            objectType: objectType,
            userText: userText,
            reaction: reaction,
            highlightData: highlightData
        )
    }
}
