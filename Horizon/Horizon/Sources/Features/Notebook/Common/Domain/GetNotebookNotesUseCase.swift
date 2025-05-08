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
    typealias Model = CDNotebookNote

    // MARK: - Dependencies
    let redwood: DomainService

    // MARK: - Overridden Properties
    var cacheKey: String? {
        "notebook-notes"
    }

    let request = GetNotesQuery()

    public var scope: Scope {
        var predicates: [NSPredicate] = []
        if let courseID = courseID {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDNotebookNote.courseID), courseID))
        }
        labels?.forEach { label in
            predicates.append(NSPredicate(format: "%K CONTAINS %@", #keyPath(CDNotebookNote.labels), label))
        }
        if let pageID = pageID {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDNotebookNote.pageID), pageID))
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let order = [NSSortDescriptor(key: #keyPath(CDNotebookNote.date), ascending: false)]
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
        let fetchRequest = NSFetchRequest<CDNotebookNote>(entityName: String(describing: CDNotebookNote.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(CDNotebookNote.date), ascending: false)]

        let result = (try? client.fetch(fetchRequest)) ?? []

        let tuple = changed(redwoodNotes: response?.data.notes.edges.map { $0.node } ?? [], cdNotebookNotes: result)
        let changed = tuple.0
        let removed = tuple.1

        changed.forEach { redwoodNote in
            CDNotebookNote.save(redwoodNote, in: client)
        }

        removed.forEach { cdNotebookNote in
            client.delete(cdNotebookNote)
        }
    }

    // Returns the notes that have been added or updated in the first item, the ones that have been removed in the second item
    func changed(redwoodNotes: [RedwoodNote], cdNotebookNotes: [CDNotebookNote]) -> ([RedwoodNote], [CDNotebookNote]) {
        let redwoodNotesAddedOrUpdated = redwoodNotes.filter { redwoodNote in
            let cdNotebookNote = cdNotebookNotes.first { $0.id == redwoodNote.id }
            return cdNotebookNote?.content != redwoodNote.userText || cdNotebookNote?.labels != redwoodNote.reaction?.serializeLabels
        }
        let notebookNotesRemoved = cdNotebookNotes.filter { cdNotebookNote in
            !redwoodNotes.contains { $0.id == cdNotebookNote.id }
        }
        return (redwoodNotesAddedOrUpdated, notebookNotesRemoved)
    }
}
