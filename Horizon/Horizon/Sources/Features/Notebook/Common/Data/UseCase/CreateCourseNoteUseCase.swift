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

class CreateCourseNoteUseCase: APIUseCase {
    var cacheKey: String?

    typealias Request = RedwoodCreateNoteMutation
    typealias Model = CourseNote

    // MARK: - Properties
    private let api: API
    private let courseId: String
    private let moduleId: String
    private let moduleType: String
    private let userText: String
    private let reactions: [String]

    var request: RedwoodCreateNoteMutation {
        RedwoodCreateNoteMutation(
            jwt: api.loginSession?.accessToken ?? "",
            note: NewCourseNote(
                courseId: self.courseId,
                objectId: self.moduleId,
                objectType: self.moduleType,
                userText: self.userText,
                reaction: self.reactions
            )
        )
    }

    var scope: Scope {
        return Scope.all(orderBy: #keyPath(CourseNote.date), ascending: false)
    }

    // MARK: - Init

    public init(
        api: API,
        courseId: String,
        moduleId: String,
        moduleType: String,
        userText: String,
        reactions: [String]
    ) {
        self.api = api
        self.courseId = courseId
        self.moduleId = moduleId
        self.moduleType = moduleType
        self.userText = userText
        self.reactions = reactions
    }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping (Response?, URLResponse?, Error?) -> Void) {
        api.makeRequest(request, callback: completionHandler)
    }

    public func write(
        response: RedwoodCreateNoteMutationResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        if let note = response?.data.createNote {
            CourseNote.save(note, in: client)
        }
    }
}
