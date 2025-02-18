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

class UpdateCourseNoteUseCase: APIUseCase {
    var cacheKey: String?

    typealias Request = RedwoodUpdateNoteMutation
    typealias Model = CourseNote

    // MARK: - Properties
    let api: API
    let id: String
    let userText: String
    let reaction: [String]

    var request: RedwoodUpdateNoteMutation {
        RedwoodUpdateNoteMutation(jwt: api.loginSession?.accessToken ?? "", id: id, userText: userText, reaction: reaction)
    }

    public var scope: Scope {
        return Scope.all(orderBy: #keyPath(CourseNote.date), ascending: false)
    }

    // MARK: - Init

    public init(api: API, id: String, userText: String = "", reactions: [String] = []) {
        self.api = api
        self.id = id
        self.userText = userText
        self.reaction = reactions
    }

    // MARK: - Methods

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping (Response?, URLResponse?, Error?) -> Void) {
        api.makeRequest(request, callback: completionHandler)
    }

    public func write(
        response: RedwoodUpdateNoteMutationResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        if let note = response?.data.updateNote {
            CourseNote.save(note, in: client)
        }
    }
}
