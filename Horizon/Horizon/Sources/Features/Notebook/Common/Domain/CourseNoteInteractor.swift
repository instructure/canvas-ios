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
    typealias ObjectFilter = (courseID: String?, pageURL: String?)
    typealias FilteringNotes = (all: [CourseNotebookNote], filtered: [CourseNotebookNote])

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
    private var objectFilters: CurrentValueRelay<ObjectFilter> = CurrentValueRelay((nil, nil))
    private let refreshSubject = CurrentValueRelay<Date?>(nil)
    private var lastRefresh: Date?

    // MARK: - Public

    func add(
        courseID: String,
        pageURL: String,
        content: String = "",
        labels: [CourseNoteLabel] = [],
        notebookHighlight: NotebookHighlight? = nil
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        pageIDPublisher
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
            pageIDPublisher
        )
        .flatMap { [weak self] _, _, refreshDate, pageID in
            guard let self = self else {
                return Just([CourseNotebookNote]())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return self.notesRequest(pageID: pageID, isRefresh: isRefresh(refreshDate))
        }
        .mapError { _ in NotebookError.unknown }
        .eraseToAnyPublisher()
    }

    // A method for requesting an update to the list of course notes
    func refresh() {
        refreshSubject.accept(Date())
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

    // MARK: - Private Methods

    private func isRefresh(_ date: Date?) -> Bool {
        let isRefresh = lastRefresh != date
        lastRefresh = date
        return isRefresh
    }

    private func notesRequest(pageID: String? = nil, isRefresh: Bool) -> AnyPublisher<[CourseNotebookNote], any Error> {
        weak var weakSelf = self
        return ReactiveStore(
            useCase: GetNotebookNotesUseCase(
                labels: [filter?.rawValue].compactMap { $0 },
                courseID: objectFilters.value.0,
                pageID: pageID
            )
        )
        .getEntities(
            ignoreCache: isRefresh,
            keepObservingDatabaseChanges: true
        )
        .map { $0.courseNotebookNotes }
        .map { weakSelf?.filteredToPage($0) ?? ([], [])  }
        .map { tuple in tuple.filtered }
        .eraseToAnyPublisher()
    }

    private var pageIDPublisher: AnyPublisher<String?, Error> {
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

    private func filteredToPage(_ notes: [CourseNotebookNote]) -> FilteringNotes {
        let pageSize = 10

        guard let cursor = cursor else {
            return (notes, filtered: Array(notes.prefix(pageSize)))
        }

        let filtered = Array(
            notes.filter { note in
                cursor.isBefore ?
                    note.date < cursor.cursor :
                    note.date > cursor.cursor
            }.prefix(pageSize)
        )
        return (notes, filtered)
    }
}

// MARK: - Extensions

extension Array where Element == CDNotebookNote {
    var courseNotebookNotes: [CourseNotebookNote] {
        let count = self.count
        return enumerated().map { $1.courseNotebookNote(index: $0, count: count) }
    }
}

extension CDNotebookNote {
    func courseNotebookNote(index: Int, count: Int) -> CourseNotebookNote {
        CourseNotebookNote(
            id: id,
            date: date,
            courseId: courseID,
            hasNext: index < count - 1,
            hasPrevious: index > 0,
            objectId: pageID,
            content: content,
            highlightData: notebookHighlight,
            labels: courseNoteLabels
        )
    }

    var courseNoteLabels: [CourseNoteLabel]? {
        labels.deserializeLabels?.compactMap { CourseNoteLabel.init(rawValue: $0) }
    }

    var notebookHighlight: NotebookHighlight? {
        guard let selectedText = selectedText,
           let startContainer = startContainer,
           let endContainer = endContainer,
           let startOffset = startOffset,
           let endOffset = endOffset,
           let start = start,
           let end = end else {
            return nil
        }
        return NotebookHighlight(
            selectedText: selectedText,
            textPosition: NotebookHighlight.TextPosition(
                start: Int(truncating: start),
                end: Int(truncating: end)
            ),
            range: NotebookHighlight.Range(
                startContainer: startContainer,
                startOffset: Int(truncating: startOffset),
                endContainer: endContainer,
                endOffset: Int(truncating: endOffset)
            )
        )
    }
}

/// Cursor to paginate the notes
/// If previous is set, it'll get the prior results
/// If next is set, it'll get the next results
struct Cursor {
    let cursor: Date
    let isBefore: Bool // if it's not before, it's "after"

    init(previous cursor: Date) {
        self.cursor = cursor
        isBefore = true
    }

    init(next cursor: Date) {
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
