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

enum NotebookError: Error {
    case unknown
}

protocol CourseNoteInteractor {
    func add(
        courseId: String,
        itemId: String,
        moduleType: ModuleItemType,
        content: String,
        labels: [CourseNoteLabel],
        notebookHighlight: NotebookHighlight?
    ) -> AnyPublisher<API.CourseNotebookNote, NotebookError>
    func delete(id: String) -> AnyPublisher<Void, NotebookError>
    func get(courseId: String, itemId: String) -> AnyPublisher<[API.CourseNotebookNote], NotebookError>
    func set(id: String, content: String?, labels: [CourseNoteLabel]?, highlightData: NotebookHighlight?)
        -> AnyPublisher<API.CourseNotebookNote, NotebookError>
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
        getCourseNotesInteractor: GetCourseNotesInteractor = GetCourseNotesInteractorLive.shared
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
    ) -> AnyPublisher<API.CourseNotebookNote, NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap { api in
                api.makeRequest(
                    RedwoodCreateNoteMutation(
                        jwt: api.loginSession?.accessToken ?? "",
                        note: NewRedwoodNote(
                            courseId: courseId,
                            objectId: itemId,
                            objectType: moduleType.apiModuleItemType.rawValue,
                            userText: content,
                            reaction: labels.map { $0.rawValue },
                            highlightData: notebookHighlight
                        )
                    )
                )
                .compactMap { [weak self] (response: RedwoodCreateNoteMutationResponse?) in
                    self?.getCourseNotesInteractor.refresh()
                    self?.refreshSubject.send()
                    return response.map { API.CourseNotebookNote(from: $0.data.createNote) }
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

    func get(courseId: String, itemId: String) -> AnyPublisher<[API.CourseNotebookNote], NotebookError> {
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
    ) -> AnyPublisher<API.CourseNotebookNote, NotebookError> {
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
                    return response.map { API.CourseNotebookNote(from: $0.data.updateNote) }
                }
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }
}

extension ModuleItemType {
    var apiModuleItemType: APIModuleItemType {
        switch self {
        case .file:
            return .file
        case .page:
            return .page
        case .discussion:
            return .discussion
        case .quiz:
            return .quiz
        case .assignment:
            return .assignment
        case .externalTool:
            return .externalTool
        case .subHeader:
            return .subHeader
        case .externalURL:
            return .externalURL
        }
    }
}

extension API.CourseNotebookNote {
    init(from note: RedwoodNote) {
        self.id = note.id ?? ""
        self.date = note.createdAt ?? Date()
        self.courseId = note.courseId
        self.objectId = note.objectId

        self.content = note.userText
        self.labels = note.reaction?.compactMap { CourseNoteLabel(rawValue: $0) } ?? []

        self.highlightData = note.highlightData
    }
}
