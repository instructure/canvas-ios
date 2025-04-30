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
import Combine

class NotebookNoteUseCase: CollectionUseCase {
    typealias Model = CDNotebookNote

    // MARK: - Dependencies
    let request: GetNotesQuery
    let redwood: DomainService

    // MARK: - Overridden Properties
    var cacheKey: String? {
        "notebook-notes-\(after ?? "")-\(before ?? "")-\(labels ?? "")-\(courseID ?? "")-\(pageID ?? "")"
    }

    public var scope: Scope {
        var predicates: [NSPredicate] = []
        if let after = after {
            predicates.append(NSPredicate(format: "%K > %@", #keyPath(CDNotebookNote.date), after))
        }
        if let before = before {
            predicates.append(NSPredicate(format: "%K < %@", #keyPath(CDNotebookNote.date), before))
        }
        if let courseID = courseID {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDNotebookNote.courseID), courseID))
        }
        if let labelsSerialized = labels {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDNotebookNote.labels), labelsSerialized))
        }
        if let pageID = pageID {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDNotebookNote.pageID), pageID))
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let order = [NSSortDescriptor(key: #keyPath(CDNotebookNote.date), ascending: false)]
        return Scope(predicate: predicate, order: order)
    }

    // MARK: - Private Properties

    private var after: String? {
        request.variables.after
    }

    private var before: String? {
        request.variables.before
    }

    private var courseID: String? {
        request.variables.filter?.courseId
    }

    private var labels: String? {
        CDNotebookNote.serializeLabels(request.variables.filter?.reactions)
    }

    private var pageID: String? {
        request.variables.filter?.learningObject?.id
    }

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(getNotesQuery: GetNotesQuery, redwood: DomainService = DomainService(.redwood)) {
        request = getNotesQuery
        self.redwood = redwood
    }

    // MARK: - Overridden Methods

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping (Response?, URLResponse?, Error?) -> Void) {
        redwood
            .api()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] api in
                    guard let self = self else { return }
                    api.makeRequest(self.request, callback: completionHandler)
                }
            )
            .store(in: &subscriptions)
    }

    func write(
       response: RedwoodFetchNotesQueryResponse?,
       urlResponse _: URLResponse?,
       to client: NSManagedObjectContext
    ) {
        response?.data.notes.edges.forEach { edge in
            CDNotebookNote.save(edge.node, before: before, after: after, in: client)
        }
    }
}
