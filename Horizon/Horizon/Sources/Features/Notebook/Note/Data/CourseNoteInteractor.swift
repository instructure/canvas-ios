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

import Combine
import Core
import CoreData

enum NotebookError: Error {
    case unknown
}

struct NotebookHighlight {
    /// The NotebookNoteIndex is used to index where an annotation belongs
    /// The highlightKey is globally unique to the block of text that's being highlighted. This for example might be a single paragraph. It may have multiple highlights.
    /// The startIndex is the index of the first character in the highlight
    /// The length is the number of characters in the highlight
    let highlightKey: String
    let startIndex: Int
    let length: Int
    let highlightedText: String
}

protocol CourseNoteInteractor {
    func add(
        courseId: String,
        moduleId: String,
        moduleType: ModuleItemType,
        content: String,
        labels: [CourseNoteLabel],
        index: NotebookHighlight
    ) -> AnyPublisher<CourseNote, NotebookError>
    func delete(id: String) -> AnyPublisher<CourseNote, NotebookError>
    func get(highlightsKey: String) -> AnyPublisher<[CourseNote], NotebookError>
    func get(id: String) -> AnyPublisher<CourseNote?, NotebookError>
    func set(id: String, content: String?, labels: [CourseNoteLabel]?) -> AnyPublisher<CourseNote?, NotebookError>
}

class CourseNoteInteractorLive: CourseNoteInteractor {

    // MARK: - Dependencies

    private let canvasApi: API

    // MARK: - Init

    init(canvasApi: API = AppEnvironment.shared.api) {
        self.canvasApi = canvasApi
    }

    // MARK: - Public

    func add(
        courseId: String,
        moduleId: String,
        moduleType: ModuleItemType,
        content: String = "",
        labels: [CourseNoteLabel] = [],
        index: NotebookHighlight
    ) -> AnyPublisher<CourseNote, NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap { api in
                ReactiveStore(
                    useCase: CreateCourseNoteUseCase(
                        api: api,
                        courseId: courseId,
                        moduleId: moduleId,
                        moduleType: moduleType.courseNoteLabel,
                        userText: content,
                        reactions: labels.map { $0.rawValue }
                    )
                )
                .getEntities()
                .mapError { _ in NotebookError.unknown }
                .compactMap { $0.first }
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }

    func delete(id: String) -> AnyPublisher<CourseNote, NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap { api in
                ReactiveStore(useCase: DeleteCourseNoteUseCase(api: api, id: id))
                    .getEntities()
                    .mapError { _ in NotebookError.unknown }
                    .compactMap { $0.first }
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }

    func get(id: String) -> AnyPublisher<CourseNote?, NotebookError> {
        fetch(id: id)
            .map(\.first)
            .eraseToAnyPublisher()
    }

    func get(highlightsKey: String) -> AnyPublisher<[CourseNote], NotebookError> {
        fetch(highlightsKey: highlightsKey)
    }

    func set(id: String, content: String?, labels: [CourseNoteLabel]?) -> AnyPublisher<CourseNote?, NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap { api in
                ReactiveStore(
                    useCase: UpdateCourseNoteUseCase(
                        api: api,
                        id: id,
                        userText: content ?? "",
                        reactions: labels?.map { $0.rawValue } ?? []
                    )
                )
                .getEntities()
                .mapError { _ in NotebookError.unknown }
                .compactMap { $0.first }
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func fetch(id: String? = nil, highlightsKey: String? = nil) -> AnyPublisher<[CourseNote], NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap { api in
                ReactiveStore(useCase: GetCourseNotesUseCase(api: api, id: id, highlightsKey: highlightsKey))
                    .getEntities()
                    .eraseToAnyPublisher()
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }
}

extension ModuleItemType {
    var courseNoteLabel: String {
        switch self {
        case .file:
            return "file"
        case .discussion:
            return "discussion"
        case .assignment:
            return "assignment"
        case .quiz:
            return "quiz"
        case .externalURL:
            return "externalURL"
        case .externalTool:
            return "externalTool"
        case .page:
            return "page"
        case .subHeader:
            return "subHeader"
        }
    }
}

extension CourseNote {
    @discardableResult
    public static func save(_ note: RedwoodNote, in context: NSManagedObjectContext) -> CourseNote {
        let firstCourseNote: CourseNote? = context.first(where: #keyPath(CourseNote.id), equals: note.id)
        let courseNote: CourseNote = firstCourseNote ?? NSEntityDescription.insertNewObject(forEntityName: "CourseNote", into: context) as? CourseNote ?? CourseNote()
        courseNote.id = note.id
        courseNote.date = note.createdAt
        courseNote.content = note.userText
        courseNote.courseID = note.courseId
        courseNote.date = note.createdAt
//        courseNote.highlightKey = note.highlightKey // COMING SOON!
//        courseNote.highlightedText = note.highlightedText
        courseNote.labels = (note.reaction ?? []).joined(separator: ";")
//        courseNote.length = note.length
//        courseNote.startIndex = note.startIndex
        return courseNote
    }

    public static func delete(id: String, in context: NSManagedObjectContext) {
        if let courseNote: CourseNote = context.first(where: #keyPath(CourseNote.id), equals: id) {
            context.delete(courseNote)
        }
    }
}

class CourseNoteInteractorPreview: CourseNoteInteractor {
    func add(
        courseId: String,
        moduleId: String,
        moduleType: ModuleItemType,
        content: String = "",
        labels: [CourseNoteLabel] = [],
        index: NotebookHighlight
    ) -> AnyPublisher<CourseNote, NotebookError> {
        Just(CourseNote())
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }

    func delete(id: String) -> AnyPublisher<CourseNote, NotebookError> {
        Just(CourseNote())
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }

    func get(id: String) -> AnyPublisher<CourseNote?, NotebookError> {
        Just(nil)
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }

    func get(highlightsKey: String) -> AnyPublisher<[CourseNote], NotebookError> {
        Just([])
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }

    func set(id: String, content: String?, labels: [CourseNoteLabel]?) -> AnyPublisher<CourseNote?, NotebookError> {
        Just(nil)
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }
}
