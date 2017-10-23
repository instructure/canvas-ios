//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
