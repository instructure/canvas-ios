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

class DeleteCourseNoteUseCase: APIUseCase {

    var cacheKey: String?

    typealias Request = RedwoodDeleteNoteMutation
    typealias Model = CourseNote

    private let api: API
    private let id: String

    var scope: Scope {
        Scope(predicate: NSPredicate(format: "%K == %@", #keyPath(CourseNote.id), id), order: [])
    }

    var request: RedwoodDeleteNoteMutation {
        return RedwoodDeleteNoteMutation(jwt: api.loginSession?.accessToken ?? "", id: id)
    }

    init(api: API, id: String) {
        self.api = api
        self.id = id
    }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping (Response?, URLResponse?, Error?) -> Void) {
        api.makeRequest(request, callback: completionHandler)
    }

    func write(response: RedwoodDeleteNoteMutationResponse?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        if let id = response?.data.deleteNote {
            CourseNote.delete(id: id, in: client)
        }
    }
}
