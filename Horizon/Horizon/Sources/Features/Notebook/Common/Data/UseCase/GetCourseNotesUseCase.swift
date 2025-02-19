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

class GetCourseNotesUseCase: APIUseCase {
    typealias Model = CourseNote
    typealias Request = GetNotesQuery

    // MARK: - Properties

    private let api: API
    private let id: String?
    private let highlightsKey: String?
    private let labels: [CourseNoteLabel]?
    var cacheKey: String? {
        return after
    }
    private let searchTerm: String?
    private let after: String?

    var request: GetNotesQuery {
        .init(jwt: api.loginSession?.accessToken ?? "", after: after)
    }

    var scope: Scope {
        let order = [NSSortDescriptor(key: #keyPath(CourseNote.date), ascending: false)]
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
        let searchTermPredicate = searchTerm?.isEmpty == true ? nil : searchTerm.map {
            NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(CourseNote.content), $0)
        }
        let predicates: [NSPredicate] = [
            highlightKeyPredicate,
            idPredicate,
            reactionsPredicate,
            searchTermPredicate
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
        searchTerm: String? = nil,
        after: String? = nil
    ) {
        self.api = api
        self.id = id
        self.highlightsKey = highlightsKey
        self.labels = labels
        self.searchTerm = searchTerm
        self.after = after
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

        // delete all notes that do not come back in the response if we don't have any filters applied
        if id == nil && highlightsKey == nil && (labels == nil || labels?.isEmpty == true) {
            let idsReturned = response?.data.notes.nodes.map(\.id) ?? []
            let notesToDelete: [CourseNote] = client.fetch(NSPredicate(format: "NOT %K IN %@", #keyPath(CourseNote.id), idsReturned))
            client.delete(notesToDelete)
        }

        response?.data.notes.nodes.forEach {
            CourseNote.save($0, in: client)
        }
    }
}
