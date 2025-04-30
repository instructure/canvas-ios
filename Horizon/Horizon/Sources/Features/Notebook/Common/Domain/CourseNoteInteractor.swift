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

protocol CourseNoteInteractor {
    func add(
        courseID: String,
        pageURL: String,
        content: String,
        labels: [CourseNoteLabel],
        notebookHighlight: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError>
    func delete(id: String) -> AnyPublisher<Void, NotebookError>
    var filter: CourseNoteLabel? { get }
    func get() -> AnyPublisher<[CourseNotebookNote], NotebookError>
    func refresh()
    func set(courseID: String?, pageURL: String?)
    func set(cursor: Cursor?)
    func set(filter: CourseNoteLabel?)
    func set(
        id: String,
        content: String?,
        labels: [CourseNoteLabel]?,
        highlightData: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError>
}

enum NotebookError: Error {
    case unknown
    case unableToCreateNote
}

final class CourseNoteInteractorLive: CourseNoteInteractor {

    // MARK: - Type Definitions

    typealias CursorFilter = (cursor: Cursor?, filter: CourseNoteLabel?)

    // MARK: - Dependencies

    private let redwoodDomainService: DomainService

    // MARK: - Private Properties

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

    init(redwoodDomainService: DomainService = DomainService(.redwood)) {
        self.redwoodDomainService = redwoodDomainService
    }

    // MARK: - Public

    func add(
        courseID: String,
        pageURL: String,
        content: String = "",
        labels: [CourseNoteLabel] = [],
        notebookHighlight: NotebookHighlight? = nil
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        objectIdPublisher
            .mapError { _ in NotebookError.unknown }
            .flatMap { pageID in

            guard let pageID = pageID else {
                return Fail<CourseNotebookNote, NotebookError>(error: NotebookError.unableToCreateNote)
                    .eraseToAnyPublisher()
            }

            return ReactiveStore(
                useCase: AddNotebookNoteUseCase(
                    request: RedwoodCreateNoteMutation(
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
            )
            .getEntities()
            .compactMap { notebookNotes in
                notebookNotes.courseNotebookNotes.first
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    func delete(id: String) -> AnyPublisher<Void, NotebookError> {
        ReactiveStore(
            useCase: DeleteNotebookNoteUseCase(
                request: RedwoodDeleteNoteMutation(id: id)
            )
        )
        .getEntities()
        .compactMap { _ in () }
        .mapError { _ in NotebookError.unknown }
        .eraseToAnyPublisher()
    }

    func get() -> AnyPublisher<[CourseNotebookNote], NotebookError> {
        Publishers.CombineLatest4(
            cursorFilter.setFailureType(to: Error.self).eraseToAnyPublisher(),
            objectFilters.setFailureType(to: Error.self).eraseToAnyPublisher(),
            refreshSubject.setFailureType(to: Error.self).eraseToAnyPublisher(),
            objectIdPublisher
        )
        .flatMap { [weak self] _, _, _, objectId in
            guard let self = self else {
                return Just([CourseNotebookNote]())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            guard let objectId = objectId else {
                return self.notesRequest()
            }
            return self.notesRequest(objectId: objectId)
        }
        .mapError { _ in NotebookError.unknown }
        .eraseToAnyPublisher()
    }

    func set(courseID: String?, pageURL: String? = nil) {
        objectFilters.accept((courseID, pageURL))
    }

    func set(cursor: Cursor?) {
        cursorFilter.accept(
            cursor == nil && filter == nil ? nil : (cursor: cursor, filter: filter)
        )
    }

    func set(filter: CourseNoteLabel?) {
        self.filter = filter
    }

    func set(
        id: String,
        content: String?,
        labels: [CourseNoteLabel]?,
        highlightData: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        ReactiveStore(
            useCase: UpdateNotebookNoteUseCase(
                updateNoteMutation: RedwoodUpdateNoteMutation(
                    id: id,
                    userText: content ?? "",
                    reaction: labels?.map { $0.rawValue } ?? [],
                    highlightData: highlightData
                )
            )
        )
        .getEntities()
        .compactMap { $0.courseNotebookNotes.first }
        .mapError { _ in NotebookError.unknown }
        .eraseToAnyPublisher()
    }

    // A method for requesting an update to the list of course notes
    func refresh() {
        //refreshSubject.accept(())
    }

    // MARK: - Private Methods

    private func request(
        labels: [CourseNoteLabel]? = nil,
        courseID: String? = nil,
        objectId: String? = nil
    ) -> GetNotesQuery {
        let reactions = labels?.map(\.rawValue)

        guard let cursorValue = cursor?.cursor else {
            return .init(
                reactions: reactions,
                courseId: courseID,
                objectId: objectId
            )
        }
        if cursor?.isBefore == true {
            return .init(
                before: cursorValue,
                reactions: reactions,
                courseId: courseID,
                objectId: objectId
            )
        }
        return .init(
            after: cursorValue,
            reactions: reactions,
            courseId: courseID,
            objectId: courseID
        )
    }

    private func notesRequest(objectId: String? = nil) -> AnyPublisher<[CourseNotebookNote], any Error> {
        ReactiveStore(
            useCase: GetNotebookNotesUseCase(
                getNotesQuery: request(
                    labels: cursorFilter.value?.filter.map { [$0] },
                    courseID: objectFilters.value.0,
                    objectId: objectId
                ),
            )
        )
        .getEntities()
        .compactMap { $0.courseNotebookNotes }
        .eraseToAnyPublisher()
    }

    private var objectIdPublisher: AnyPublisher<String?, Error> {
        guard let courseID = objectFilters.value.0,
            let pageURL = objectFilters.value.1 else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return ReactiveStore(
            useCase: GetPage(context: .course(courseID), url: pageURL)
        )
        .getEntities()
        .compactMap { $0.first?.id }
        .eraseToAnyPublisher()
    }
}

// MARK: - Extensions

extension Array where Element == CDNotebookNote {
    var courseNotebookNotes: [CourseNotebookNote] {
        map { $0.courseNotebookNote }
    }
}

extension CDNotebookNote {
    var courseNotebookNote: CourseNotebookNote {
        CourseNotebookNote(
            id: id,
            date: date,
            courseId: courseID,
            objectId: pageID,
            content: content,
            highlightData: notebookHighlight,
            labels: courseNoteLabels,
            nextCursor: nil,
            previousCursor: nil
        )
    }

    var courseNoteLabels: [CourseNoteLabel]? {
        CDNotebookNote.deserializeLabels(labels)?.compactMap { CourseNoteLabel.init(rawValue: $0) }
    }

    var notebookHighlight: NotebookHighlight? {
        guard let selectedText = selectedText,
           let startContainer = startContainer,
           let endContainer = endContainer,
           startOffset >= 0,
           endOffset >= 0,
           start >= 0,
           end >= 0 else {
            return nil
        }
        return NotebookHighlight(
            selectedText: selectedText,
            textPosition: NotebookHighlight.TextPosition(
                start: Int(start),
                end: Int(end)
            ),
            range: NotebookHighlight.Range(
                startContainer: startContainer,
                startOffset: Int(startOffset),
                endContainer: endContainer,
                endOffset: Int(endOffset)
            )
        )
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
final class CourseNoteInteractorPreview: CourseNoteInteractor {
    func add(
        courseID: String,
        pageURL: String,
        content: String,
        labels: [CourseNoteLabel],
        notebookHighlight: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        Just(CourseNotebookNote.example)
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }
    func delete(id: String) -> AnyPublisher<Void, NotebookError> {
        Just(())
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }
    var filter: CourseNoteLabel? { nil }
    func get() -> AnyPublisher<[CourseNotebookNote], NotebookError> {
        Just([CourseNotebookNote.example])
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }
    func refresh() {}
    func set(courseID: String?, pageURL: String?) {}
    func set(cursor: Cursor?) {}
    func set(filter: CourseNoteLabel?) {}
    func set(
        id: String,
        content: String?,
        labels: [CourseNoteLabel]?,
        highlightData: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        Just(CourseNotebookNote.example)
            .setFailureType(to: NotebookError.self)
            .eraseToAnyPublisher()
    }
}
#endif
