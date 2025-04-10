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
    case unableToCreateNote
}

protocol CourseNoteInteractor {
    func add(
        courseID: String,
        pageURL: String,
        content: String,
        labels: [CourseNoteLabel],
        notebookHighlight: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError>
    func delete(id: String) -> AnyPublisher<Void, NotebookError>
    func get(courseID: String, pageURL: String) -> AnyPublisher<[CourseNotebookNote], NotebookError>
    func set(id: String, content: String?, labels: [CourseNoteLabel]?, highlightData: NotebookHighlight?)
        -> AnyPublisher<CourseNotebookNote, NotebookError>
}

class CourseNoteInteractorLive: CourseNoteInteractor {

    // MARK: - Public

    static let instance = CourseNoteInteractorLive()

    // MARK: - Dependencies

    private let redwoodDomainService: DomainService
    private let getCourseNotesInteractor: GetCourseNotesInteractor

    // MARK: - Private

    private let refreshSubject = CurrentValueSubject<Void, Error>(())

    // MARK: - Init

    private init(
        redwoodDomainService: DomainService = DomainService(.redwood),
        getCourseNotesInteractor: GetCourseNotesInteractor = GetCourseNotesInteractorLive.shared
    ) {
        self.redwoodDomainService = redwoodDomainService
        self.getCourseNotesInteractor = getCourseNotesInteractor
    }

    // MARK: - Public

    func add(
        courseID: String,
        pageURL: String,
        content: String = "",
        labels: [CourseNoteLabel] = [],
        notebookHighlight: NotebookHighlight? = nil
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        objectIdPublisher(courseID: courseID, pageURL: pageURL)
            .mapError { _ in NotebookError.unknown }
            .flatMap { [weak self] pageID in

            guard let self = self,
                let pageID = pageID else {
                return Fail<CourseNotebookNote, NotebookError>(error: NotebookError.unableToCreateNote)
                    .eraseToAnyPublisher()
            }

            let publisher: AnyPublisher<CourseNotebookNote, NotebookError> = redwoodDomainService.api()
                .flatMap { api in
                    api.makeRequest(
                        RedwoodCreateNoteMutation(
                            jwt: api.loginSession?.accessToken ?? "",
                            note: NewRedwoodNote(
                                courseId: courseID,
                                objectId: pageID,
                                objectType: APIModuleItemType.page.rawValue,
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

            return publisher
        }.eraseToAnyPublisher()
    }

    func delete(id: String) -> AnyPublisher<Void, NotebookError> {
        redwoodDomainService.api()
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

    func get(courseID: String, pageURL: String) -> AnyPublisher<[CourseNotebookNote], NotebookError> {
        Publishers.CombineLatest3(
            redwoodDomainService.api(),
            refreshSubject,
            objectIdPublisher(courseID: courseID, pageURL: pageURL)
        )
        .flatMap { api, _, pageId in
            api.makeRequest(
                GetNotesQuery(
                    jwt: api.loginSession?.accessToken ?? "",
                    courseId: courseID,
                    objectId: pageId
                )
            )
            .compactMap { $0?.courseNotebookNotes.filter { $0.objectId == pageId } }
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
        redwoodDomainService.api()
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

    // MARK: - Private functions

    private func objectIdPublisher(courseID: String, pageURL: String) -> AnyPublisher<String?, Error> {
        ReactiveStore(
            useCase: GetPage(context: .course(courseID), url: pageURL)
        )
        .getEntities()
        .compactMap { $0.first?.id }
        .eraseToAnyPublisher()
    }
}
