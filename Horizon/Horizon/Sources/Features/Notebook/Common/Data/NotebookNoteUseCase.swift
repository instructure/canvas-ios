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

class NotebookNoteUseCase: CollectionUseCase {
    typealias Model = CDNotebookNote

    let cacheKey: String? = "notebook-notes"
    let request: GetNotesQuery

    init(getNotesQuery: GetNotesQuery) {
        request = getNotesQuery
    }

    public var scope: Scope {
        var predicates: [NSPredicate] = []
        if let labelsSerialized = CDNotebookNote.serializeLabels(request.variables.filter?.reactions) {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDNotebookNote.labels), labelsSerialized))
        }
        if let courseID = request.variables.filter?.courseId {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDNotebookNote.courseID), courseID))
        }
        if let itemID = request.variables.filter?.learningObject?.id {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDNotebookNote.pageID), itemID))
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let order = [NSSortDescriptor(key: #keyPath(CDNotebookNote.date), ascending: false)]
        return Scope(predicate: predicate, order: order)
    }

    func write(
       response: RedwoodFetchNotesQueryResponse?,
       urlResponse _: URLResponse?,
       to client: NSManagedObjectContext
    ) {
        response?.data.notes.edges.forEach { edge in
            CDNotebookNote.save(edge.node, in: client)
        }
    }
}
