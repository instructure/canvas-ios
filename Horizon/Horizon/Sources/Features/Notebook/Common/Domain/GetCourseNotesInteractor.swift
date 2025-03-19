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

protocol GetCourseNotesInteractor {
    var filter: CourseNoteLabel? { get set }
    func get() -> AnyPublisher<[CourseNotebookNote], NotebookError>
    func refresh()
    func set(courseId: String?)
    func set(cursor: Cursor?)
}

final class GetCourseNotesInteractorLive: GetCourseNotesInteractor {
    typealias CursorFilter = (cursor: Cursor?, filter: CourseNoteLabel?)

    // MARK: - Dependencies

    private let redwoodDomainService: DomainService

    static let shared: GetCourseNotesInteractor = GetCourseNotesInteractorLive(
        redwoodDomainService: DomainService(.redwood)
    )

    // MARK: - Public

    func set(courseId: String?) {
        courseIdFilter.accept(courseId)
    }

    func set(cursor: Cursor?) {
        cursorFilter.accept(
            cursor == nil && filter == nil ? nil : (cursor: cursor, filter: filter)
        )
    }

    var filter: CourseNoteLabel? {
        didSet {
            cursorFilter.accept(
                filter == nil ? nil : (cursor: nil, filter: filter)
            )
        }
    }

    // A method for requesting an update to the list of course notes
    func refresh() {
        refreshSubject.accept(())
    }

    // MARK: - Private

    private var cursor: Cursor? {
        cursorFilter.value?.cursor
    }
    private var courseIdFilter: CurrentValueRelay<String?> = CurrentValueRelay(nil)
    private var cursorFilter: CurrentValueRelay<CursorFilter?> = CurrentValueRelay(nil)
    private let refreshSubject = CurrentValueRelay<Void>(())
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    private init(redwoodDomainService: DomainService) {
        self.redwoodDomainService = redwoodDomainService
    }

    // MARK: - Public Methods

    func get() -> AnyPublisher<[CourseNotebookNote], NotebookError> {
        self.redwoodDomainService.api()
            .flatMap(listenToFilters)
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func request(
        api: API,
        labels: [CourseNoteLabel]? = nil,
        courseId: String? = nil
    ) -> GetNotesQuery {
        let accessToken = api.loginSession?.accessToken ?? ""
        let reactions = labels?.map(\.rawValue)

        guard let cursorValue = cursor?.cursor else {
            return .init(jwt: accessToken, courseId: courseId, reactions: reactions)
        }
        if cursor?.isBefore == true {
            return .init(
                jwt: accessToken,
                before: cursorValue,
                reactions: reactions,
                courseId: courseId
            )
        }
        return .init(
            jwt: accessToken,
            after: cursorValue,
            reactions: reactions,
            courseId: courseId
        )
    }

    private func listenToFilters(_ api: API) -> AnyPublisher<[CourseNotebookNote], any Error> {
        Publishers.CombineLatest3(
            cursorFilter,
            courseIdFilter,
            refreshSubject
        )
        .flatMap { [weak self] cursorFilter, courseId, _ in
            guard let self = self else {
                return Just([CourseNotebookNote]())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.listenTo(api: api, cursorFilter: cursorFilter, courseId: courseId)
        }
        .eraseToAnyPublisher()
    }

    private func listenTo(
        api: API,
        cursorFilter: CursorFilter? = nil,
        courseId: String? = nil
    ) -> AnyPublisher<
        [CourseNotebookNote], any Error
    > {
        api.makeRequest(
            request(
                api: api,
                labels: cursorFilter?.filter.map { [$0] },
                courseId: courseId
            )
        )
        .compactMap { $0?.courseNotebookNotes }
        .eraseToAnyPublisher()
    }
}

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

#if DEBUG
final class GetCourseNotesInteractorPreview: GetCourseNotesInteractor {
    var filter: CourseNoteLabel?
    var cursor: Cursor?
    func get() -> AnyPublisher<[CourseNotebookNote], NotebookError> {
        Just([CourseNotebookNote.example])
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }
    func refresh() {}
    func set(courseId: String?) {}
    func set(cursor: Cursor?) {}
}
#endif
