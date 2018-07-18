//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    


import CoreData




extension Upload {
    public static func inProgress(_ session: Session) throws -> [Upload] {
        let context = try session.assignmentsManagedObjectContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName(context))
        request.predicate = NSPredicate(format: "%K == nil", "terminatedAt")
        return try context.fetch(request) as? [Upload] ?? []
    }

    public static func activeBackgroundSessionIdentifiers(_ session: Session) throws -> [String] {
        let context = try session.assignmentsManagedObjectContext()

        guard let entity = NSEntityDescription.entity(forEntityName: entityName(context), in: context) else {
            ❨╯°□°❩╯⌢"Failed to get Entity Description for Upload."
        }

        guard let property = entity.propertiesByName["backgroundSessionID"] else {
            ❨╯°□°❩╯⌢"Failed to get backgroundSessionID property."
        }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName(context))
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [property]
        request.returnsDistinctResults = true

        guard let ids = try context.fetch(request) as? [String] else {
            ❨╯°□°❩╯⌢"expected an array of String ids"
        }

        return ids
    }

    public static func inProgressFetch(_ session: Session, identifier: String) throws -> NSFetchRequest<Upload> {
        let context = try session.assignmentsManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@ && %K == nil", "backgroundSessionID", identifier, "terminatedAt")
        return context.fetch(predicate, sortDescriptors: ["startedAt".ascending])
    }

    public static func inProgressFRC(_ session: Session, identifier: String) throws -> NSFetchedResultsController<Upload> {
        let context = try session.assignmentsManagedObjectContext()
        let request = try inProgressFetch(session, identifier: identifier)
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}
