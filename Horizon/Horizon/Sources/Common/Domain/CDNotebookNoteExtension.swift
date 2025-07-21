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

import Core
import CoreData

extension CDHNotebookNote {
    @discardableResult
    public static func save(
        _ item: RedwoodNote,
        userID: String,
        notebookNote: CDHNotebookNote? = nil,
        in context: NSManagedObjectContext
    ) -> CDHNotebookNote {
        let model: CDHNotebookNote = notebookNote ?? context.first(where: #keyPath(CDHNotebookNote.id), equals: item.id) ?? context.insert()
        model.userID = userID
        model.content = item.userText
        model.courseID = item.courseId
        model.date = item.createdAt
        if let end = item.highlightData?.textPosition.end {
            model.end = NSNumber(value: end)
        }
        model.endContainer = item.highlightData?.range.endContainer
        if let endOffset = item.highlightData?.range.endOffset {
            model.endOffset = NSNumber(value: endOffset)
        }
        model.id = item.id
        model.labels = CDHNotebookNote.serializeLabels(from: item.reaction)
        model.objectType = item.objectType
        model.pageID = item.objectId
        model.selectedText = item.highlightData?.selectedText
        if let start = item.highlightData?.textPosition.start {
            model.start = NSNumber(value: start)
        }
        model.startContainer = item.highlightData?.range.startContainer
        if let startOffset = item.highlightData?.range.startOffset {
            model.startOffset = NSNumber(value: startOffset)
        }

        return model
    }
}
