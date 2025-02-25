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
        itemId: String,
        moduleType: ModuleItemType,
        content: String,
        labels: [CourseNoteLabel],
        index: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError>
    func delete(id: String) -> AnyPublisher<Void, NotebookError>
    func set(id: String, content: String?, labels: [CourseNoteLabel]?, index: NotebookHighlight?) -> AnyPublisher<CourseNotebookNote, NotebookError>
}

extension API {
    func makeRequest<Request: APIRequestable>(_ requestable: Request) -> AnyPublisher<Request.Response?, Error> {
        let apiResponseSubject = PassthroughSubject<Request.Response?, Error>()
        makeRequest(requestable) { response, _, _ in
            apiResponseSubject.send(response)
        }
        return apiResponseSubject.eraseToAnyPublisher()
    }
}

class CourseNoteInteractorLive: CourseNoteInteractor {

    // MARK: - Dependencies

    private let canvasApi: API
    private let getCourseNotesInteractor: GetCourseNotesInteractor

    // MARK: - Init

    init(
        canvasApi: API = AppEnvironment.shared.api,
        getCourseNotesInteractor: GetCourseNotesInteractor = GetCourseNotesInteractorLive.instance
    ) {
        self.canvasApi = canvasApi
        self.getCourseNotesInteractor = getCourseNotesInteractor
    }

    // MARK: - Public

    func add(
        courseId: String,
        itemId: String,
        moduleType: ModuleItemType,
        content: String = "",
        labels: [CourseNoteLabel] = [],
        index: NotebookHighlight? = nil
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap { api in
                api.makeRequest(
                    RedwoodCreateNoteMutation(
                        jwt: api.loginSession?.accessToken ?? "",
                        note: NewRedwoodNote(
                            courseId: courseId,
                            objectId: itemId,
                            objectType: moduleType.courseNoteLabel,
                            userText: content,
                            reaction: labels.map { $0.rawValue },
                            highlightKey: index?.highlightKey,
                            highlightedText: index?.highlightedText,
                            length: index?.length,
                            startIndex: index?.startIndex
                        )
                    )
                )
                .compactMap { [weak self] (response: RedwoodCreateNoteMutationResponse?) in
                    self?.getCourseNotesInteractor.refresh()

                    return response.map { CourseNotebookNote(from: $0.data.createNote) }
                }
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }

    func delete(id: String) -> AnyPublisher<Void, NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap { api in
                api.makeRequest(
                    RedwoodDeleteNoteMutation(
                        jwt: api.loginSession?.accessToken ?? "",
                        id: id
                    )
                )
                .compactMap { [weak self] _ in
                    self?.getCourseNotesInteractor.refresh()
                    return ()
                }
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }

    func set(
        id: String,
        content: String?,
        labels: [CourseNoteLabel]?,
        index: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap { api in
                api.makeRequest(
                    RedwoodUpdateNoteMutation(
                        jwt: api.loginSession?.accessToken ?? "",
                        id: id,
                        userText: content ?? "",
                        reaction: labels?.map { $0.rawValue } ?? [],
                        highlightKey: index?.highlightKey,
                        highlightedText: index?.highlightedText,
                        length: index?.length,
                        startIndex: index?.startIndex
                    )
                )
                .compactMap { [weak self] (response: RedwoodUpdateNoteMutationResponse?) in
                    self?.getCourseNotesInteractor.refresh()
                    return response.map { CourseNotebookNote(from: $0.data.updateNote) }
                }
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
    public static func save(
        _ responseNotes: RedwoodFetchNotesQueryResponse.ResponseNotes,
        in context: NSManagedObjectContext
    ) -> [CourseNote] {
        let hasNextPage = responseNotes.pageInfo.hasNextPage
        let hasPreviousPage = responseNotes.pageInfo.hasPreviousPage

        let courseNotes = responseNotes
            .edges
//            .sorted { $0.node.createdAt ?? Date() > $1.node.createdAt ?? Date() }
            .enumerated()
            .map { index, responseEdge in
            let note = responseEdge.node
            let cursor = responseEdge.cursor
            let hasMore = (hasPreviousPage && index == 0) || (hasNextPage && index == responseNotes.edges.count - 1)
            return save(
                note,
                in: context,
                cursor: cursor,
                hasMore: hasMore
            )
        }

        return courseNotes
    }

    @discardableResult
    public static func save(
        _ note: RedwoodNote,
        in context: NSManagedObjectContext,
        cursor: String? = nil,
        hasMore: Bool? = nil
    ) -> CourseNote {
        let firstCourseNote: CourseNote? = context.first(where: #keyPath(CourseNote.id), equals: note.id)
        let courseNote: CourseNote = firstCourseNote ?? NSEntityDescription.insertNewObject(forEntityName: "CourseNote", into: context) as? CourseNote ?? CourseNote()
        courseNote.id = note.id ?? ""
        courseNote.date = note.createdAt ?? Date()
        courseNote.content = note.userText
        courseNote.courseID = note.courseId
        courseNote.highlightKey = note.highlightKey
        courseNote.highlightedText = note.highlightedText
        courseNote.labels = (note.reaction ?? []).joined(separator: ";")
        courseNote.length = note.length.map { NSNumber(value: $0) }
        courseNote.startIndex = note.startIndex.map { NSNumber(value: $0) }
        if let hasMore = hasMore {
            courseNote.hasMoreBool = hasMore
        }
        if let cursor = cursor {
            courseNote.cursor = cursor
        }
        return courseNote
    }

    public static func delete(id: String, in context: NSManagedObjectContext) {
        if let courseNote: CourseNote = context.first(where: #keyPath(CourseNote.id), equals: id) {
            context.delete(courseNote)
        }
    }
}

extension CourseNotebookNote {
    init(from note: RedwoodNote) {
        self.id = note.id ?? ""
        self.date = note.createdAt ?? Date()
        self.courseID = note.courseId

        self.content = note.userText

        self.highlightedText = note.highlightedText
        self.highlightKey = note.highlightKey
        self.labels = note.reaction.map { $0.compactMap { CourseNoteLabel(rawValue: $0) } }
        self.length = note.length
        self.startIndex = note.startIndex
    }
}
