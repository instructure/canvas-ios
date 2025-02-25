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
    func get() -> AnyPublisher<[CourseNote], NotebookError>
}

final class GetCourseNotesInteractorLive: GetCourseNotesInteractor {
    // MARK: - Dependencies

    final let canvasApi: API

    final let instance: GetCourseNotesInteractorLive = .init()

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
            filterPublisher.send(newValue)
        }
    }

    // A method for requesting an update to the list of course notes
    func refresh() {
        refreshSubject.send()
    }

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private let refreshSubject = PassthroughSubject<Void, Error>()
    private var cursorPublisher: CurrentValueSubject<Cursor?, Error> = CurrentValueSubject(nil)
    private var filterPublisher: CurrentValueSubject<CourseNoteLabel?, Error> = CurrentValueSubject(nil)

    // MARK: - Init

    init(api: API = AppEnvironment.shared.api) {
        self.canvasApi = api
    }

    // MARK: - Public Methods

    func get() -> AnyPublisher<[CourseNote], NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap(listenToFilters)
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func listenToFilters(_ api: API) -> AnyPublisher<[CourseNote], any Error> {
        Publishers.CombineLatest3(
            filterPublisher,
            cursorPublisher,
            refreshSubject
        )
        .flatMap { [weak self] filter, cursor, _ in
            guard let self = self else {
                return Just([CourseNote]())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.listenToStore(api: api, filter: filter, cursor: cursor)
        }
        .eraseToAnyPublisher()
    }

    private func listenToStore(api: API, filter: CourseNoteLabel?, cursor: Cursor?) -> AnyPublisher<[CourseNote], any Error> {
        ReactiveStore(
            useCase: GetCourseNotesUseCase(
                api: api,
                labels: filter.map { [$0] },
                cursor: cursor
            )
        )
        .getEntities(keepObservingDatabaseChanges: true)
        .eraseToAnyPublisher()
    }
}
