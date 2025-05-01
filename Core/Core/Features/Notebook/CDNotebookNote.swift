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

import CoreData
import Foundation

final public class CDNotebookNote: NSManagedObject {
    @NSManaged public var after: String? // used for paging in the query used to fetch this object
    @NSManaged public var before: String? // used for paging in the query used to fetch this object
    @NSManaged public var content: String? // the text of the note
    @NSManaged public var courseID: String
    @NSManaged public var date: Date // the date the note was created
    @NSManaged public var end: Int16
    @NSManaged public var endContainer: String?
    @NSManaged public var endOffset: Int16
    @NSManaged public var id: String
    @NSManaged public var labels: String?
    @NSManaged public var objectType: String
    @NSManaged public var pageID: String
    @NSManaged public var selectedText: String?
    @NSManaged public var start: Int16
    @NSManaged public var startContainer: String?
    @NSManaged public var startOffset: Int16

    @discardableResult
    public static func save(
        _ item: RedwoodNote,
        notebookNote: CDNotebookNote? = nil,
        in context: NSManagedObjectContext
    ) -> CDNotebookNote {
        let model: CDNotebookNote = notebookNote ?? context.first(where: #keyPath(CDNotebookNote.id), equals: item.id) ?? context.insert()

        model.content = item.userText
        model.courseID = item.courseId
        model.date = item.createdAt
        model.end = Int16(item.highlightData?.textPosition.end ?? -1)
        model.endContainer = item.highlightData?.range.endContainer
        model.endOffset = Int16(item.highlightData?.range.endOffset ?? -1)
        model.id = item.id
        model.labels = item.reaction?.serializeLabels
        model.objectType = item.objectType
        model.pageID = item.objectId
        model.selectedText = item.highlightData?.selectedText
        model.start = Int16(item.highlightData?.textPosition.start ?? -1)
        model.startContainer = item.highlightData?.range.startContainer
        model.startOffset = Int16(item.highlightData?.range.startOffset ?? -1)

        return model
    }
}

extension String? {
    public var deserializeLabels: [String]? {
        self?.split(separator: ";").map { String($0) }
    }
}

extension Array where Element == String {
    public var serializeLabels: String? {
        self.sorted().joined(separator: ";")
    }
}
