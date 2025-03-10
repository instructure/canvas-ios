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

import CoreData
import Foundation
import UIKit

public final class Todo: NSManagedObject, WriteableModel {
    public typealias JSON = APITodo
    @NSManaged public var assignment: Assignment?
    @NSManaged public var quiz: Quiz?
    @NSManaged var contextRaw: String
    @NSManaged public var course: Course?
    @NSManaged public var group: Group?
    @NSManaged public var id: String
    @NSManaged public var ignoreURL: URL?
    @NSManaged public var ignorePermanentlyURL: URL?
    @NSManaged public var needsGradingCount: UInt
    @NSManaged public var name: String?
    @NSManaged public var dueAtSortNilsAtBottom: Date
    @NSManaged var typeRaw: String

    public var context: Context {
        get { return Context(canvasContextID: contextRaw) ?? .currentUser }
        set { contextRaw = newValue.canvasContextID }
    }

    public var contextColor: UIColor? { getCourse()?.color ?? getGroup()?.color }
    public var contextName: String? { getCourse()?.name ?? getGroup()?.name }

    public var type: TodoType {
        get { return TodoType(rawValue: typeRaw) ?? .submitting }
        set { typeRaw = newValue.rawValue }
    }

    public var assignmentOrQuizID: String? {
        if let assignment {
            return assignment.id
        } else if let quiz {
            return quiz.id
        } else {
            return nil
        }
    }

    public var icon: UIImage? {
        if let assignment {
            return assignment.icon
        } else if quiz != nil {
            return .quizLine
        } else {
            return nil
        }
    }

    public var isPublished: Bool? {
        if let assignment {
            return assignment.published
        } else if let quiz {
            return quiz.published
        } else {
            return nil
        }
    }

    public var htmlURL: URL? {
        if let assignment {
            return assignment.htmlURL
        } else if let quiz {
            return quiz.htmlURL
        } else {
            return nil
        }
    }

    public var dueAt: Date? {
        if let assignmentDueAt = assignment?.dueAt {
            return assignmentDueAt
        } else if let quizDueAt = quiz?.dueAt {
            return quizDueAt
        } else {
            return nil
        }
    }

    public var dueText: String {
        guard let dueAt else {
            return String(localized: "No Due Date", bundle: .core)
        }
        let format = String(localized: "Due %@", bundle: .core)
        return String.localizedStringWithFormat(format, dueAt.relativeDateTimeStringWithDayOfWeek)
    }

    func getCourse() -> Course? {
        if context.contextType == .course, course == nil, let fetchedCourse: Course = managedObjectContext?.first(where: #keyPath(Course.id), equals: context.id) {
            course = fetchedCourse
        }
        return course
    }

    func getGroup() -> Group? {
        if context.contextType == .group, group == nil, let fetchedGroup: Group = managedObjectContext?.first(where: #keyPath(Group.id), equals: context.id) {
            group = fetchedGroup
        }
        return group
    }

    public static func save(_ item: APITodo, in context: NSManagedObjectContext) -> Todo {
        let id = item.assignment?.id.value ?? item.quiz?.id.value ?? UUID.string
        let model: Todo = context.first(where: #keyPath(Todo.id), equals: id) ?? context.insert()

        if let apiAssignment = item.assignment {
            let assignment: Assignment = context.first(where: (\Assignment.id).string, equals: id) ?? context.insert()
            assignment.update(fromApiModel: apiAssignment, in: context, updateSubmission: false, updateScoreStatistics: false)
            model.assignment = assignment
            model.name = assignment.name
            model.dueAtSortNilsAtBottom = assignment.dueAt ?? .distantFuture
        } else if let apiQuiz = item.quiz {
            let quiz: Quiz = Quiz.save(apiQuiz, in: context)
            quiz.courseID = item.course_id?.value ?? "unknown"
            model.quiz = quiz
            model.name = quiz.title
            model.dueAtSortNilsAtBottom = quiz.dueAt ?? .distantFuture
        }

        if let id = item.course_id?.value {
            model.context = Context(.course, id: id)
            model.course = context.first(where: #keyPath(Course.id), equals: id)
        } else if let id = item.group_id?.value {
            model.context = Context(.group, id: id)
            model.group = context.first(where: #keyPath(Group.id), equals: id)
        }
        model.id = id
        model.ignoreURL = item.ignore
        model.ignorePermanentlyURL = item.ignore_permanently
        model.needsGradingCount = item.needs_grading_count ?? 0
        model.type = item.type
        return model
    }

    public var needsGradingText: String {
        let format = String(localized: "d_needs_grading", bundle: .core)
        return String.localizedStringWithFormat(format, needsGradingCount).localizedUppercase
    }
}

class GetTodos: CollectionUseCase {
    typealias Model = Todo
    typealias Response = Request.Response

    let type: TodoType?
    var cacheKey: String? { nil }
    var request: GetTodosRequest { GetTodosRequest() }
    var todoPredicate: NSPredicate {
        guard let type = type else {
            return .all
        }
        return NSPredicate(format: "%K == %@", #keyPath(Todo.typeRaw), type.rawValue)
    }
    var scope: Scope { Scope(predicate: todoPredicate, order: [
        NSSortDescriptor(key: #keyPath(Todo.dueAtSortNilsAtBottom), ascending: true),
        NSSortDescriptor(key: #keyPath(Todo.name), ascending: true)
    ]) }

    init(_ type: TodoType? = nil) {
        self.type = type
    }
}

class DeleteTodo: DeleteUseCase {
    typealias Model = Todo
    typealias Response = APINoContent

    let id: String
    let ignoreURL: URL
    init(id: String, ignoreURL: URL) {
        self.id = id
        self.ignoreURL = ignoreURL
    }

    var cacheKey: String? { nil }
    var request: DeleteTodoRequest { DeleteTodoRequest(ignoreURL: ignoreURL) }
    var scope: Scope { .where(#keyPath(Todo.id), equals: id) }
}

public enum TodoType: String, Codable {
    case grading, submitting
}
