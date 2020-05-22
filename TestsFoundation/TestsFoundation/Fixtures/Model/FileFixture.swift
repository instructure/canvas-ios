//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import CoreData
import Foundation
@testable import Core

extension File {
    @discardableResult
    public static func make(
        from api: APIFile = .make(),
        assignmentID: String? = nil,
        batchID: String? = nil,
        bytesSent: Int = 0,
        courseID: String? = nil,
        removeID: Bool = false,
        removeURL: Bool = false,
        taskID: String? = nil,
        userID: String? = nil,
        uploadError: String? = nil,
        session: LoginSession? = nil,
        in context: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> File {
        let model = File.save(api, in: context)
        model.batchID = batchID
        model.bytesSent = bytesSent
        if let assignmentID = assignmentID, let courseID = courseID {
            model.prepareForSubmission(courseID: courseID, assignmentID: assignmentID)
        }
        if removeID {
            model.id = nil
        }
        if removeURL {
            model.url = nil
        }
        if let session = session {
            model.setUser(session: session)
        }
        model.taskID = taskID
        model.uploadError = uploadError

        if let userID = userID {
            let u = File.User(id: userID, baseURL: URL(string: "localhost")!, masquerader: nil)
            model.user = u
        }

        try! context.save()
        return model
    }
}
