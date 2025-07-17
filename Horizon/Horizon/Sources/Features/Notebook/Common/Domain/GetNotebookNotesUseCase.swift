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

class GetNotebookNotesUseCase: CollectionUseCase {
    typealias Model = CDHNotebookNote

    // MARK: - Dependencies
    let redwood: DomainService

    // MARK: - Overridden Properties
    var cacheKey: String? {
        "notebook-notes"
    }

    let request = GetNotesQuery()

    public var scope: Scope {
        var predicates: [NSPredicate] = [
            NSPredicate(format: "%K == %@", #keyPath(CDHNotebookNote.userID), Context.currentUser.id)
        ]
        if let courseID = courseID {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDHNotebookNote.courseID), courseID))
        }
        labels?.forEach { label in
            predicates.append(NSPredicate(format: "%K CONTAINS %@", #keyPath(CDHNotebookNote.labels), label))
        }
        if let pageID = pageID {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDHNotebookNote.pageID), pageID))
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let order = [NSSortDescriptor(key: #keyPath(CDHNotebookNote.date), ascending: false)]
        return Scope(predicate: predicate, order: order)
    }

    // MARK: - Private Properties

    private let courseID: String?
    private let labels: [String]?
    private let pageID: String?
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        labels: [String] = [],
        courseID: String? = nil,
        pageID: String? = nil,
        redwood: DomainService = DomainService(.redwood)
    ) {
        self.labels = labels
        self.courseID = courseID
        self.pageID = pageID
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
        let fetchRequest = NSFetchRequest<CDHNotebookNote>(entityName: String(describing: CDHNotebookNote.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(CDHNotebookNote.date), ascending: false)]

        let result = (try? client.fetch(fetchRequest)) ?? []

        let tuple = changed(redwoodNotes: response?.data.notes.edges.map { $0.node } ?? [], cdHNotebookNotes: result)
        let changed = tuple.0
        let removed = tuple.1

        changed.forEach { redwoodNote in
            CDHNotebookNote.save(
                redwoodNote,
                userID: Context.currentUser.id,
                in: client
            )
        }

        removed.forEach { cdHNotebookNote in
            client.delete(cdHNotebookNote)
        }
    }

    // Returns the notes that have been added or updated in the first item, the ones that have been removed in the second item
    func changed(redwoodNotes: [RedwoodNote], cdHNotebookNotes: [CDHNotebookNote]) -> ([RedwoodNote], [CDHNotebookNote]) {
        let redwoodNotesAddedOrUpdated = redwoodNotes.filter { redwoodNote in
            let cdHNotebookNote = cdHNotebookNotes.first { $0.id == redwoodNote.id }
            return cdHNotebookNote?.content != redwoodNote.userText || cdHNotebookNote?.labels != CDHNotebookNote.serializeLabels(from: redwoodNote.reaction)
        }
        let notebookNotesRemoved = cdHNotebookNotes.filter { cdNotebookNote in
            !redwoodNotes.contains { $0.id == cdNotebookNote.id }
        }
        return (redwoodNotesAddedOrUpdated, notebookNotesRemoved)
    }
}
