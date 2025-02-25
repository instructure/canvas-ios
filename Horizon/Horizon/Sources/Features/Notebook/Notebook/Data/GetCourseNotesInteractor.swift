//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Foundation

protocol GetCourseNotesInteractor {
    var filter: CourseNoteLabel? { get set }
    var cursor: Cursor? { get set }
    func get() -> AnyPublisher<[CourseNotebookNote], NotebookError>
    func refresh()
}

final class GetCourseNotesInteractorLive: GetCourseNotesInteractor {
    // MARK: - Dependencies

    let canvasApi: API

    static let instance: GetCourseNotesInteractor = GetCourseNotesInteractorLive()

    // MARK: - Public

    var cursor: Cursor? {
        get {
            cursorPublisher.value
        }
        set {
            cursorPublisher.send(newValue)
        }
    }

    var filter: CourseNoteLabel? {
        get {
            filterPublisher.value
        }
        set {
            cursor = nil
            filterPublisher.send(newValue)
        }
    }

    // A method for requesting an update to the list of course notes
    func refresh() {
        refreshSubject.send()
    }

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private let refreshSubject = CurrentValueSubject<Void, Error>(())
    private var cursorPublisher: CurrentValueSubject<Cursor?, Error> = CurrentValueSubject(nil)
    private var filterPublisher: CurrentValueSubject<CourseNoteLabel?, Error> = CurrentValueSubject(nil)

    private func request(api: API, labels: [CourseNoteLabel]? = nil) -> GetNotesQuery {
        let accessToken = api.loginSession?.accessToken ?? ""
        let reactions = labels?.map(\.rawValue)

        guard let cursorValue = cursor?.cursor else {
            return .init(jwt: accessToken, reactions: reactions)
        }
        if cursor?.isBefore == true {
            return .init(
                jwt: accessToken,
                before: cursorValue,
                reactions: reactions
            )
        }
        return .init(
            jwt: accessToken,
            after: cursorValue,
            reactions: reactions
        )
    }

    // MARK: - Init

    private init(api: API = AppEnvironment.shared.api) {
        self.canvasApi = api
    }

    // MARK: - Public Methods

    func get() -> AnyPublisher<[CourseNotebookNote], NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap(listenToFilters)
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func listenToFilters(_ api: API) -> AnyPublisher<[CourseNotebookNote], any Error> {
        Publishers.CombineLatest3(
            filterPublisher,
            cursorPublisher,
            refreshSubject
        )
        .flatMap { [weak self] filter, cursor, _ in
            guard let self = self else {
                return Just([CourseNotebookNote]())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.listenTo(api: api, filter: filter, cursor: cursor)
        }
        .eraseToAnyPublisher()
    }

    private func listenTo(api: API, filter: CourseNoteLabel?, cursor: Cursor?) -> AnyPublisher<[CourseNotebookNote], any Error> {
        api.makeRequest(request(api: api, labels: filter.map { [$0] }))
        .map(queryResponseToNotes)
        .eraseToAnyPublisher()
    }

    private func queryResponseToNotes(_ response: RedwoodFetchNotesQueryResponse?) -> [CourseNotebookNote] {
        guard let response = response else {
            return []
        }

        let pageInfo = response.data.notes.pageInfo
        return response.data.notes.edges.compactMap { edge in
            .init(
                from: edge,
                pageInfo: pageInfo
            )
        }
    }
}

extension CourseNotebookNote {
    init(
        from edge: RedwoodFetchNotesQueryResponse.ResponseEdge,
        pageInfo: RedwoodFetchNotesQueryResponse.PageInfo
    ) {
        let note = edge.node

        self.id = note.id ?? ""
        self.date = note.createdAt ?? Date()
        self.courseID = note.courseId

        self.content = note.userText

        self.nextCursor = pageInfo.hasNextPage ? edge.cursor : nil
        self.previousCursor = pageInfo.hasPreviousPage ? edge.cursor : nil

        self.highlightedText = note.highlightedText
        self.highlightKey = note.highlightKey
        self.labels = note.reaction.map { $0.compactMap { CourseNoteLabel(rawValue: $0) } }
        self.length = note.length
        self.startIndex = note.startIndex
    }
}
