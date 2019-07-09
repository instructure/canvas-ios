//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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




extension Upload {
    @objc public static func inProgress(_ session: Session) throws -> [Upload] {
        let context = try session.assignmentsManagedObjectContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName(context))
        request.predicate = NSPredicate(format: "%K == nil", "terminatedAt")
        return try context.fetch(request) as? [Upload] ?? []
    }

    @objc public static func activeBackgroundSessionIdentifiers(_ session: Session) throws -> [String] {
        let context = try session.assignmentsManagedObjectContext()

        guard let entity = NSEntityDescription.entity(forEntityName: entityName(context), in: context) else {
            fatalError("Failed to get Entity Description for Upload.")
        }

        guard let property = entity.propertiesByName["backgroundSessionID"] else {
            fatalError("Failed to get backgroundSessionID property.")
        }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName(context))
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [property]
        request.returnsDistinctResults = true

        guard let ids = try context.fetch(request) as? [String] else {
            fatalError("expected an array of String ids")
        }

        return ids
    }

    @objc public static func inProgressFetch(_ session: Session, identifier: String) throws -> NSFetchRequest<Upload> {
        let context = try session.assignmentsManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@ && %K == nil", "backgroundSessionID", identifier, "terminatedAt")
        return context.fetch(predicate, sortDescriptors: ["startedAt".ascending])
    }

    @objc public static func inProgressFRC(_ session: Session, identifier: String) throws -> NSFetchedResultsController<Upload> {
        let context = try session.assignmentsManagedObjectContext()
        let request = try inProgressFetch(session, identifier: identifier)
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}
