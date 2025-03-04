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

struct NotebookHighlight: Codable, Equatable {
    let selectedText: String
    let textPosition: TextPosition
    let range: Range

    enum CodingKeys: String, CodingKey {
        case selectedText, textPosition, range
    }

    struct TextPosition: Codable, Equatable {
        let start: Int
        let end: Int

        enum CodingKeys: String, CodingKey {
            case start, end
        }
    }

    struct Range: Codable, Equatable {
        let startContainer: String
        let startOffset: Int
        let endContainer: String
        let endOffset: Int

        enum CodingKeys: String, CodingKey {
            case startContainer, startOffset, endContainer, endOffset
        }
    }
}

protocol CourseNoteInteractor {
    func add(
        courseId: String,
        itemId: String,
        moduleType: ModuleItemType,
        content: String,
        labels: [CourseNoteLabel],
        notebookHighlight: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError>
    func delete(id: String) -> AnyPublisher<Void, NotebookError>
    func get(courseId: String, itemId: String) -> AnyPublisher<[CourseNotebookNote], NotebookError>
    func set(id: String, content: String?, labels: [CourseNoteLabel]?, highlightData: NotebookHighlight?)
        -> AnyPublisher<CourseNotebookNote, NotebookError>
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

    // MARK: - Public

    static let instance = CourseNoteInteractorLive()

    // MARK: - Dependencies

    private let canvasApi: API
    private let getCourseNotesInteractor: GetCourseNotesInteractor

    // MARK: - Private

    private let refreshSubject = CurrentValueSubject<Void, Error>(())

    // MARK: - Init

    private init(
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
        notebookHighlight: NotebookHighlight? = nil
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
                            highlightData: notebookHighlight
                        )
                    )
                )
                .compactMap { [weak self] (response: RedwoodCreateNoteMutationResponse?) in
                    self?.getCourseNotesInteractor.refresh()
                    self?.refreshSubject.send()
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
                .map { [weak self] _ in
                    self?.getCourseNotesInteractor.refresh()
                    self?.refreshSubject.send()
                    return ()
                }
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }

    func get(courseId: String, itemId: String) -> AnyPublisher<[CourseNotebookNote], NotebookError> {
        Publishers.CombineLatest(
            JWTTokenRequest(.redwood).api(from: canvasApi),
            refreshSubject
        )
        .flatMap { api, _ in
            api.makeRequest(
                GetNotesQuery(jwt: api.loginSession?.accessToken ?? "", courseId: courseId)
            )
            .compactMap { $0?.courseNotebookNotes.filter { $0.objectId == itemId } }
            .eraseToAnyPublisher()
        }
        .mapError { _ in NotebookError.unknown }
        .eraseToAnyPublisher()
    }

    func set(
        id: String,
        content: String?,
        labels: [CourseNoteLabel]?,
        highlightData: NotebookHighlight?
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
                        highlightData: highlightData
                    )
                )
                .compactMap { [weak self] (response: RedwoodUpdateNoteMutationResponse?) in
                    self?.getCourseNotesInteractor.refresh()
                    self?.refreshSubject.send()
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

extension CourseNotebookNote {
    init(from note: RedwoodNote) {
        self.id = note.id ?? ""
        self.date = note.createdAt ?? Date()
        self.courseId = note.courseId
        self.objectId = note.objectId

        self.content = note.userText
        self.labels = note.reaction.map { $0.compactMap { CourseNoteLabel(rawValue: $0) } }

        self.highlightData = note.highlightData
    }
}
