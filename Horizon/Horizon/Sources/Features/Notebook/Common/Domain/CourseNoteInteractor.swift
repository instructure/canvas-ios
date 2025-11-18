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
    func getAllNotesWithCourses(
        pageURL: String?,
        ignoreCache: Bool,
        keepObserving: Bool,
        filter: NotebookQueryFilter
    ) -> AnyPublisher<ListCourseNotebookNoteModel, Never>

    func add(
        courseID: String?,
        pageURL: String?,
        content: String,
        labels: [CourseNoteLabel],
        notebookHighlight: NotebookHighlight?
    ) -> AnyPublisher<CourseNotebookNote, NotebookError>

    func delete(id: String) -> AnyPublisher<Void, Error>

    func getNotes(
        for pageURL: String?,
        ignoreCache: Bool,
        keepObserving: Bool,
        filter: NotebookQueryFilter
    ) -> AnyPublisher<[CourseNotebookNote], Never>

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
    // MARK: - Dependencies

    private let learnCoursesInteractor: GetLearnCoursesInteractor

    // MARK: - Init

    init(learnCoursesInteractor: GetLearnCoursesInteractor = GetLearnCoursesInteractorLive()) {
        self.learnCoursesInteractor = learnCoursesInteractor
    }

    func add(
        courseID: String?,
        pageURL: String?,
        content: String = "",
        labels: [CourseNoteLabel] = [],
        notebookHighlight: NotebookHighlight? = nil
    ) -> AnyPublisher<CourseNotebookNote, NotebookError> {
        getPageID(courseID: courseID, pageURL: pageURL)
            .flatMap { pageID in
                guard let courseID, let pageID = pageID else {
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
                notebookNotes.mapToNoteModel().first
            }
            .mapError { _ in NotebookError.unknown }
            .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    func delete(id: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: DeleteNotebookNoteUseCase(
                request: RedwoodDeleteNoteMutation(id: id)
            )
        )
        .getEntities()
        .compactMap { _ in () }
        .eraseToAnyPublisher()
    }

    func getAllNotesWithCourses(
        pageURL: String?,
        ignoreCache: Bool,
        keepObserving: Bool,
        filter: NotebookQueryFilter
    ) -> AnyPublisher<ListCourseNotebookNoteModel, Never> {
        getPageID(courseID: filter.courseId, pageURL: pageURL)
            .flatMap { [weak self] pageId -> AnyPublisher<ListCourseNotebookNoteModel, Never> in
                guard let self else {
                    return Just(ListCourseNotebookNoteModel(notes: [], courses: []))
                        .eraseToAnyPublisher()
                }

                var filterUpdated = filter
                filterUpdated.pageId = pageId

                return self.notesRequest(
                    ignoreCache: ignoreCache,
                    keepObserving: keepObserving,
                    filter: filterUpdated
                )
                .combineLatest(self.learnCoursesInteractor.getCourses(ignoreCache: ignoreCache))
                .map { notesResult, courses in
                    let notes = notesResult.mapToNoteModel(courses: courses)
                    let allCourses = DropdownMenuItem(id: "-1", name: String(localized: "All Courses"))
                    let listCourses: [DropdownMenuItem] = [allCourses] + courses.map { .init(id: $0.id, name: $0.name) }
                    return ListCourseNotebookNoteModel(notes: notes, courses: listCourses)
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getNotes(
        for pageURL: String?,
        ignoreCache: Bool,
        keepObserving: Bool,
        filter: NotebookQueryFilter
    ) -> AnyPublisher<[CourseNotebookNote], Never> {
        getPageID(courseID: filter.courseId, pageURL: pageURL)
            .flatMap { [weak self] pageId in
                guard let self else { return Just([CDHNotebookNote]()).eraseToAnyPublisher() }
                var filterUpdated = filter
                filterUpdated.pageId = pageId
                return self.notesRequest(
                    ignoreCache: ignoreCache,
                    keepObserving: keepObserving,
                    filter: filterUpdated
                )
            }
            .map { $0.mapToNoteModel() }
            .eraseToAnyPublisher()
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
        .compactMap { $0.mapToNoteModel().first }
        .mapError { _ in NotebookError.unknown }
        .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func notesRequest(
        ignoreCache: Bool,
        keepObserving: Bool,
        filter: NotebookQueryFilter
    ) -> AnyPublisher<[CDHNotebookNote], Never> {
        return ReactiveStore(useCase: GetNotebookNotesUseCase(filter: filter))
            .getEntities(ignoreCache: ignoreCache, keepObservingDatabaseChanges: keepObserving)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private func getPageID(
        courseID: String?,
        pageURL: String?
    ) -> AnyPublisher<String?, Never> {
        guard let courseID, let pageURL else {
            return Just(nil).eraseToAnyPublisher()
        }
        return ReactiveStore(useCase: GetPage(context: .course(courseID), url: pageURL))
            .getEntities(ignoreCache: false)
            .replaceError(with: [])
            .compactMap { $0.first?.id }
            .eraseToAnyPublisher()
    }
}

// MARK: - Extensions

extension Array where Element == CDHNotebookNote {
    func mapToNoteModel(courses: [LearnCourse] = []) -> [CourseNotebookNote] {
        return enumerated().map { $1.map(courses: courses) }
    }
}

extension CDHNotebookNote {
    func map(courses: [LearnCourse]) -> CourseNotebookNote {
        CourseNotebookNote(
            id: id,
            date: date,
            courseId: courseID,
            courseName: courses.first(where: { $0.id == courseID })?.name,
            objectId: pageID,
            content: content,
            highlightData: notebookHighlight,
            labels: courseNoteLabels
        )
    }

    var courseNoteLabels: [CourseNoteLabel]? {
        CDHNotebookNote.deserializeLabels(from: labels)?.compactMap { CourseNoteLabel.init(rawValue: $0) }
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
