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

final public class ModuleItem: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var courseID: String
    @NSManaged public var moduleID: String
    @NSManaged public var position: Double
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
    @NSManaged public var completedRaw: NSNumber?
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?
    @NSManaged public var masteryPathItem: ModuleItem?
    @NSManaged public var masteryPath: MasteryPath?
    @NSManaged public var moduleItem: ModuleItem? // inverse of masteryPathItem

    public var published: Bool? {
        get { return publishedRaw?.boolValue }
        set { publishedRaw = NSNumber(value: newValue) }
    }

    public var hideQuantitativeData: Bool {
        let course: Course? = managedObjectContext?.first(where: #keyPath(Course.id), equals: courseID)
        return course?.hideQuantitativeData ?? false
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

    public var visibleWhenLocked: Bool {
        switch type {
        case .assignment, .discussion, .quiz:
            return true
        default: return false
        }
    }

    public var isLocked: Bool {

        if module?.state == .completed || completed == true {
            return false
        }

        if masteryPath?.locked == true || module?.state == .locked || lockedForUser == true {
            return true
        }

        if module?.requireSequentialProgress == true && lockedForUser {
            return true
        }

        guard let prevModuleItemIsComplete = prevModuleItemIsComplete() else {
            return false
        }

        if module?.requireSequentialProgress == true && !prevModuleItemIsComplete {
            return true
        }

        return lockedForUser
    }

    private func prevModuleItemIsComplete() -> Bool? {
        if let index = module?.items.firstIndex(of: self), index > 0 {
            return module?.items[index-1].completed ?? true
        }
        return nil
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

    public var completed: Bool? {
        get { return completedRaw?.boolValue }
        set { completedRaw = NSNumber(value: newValue) }
    }

    public var completionRequirement: CompletionRequirement? {
        get {
            guard let type = completionRequirementType else { return nil }
            return CompletionRequirement(type: type, completed: completed, min_score: minScore)
        }
        set {
            completionRequirementType = newValue?.type
            completed = newValue?.completed
            minScore = newValue?.min_score
        }
    }

    @discardableResult
    public static func save(_ item: APIModuleItem,
                            forCourse courseID: String,
                            updateMasteryPath: Bool = true,
                            in context: NSManagedObjectContext) -> ModuleItem {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(ModuleItem.courseID), equals: courseID),
            NSPredicate(key: #keyPath(ModuleItem.id), equals: item.id.value),
        ])
        let model: ModuleItem = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.moduleID = item.module_id.value
        model.position = Double(item.position)
        model.title = item.title
        model.indent = item.indent
        model.htmlURL = item.html_url
        model.url = item.url
        model.published = item.published
        model.type = item.content
        model.pointsPossible = item.content_details?.points_possible
        model.dueAt = item.content_details?.due_at
        model.lockedForUser = item.content_details?.locked_for_user == true
        model.lockExplanation = item.content_details?.lock_explanation
        model.completionRequirement = item.completion_requirement
        model.courseID = courseID

        if updateMasteryPath {
            if let masteryPath = item.mastery_paths, masteryPath.selected_set_id == nil {
                let path: ModuleItem = context.insert()
                path.id = "\(item.id)-mastery-path"
                path.courseID = courseID
                path.moduleID = item.module_id.value
                path.position = Double(item.position) + 0.5
                path.title = item.mastery_paths?.locked == true
                    ? String.localizedStringWithFormat(NSLocalizedString("Locked until \"%@\" is graded", comment: ""), item.title)
                    : NSLocalizedString("Select a Path", comment: "")
                path.indent = item.indent
                path.type = item.content
                path.masteryPath = MasteryPath.save(masteryPath, in: context)
                model.masteryPathItem = path
            } else {
                if let masteryPathItem = model.masteryPathItem {
                    context.delete(masteryPathItem)
                }
                model.masteryPathItem = nil
            }
        }

        return model
    }
}
