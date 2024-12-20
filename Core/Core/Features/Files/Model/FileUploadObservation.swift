//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

 extension UploadManager {
     public typealias Store = Core.Store<LocalUseCase<File>>

    /**
     - returns: A local Store observing files for the current user where `batchID` matches the one received in parameter. Files are ordered by size, ascending.
     */
     public func subscribe(batchID: String, eventHandler: @escaping Store.EventHandler) -> Store {
        let scope = Scope(predicate: filesPredicate(batchID: batchID), order: [NSSortDescriptor(key: #keyPath(File.size), ascending: true)])
        let useCase = LocalUseCase<File>(scope: scope)
        return Store(env: environment, database: database, useCase: useCase, eventHandler: eventHandler)
    }

    /**
     - returns: A predicate that filters files where `userID` matches the user currently logged in and `batchID` matches the one received in parameter.
     */
    public func filesPredicate(batchID: String) -> NSPredicate {
        let user = environment.currentSession.flatMap { NSPredicate(format: "%K == %@", #keyPath(File.userID), $0.userID) } ?? .all
        return predicate(userPredicate: user, batchID: batchID)
    }

    func predicate(userID: String, batchID: String) -> NSPredicate {
        let user = NSPredicate(format: "%K == %@", #keyPath(File.userID), userID)
        return predicate(userPredicate: user, batchID: batchID)
    }

    func predicate(userPredicate: NSPredicate, batchID: String) -> NSPredicate {
        let batch = NSPredicate(format: "%K == %@", #keyPath(File.batchID), batchID)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, batch])
    }
}
