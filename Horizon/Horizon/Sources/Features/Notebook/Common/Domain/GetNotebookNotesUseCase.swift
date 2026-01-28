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

final class GetNotebookNotesUseCase: CollectionUseCase {
    typealias Model = CDHNotebookNote

    // MARK: - Dependencies

    private let redwood: DomainServiceProtocol
    private let filter: NotebookQueryFilter

    // MARK: - Properties

    var cacheKey: String? { "notebook-notes" }
    var request: GetNotesQuery { GetNotesQuery() }

    public var scope: Scope {
        var predicates: [NSPredicate] = [
            NSPredicate(format: "%K == %@", #keyPath(CDHNotebookNote.userID), Context.currentUser.id)
        ]
        if let courseID = filter.courseId {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDHNotebookNote.courseID), courseID))
        }
        if let reactions = filter.reactions {
            reactions.forEach { label in
                predicates.append(NSPredicate(format: "%K CONTAINS %@", #keyPath(CDHNotebookNote.labels), label))
            }
        }
        if let pageID = filter.pageId {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(CDHNotebookNote.pageID), pageID))
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let order = [NSSortDescriptor(key: #keyPath(CDHNotebookNote.date), ascending: false)]
        return Scope(predicate: predicate, order: order)
    }

    // MARK: - Private Properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        filter: NotebookQueryFilter,
        redwood: DomainServiceProtocol = DomainService(),
    ) {
        self.filter = filter
        self.redwood = redwood
    }

    // MARK: - Overridden Methods

    func makeRequest(
        environment: AppEnvironment,
        completionHandler: @escaping ([RedwoodFetchNotesQueryResponse.ResponseEdge]?, URLResponse?, Error?) -> Void
    ) {
        redwood
            .api()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] api in
                    guard let self = self else { return }
                    api.exhaust(self.request, callback: completionHandler)
                }
            )
            .store(in: &subscriptions)
    }

    func write(
        response: [RedwoodFetchNotesQueryResponse.ResponseEdge]?,
        urlResponse _: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        let notes = response?.map { $0.node } ?? []
        notes.forEach { redwoodNote in
            CDHNotebookNote.save(
                redwoodNote,
                userID: Context.currentUser.id,
                in: client
            )
        }
    }
}
