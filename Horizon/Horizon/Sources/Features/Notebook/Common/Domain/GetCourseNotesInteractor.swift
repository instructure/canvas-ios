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
    var filter: CourseNoteLabel? { get }
    func get() -> AnyPublisher<[CourseNotebookNote], NotebookError>
    func refresh()
    func set(courseId: String?, moduleId: String?)
    func set(cursor: Cursor?)
    func set(filter: CourseNoteLabel?)
}

final class GetCourseNotesInteractorLive: GetCourseNotesInteractor {
    typealias CursorFilter = (cursor: Cursor?, filter: CourseNoteLabel?)

    // MARK: - Dependencies

    private let redwoodDomainService: DomainService

    static let shared: GetCourseNotesInteractor = GetCourseNotesInteractorLive(
        redwoodDomainService: DomainService(.redwood)
    )

    // MARK: - Public

    func set(courseId: String?, moduleId: String? = nil) {
        objectFilters.accept((courseId, moduleId))
    }

    func set(cursor: Cursor?) {
        cursorFilter.accept(
            cursor == nil && filter == nil ? nil : (cursor: cursor, filter: filter)
        )
    }

    func set(filter: CourseNoteLabel?) {
        self.filter = filter
    }

    // A method for requesting an update to the list of course notes
    func refresh() {
        refreshSubject.accept(())
    }

    // MARK: - Private

    private var cursor: Cursor? {
        cursorFilter.value?.cursor
    }
    private var cursorFilter: CurrentValueRelay<CursorFilter?> = CurrentValueRelay(nil)
    private(set) var filter: CourseNoteLabel? {
        didSet {
            set(cursor: nil)
        }
    }
    private var objectFilters: CurrentValueRelay<(String?, String?)> = CurrentValueRelay((nil, nil))
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
        courseId: String? = nil,
        objectId: String? = nil
    ) -> GetNotesQuery {
        let accessToken = api.loginSession?.accessToken ?? ""
        let reactions = labels?.map(\.rawValue)

        guard let cursorValue = cursor?.cursor else {
            return .init(
                jwt: accessToken,
                reactions: reactions,
                courseId: courseId,
                objectId: objectId
            )
        }
        if cursor?.isBefore == true {
            return .init(
                jwt: accessToken,
                before: cursorValue,
                reactions: reactions,
                courseId: courseId,
                objectId: objectId
            )
        }
        return .init(
            jwt: accessToken,
            after: cursorValue,
            reactions: reactions,
            courseId: courseId,
            objectId: courseId
        )
    }

    private func listenToFilters(_ api: API) -> AnyPublisher<[CourseNotebookNote], any Error> {
        Publishers.CombineLatest3(
            cursorFilter,
            objectFilters,
            refreshSubject
        )
        .flatMap { [weak self] _, _, _ in
            guard let self = self else {
                return Just([CourseNotebookNote]())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.listen(to: api)
        }
        .eraseToAnyPublisher()
    }

    private func listen(to api: API) -> AnyPublisher<
        [CourseNotebookNote], any Error
    > {
        api.makeRequest(
            request(
                api: api,
                labels: cursorFilter.value?.filter.map { [$0] },
                courseId: objectFilters.value.0,
                objectId: objectFilters.value.1
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
    var cursor: Cursor?
    var filter: CourseNoteLabel? { nil }
    func get() -> AnyPublisher<[CourseNotebookNote], NotebookError> {
        Just([CourseNotebookNote.example])
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }
    func refresh() {}
    func set(courseId: String?, moduleId: String?) {}
    func set(cursor: Cursor?) {}
    func set(filter: CourseNoteLabel?) {}
}
#endif
