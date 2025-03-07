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
import CombineExt
import Core
import Foundation

/// Cursor to paginate the notes
/// If previous is set, it'll get the prior results
/// If next is set, it'll get the next results
struct Cursor {
    let cursor: String
    let isBefore: Bool // if it's not before, it's "after"

    init(previous cursor: String) {
        self.cursor = cursor
        isBefore = true
    }

    init(next cursor: String) {
        self.cursor = cursor
        isBefore = false
    }
}

protocol GetCourseNotesInteractor {
    var filter: CourseNoteLabel? { get set }
    var cursor: Cursor? { get set }
    func get() -> AnyPublisher<[API.CourseNotebookNote], NotebookError>
    func refresh()
}

final class GetCourseNotesInteractorLive: GetCourseNotesInteractor {
    typealias CursorFilter = (cursor: Cursor?, filter: CourseNoteLabel?)

    // MARK: - Dependencies

    let canvasApi: API

    static let shared: GetCourseNotesInteractor = GetCourseNotesInteractorLive()

    // MARK: - Public

    var cursor: Cursor? {
        get {
            cursorFilter.value?.cursor
        }
        set {
            cursorFilter.accept(
                newValue == nil && filter == nil ? nil : (cursor: newValue, filter: filter)
            )
        }
    }

    var filter: CourseNoteLabel? {
        get {
            cursorFilter.value?.filter
        }
        set {
            cursorFilter.accept(
                newValue == nil ? nil : (cursor: nil, filter: newValue)
            )
        }
    }

    // A method for requesting an update to the list of course notes
    func refresh() {
        refreshSubject.accept(())
    }

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private let refreshSubject = CurrentValueRelay<Void>(())
    private var cursorFilter: CurrentValueRelay<CursorFilter?> = CurrentValueRelay(nil)

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

    func get() -> AnyPublisher<[API.CourseNotebookNote], NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap(listenToFilters)
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func listenToFilters(_ api: API) -> AnyPublisher<[API.CourseNotebookNote], any Error> {
        Publishers.CombineLatest(
            cursorFilter,
            refreshSubject
        )
        .flatMap { [weak self] cursorFilter, _ in
            guard let self = self else {
                return Just([API.CourseNotebookNote]())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.listenTo(api: api, filter: cursorFilter?.filter, cursor: cursorFilter?.cursor)
        }
        .eraseToAnyPublisher()
    }

    private func listenTo(api: API, filter: CourseNoteLabel?, cursor: Cursor?) -> AnyPublisher<
        [API.CourseNotebookNote], any Error
    > {
        api.makeRequest(request(api: api, labels: filter.map { [$0] }))
            .compactMap { $0?.courseNotebookNotes }
            .eraseToAnyPublisher()
    }
}

#if DEBUG
final class GetCourseNotesInteractorPreview: GetCourseNotesInteractor {
    var filter: CourseNoteLabel?
    var cursor: Cursor?
    func get() -> AnyPublisher<[API.CourseNotebookNote], NotebookError> {
        Just([API.CourseNotebookNote.example])
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }
    func refresh() {}
}
#endif
