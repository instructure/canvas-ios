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
    var term: String { get set }
    var afterNodeId: String? { get set }
    func get(after nodeId: String?) -> AnyPublisher<[CourseNote], NotebookError>
}

final class GetCourseNotesInteractorLive: GetCourseNotesInteractor {
    // MARK: - Dependencies

    final let canvasApi: API

    // MARK: - Public

    var filter: CourseNoteLabel? {
        get {
            filterPublisher.value
        }
        set {
            filterPublisher.send(newValue)
        }
    }

    var term: String {
        get {
            termPublisher.value
        }
        set {
            termPublisher.send(newValue)
        }
    }

    var afterNodeId: String? {
        get {
            afterNodeIdPublisher.value
        }
        set {
            afterNodeIdPublisher.send(newValue)
        }
    }

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private var termPublisher: CurrentValueSubject<String, Error> = CurrentValueSubject("")
    private var filterPublisher: CurrentValueSubject<CourseNoteLabel?, Error> = CurrentValueSubject(nil)
    private var afterNodeIdPublisher: CurrentValueSubject<String?, Error> = CurrentValueSubject(nil)

    // MARK: - Init

    init(api: API = AppEnvironment.shared.api) {
        self.canvasApi = api
    }

    // MARK: - Public Methods

    func get(after nodeId: String? = nil) -> AnyPublisher<[CourseNote], NotebookError> {
        JWTTokenRequest(.redwood)
            .api(from: canvasApi)
            .flatMap { api in
                Publishers.CombineLatest3(
                    self.filterPublisher,
                    self.termPublisher,
                    self.afterNodeIdPublisher
                )
                .flatMap { value in
                    ReactiveStore(
                        useCase: GetCourseNotesUseCase(
                            api: api,
                            labels: value.0.map { [$0] } ?? [],
                            searchTerm: value.1,
                            after: value.2
                        )
                    )
                    .getEntities(keepObservingDatabaseChanges: true)
                    .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
    }
}
