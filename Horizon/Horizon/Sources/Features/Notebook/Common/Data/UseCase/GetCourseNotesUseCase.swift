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

/// Cursor to paginate the notes
/// If previous is set, it'll get the prior results
/// If next is set, it'll get the next results
struct Cursor {
    let cursor: String
    let isBefore: Bool // if it's not before, it's "after"

    init(previous cursor: String) {
        self.cursor = cursor
        isBefore = true
    }

    init(next cursor: String) {
        self.cursor = cursor
        isBefore = false
    }
}

class GetCourseNotesUseCase: APIUseCase {
    typealias Model = CourseNote
    typealias Request = GetNotesQuery

    // MARK: - Properties
    private static let pageSize = 10
    private let api: API
    private let id: String?
    private let highlightsKey: String?
    private let labels: [CourseNoteLabel]?

    var cacheKey: String?

    private let cursor: Cursor?

    var request: GetNotesQuery {
        let accessToken = api.loginSession?.accessToken ?? ""
        let reactions = labels?.map(\.rawValue)

        guard let cursorValue = cursor?.cursor else {
            return .init(jwt: accessToken, reactions: reactions)
        }
        if cursor?.isBefore == true {
            return .init(
                jwt: accessToken,
                before: cursorValue,
                reactions: reactions
            )
        }
        return .init(
            jwt: accessToken,
            after: cursorValue,
            reactions: reactions
        )
    }

    var scope: Scope {
        let order = [NSSortDescriptor(key: #keyPath(CourseNote.date), ascending: true)]
        let highlightKeyPredicate = highlightsKey.map {
            NSPredicate(format: "%K == %@", #keyPath(CourseNote.highlightKey), $0)
        }
        let idPredicate = id.map {
            NSPredicate(format: "%K == %@", #keyPath(CourseNote.id), $0)
        }
        var reactionsPredicate: NSPredicate?
        if let labels = labels, labels.count > 0 {
            reactionsPredicate = NSCompoundPredicate(
                type: .or,
                subpredicates: labels.map { label in
                    NSPredicate(format: "%K CONTAINS %@", #keyPath(CourseNote.labels), label.rawValue)
                }
            )
        }

        let predicates: [NSPredicate] = [
            highlightKeyPredicate,
            idPredicate,
            reactionsPredicate
        ].compactMap { $0 }
        let predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        return Scope(predicate: predicate, order: order)
    }

    // MARK: - Init

    init(
        api: API,
        id: String? = nil,
        highlightsKey: String? = nil,
        labels: [CourseNoteLabel]? = nil,
        cursor: Cursor? = nil
    ) {
        self.api = api
        self.id = id
        self.highlightsKey = highlightsKey
        self.labels = labels
        self.cursor = cursor
    }

    // MARK: - Methods

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping (Response?, URLResponse?, Error?) -> Void) {
        api.makeRequest(request, callback: completionHandler)
    }

    func write(
        response: RedwoodFetchNotesQueryResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        // If not filtering by id or highlightsKey, delete all notes that are not in the response
        if id == nil && highlightsKey == nil {
            let idsReturned = response?.data.notes.edges.map { $0.node.id } ?? []
            let notesToDelete: [CourseNote] = client.fetch(NSPredicate(format: "NOT %K IN %@", #keyPath(CourseNote.id), idsReturned))
            client.delete(notesToDelete)
        }

        if let responseNotes = response?.data.notes {
            CourseNote.save(responseNotes, in: client)
        }
    }
}
