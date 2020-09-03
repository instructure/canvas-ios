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

public final class Todo: NSManagedObject, WriteableModel {
    public typealias JSON = APITodo

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    @NSManaged public var assignment: Assignment
    @NSManaged var contextRaw: String
    @NSManaged public var id: String
    @NSManaged public var ignoreURL: URL?
    @NSManaged public var ignorePermanentlyURL: URL?
    @NSManaged public var needsGradingCount: UInt
    @NSManaged var typeRaw: String

    public var context: Context {
        get { return Context(canvasContextID: contextRaw) ?? .currentUser }
        set { contextRaw = newValue.canvasContextID }
    }

    public var course: Course? {
        guard context.contextType == .course else { return nil }
        return managedObjectContext?.first(where: #keyPath(Course.id), equals: context.id)
    }

    public var group: Group? {
       guard context.contextType == .group else { return nil }
       return managedObjectContext?.first(where: #keyPath(Group.id), equals: context.id)
    }

    public var type: TodoType {
        get { return TodoType(rawValue: typeRaw) ?? .submitting }
        set { typeRaw = newValue.rawValue }
    }

    public static func save(_ item: APITodo, in context: NSManagedObjectContext) -> Todo {
        let id = item.assignment.id.value
        let assignment: Assignment = context.first(where: #keyPath(Assignment.id), equals: id) ?? context.insert()
        assignment.update(fromApiModel: item.assignment, in: context, updateSubmission: false, updateScoreStatistics: false)

        let model: Todo = context.first(where: #keyPath(Todo.id), equals: id) ?? context.insert()
        model.assignment = assignment
        if let id = item.course_id?.value {
            model.context = Context(.course, id: id)
        } else if let id = item.group_id?.value {
            model.context = Context(.group, id: id)
        }
        model.id = id
        model.ignoreURL = item.ignore
        model.ignorePermanentlyURL = item.ignore_permanently
        model.needsGradingCount = item.needs_grading_count ?? 0
        model.type = item.type
        return model
    }

    public var subtitleText: String {
        switch type {
        case .submitting:
            guard let dueAt = assignment.dueAt else {
                return NSLocalizedString("No Due Date", bundle: .core, comment: "")
            }
            let format = NSLocalizedString("Due %@", bundle: .core, comment: "")
            let dueText = Todo.dateFormatter.string(from: dueAt)
            return String.localizedStringWithFormat(format, dueText)
        case .grading:
            let format = NSLocalizedString("d_needs_grading", bundle: .core, comment: "")
            return String.localizedStringWithFormat(format, needsGradingCount)
        }
    }
}

class GetTodos: CollectionUseCase {
    typealias Model = Todo

    let cacheKey: String? = nil
    let request = GetTodosRequest()
    let scope = Scope(predicate: .all, order: [
        NSSortDescriptor(key: #keyPath(Todo.assignment.dueAtSortNilsAtBottom), ascending: true),
        NSSortDescriptor(key: #keyPath(Todo.assignment.name), ascending: true, selector: #selector(NSString.localizedStandardCompare)),
    ])
}
