//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
import CoreData

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

public class MasteryPath: NSManagedObject {
    @NSManaged public var locked: Bool
    @NSManaged public var assignmentSets: Set<MasteryPathAssignmentSet>

    public static func save(_ item: APIMasteryPath, in context: NSManagedObjectContext) -> MasteryPath {
        let model = context.insert() as MasteryPath
        model.locked = item.locked
        model.assignmentSets = Set(item.assignment_sets.map { .save($0, in: context) })
        return model
    }
}

public class MasteryPathAssignmentSet: NSManagedObject {
    @NSManaged public var assignments: Set<MasteryPathAssignment>

    public static func save(_ item: APIMasteryPath.AssignmentSet, in context: NSManagedObjectContext) -> MasteryPathAssignmentSet {
        let model = context.insert() as MasteryPathAssignmentSet
        model.assignments = Set(item.assignments.map { .save($0, in: context) })
        return model
    }
}

public class MasteryPathAssignment: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var pointsPossible: NSNumber?

    public static func save(_ item: APIAssignment, in context: NSManagedObjectContext) -> MasteryPathAssignment {
        let model = context.insert() as MasteryPathAssignment
        model.id = item.id.value
        model.name = item.name
        model.pointsPossible = NSNumber(value: item.points_possible)
        return model
    }
}

public class ModuleItem: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var courseID: String
    @NSManaged public var moduleID: String
    @NSManaged public var position: Int
    @NSManaged public var title: String
    @NSManaged public var indent: Int
    @NSManaged public var htmlURL: URL?
    @NSManaged public var url: URL?
    @NSManaged public var publishedRaw: NSNumber?
    @NSManaged public var typeRaw: Data?
    @NSManaged public var module: Module?
    @NSManaged public var dueAt: Date?
    @NSManaged public var pointsPossibleRaw: NSNumber?
    @NSManaged public var completionRequirementTypeRaw: String?
    @NSManaged public var minScoreRaw: NSNumber?
    @NSManaged public var completed: Bool
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?

    public var published: Bool? {
        get { return publishedRaw?.boolValue }
        set { publishedRaw = NSNumber(value: newValue) }
    }

    public var type: ModuleItemType? {
        get {
            if let data = typeRaw {
                return try? decoder.decode(ModuleItemType.self, from: data)
            }
            return nil
        }
        set { typeRaw = try? encoder.encode(newValue) }
    }

    public var isAssignment: Bool {
        if case .assignment(_) = type {
            return true
        }
        return false
    }

    public var pointsPossible: Double? {
        get { return pointsPossibleRaw?.doubleValue }
        set { pointsPossibleRaw = NSNumber(value: newValue) }
    }

    public var completionRequirementType: CompletionRequirementType? {
        get { return completionRequirementTypeRaw.flatMap { CompletionRequirementType(rawValue: $0) } }
        set { completionRequirementTypeRaw = newValue?.rawValue }
    }

    public var minScore: Double? {
        get { return minScoreRaw?.doubleValue }
        set { minScoreRaw = NSNumber(value: newValue) }
    }

    public var completionRequirement: CompletionRequirement? {
        get {
            guard let type = completionRequirementType else { return nil }
            return CompletionRequirement(type: type, completed: completed, min_score: minScore)
        }
        set {
            completionRequirementType = newValue?.type
            completed = newValue?.completed ?? false
            minScore = newValue?.min_score
        }
    }

    @discardableResult
    public static func save(_ item: APIModuleItem, forCourse courseID: String, in context: NSManagedObjectContext) -> ModuleItem {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(ModuleItem.courseID), equals: courseID),
            NSPredicate(key: #keyPath(ModuleItem.id), equals: item.id.value),
        ])
        let model: ModuleItem = context.fetch(predicate).first ?? context.insert()
        model.update(item)
        model.courseID = courseID
        return model
    }

    func update(_ item: APIModuleItem) {
        id = item.id.value
        moduleID = item.module_id.value
        position = item.position
        title = item.title
        indent = item.indent
        htmlURL = item.html_url
        url = item.url
        published = item.published
        type = item.content
        pointsPossible = item.content_details?.points_possible
        dueAt = item.content_details?.due_at
        lockedForUser = item.content_details?.locked_for_user == true
        lockExplanation = item.content_details?.lock_explanation
        completionRequirement = item.completion_requirement
    }
}
