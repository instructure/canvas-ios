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

import Core
import Combine
import CombineSchedulers
import Observation
import Foundation

@Observable
final class NotebookListViewModel {
    enum State {
        case data
        case empty
        case filterEmpty
    }
    // MARK: - Outputs

    private(set) var courses: [DropdownMenuItem] = []
    private(set) var courseLables: [DropdownMenuItem] = CourseNoteLabel.list
    private(set) var filteredNotes: [CourseNotebookNote] = []
    private(set) var state: State = .data
    var listState = NoteCardListState()

    // MARK: - Private Variables

    private var totalNotesInDatabase = 0
    private var allNotes: [CourseNotebookNote] = []
    private var paginatedNotes: [[CourseNotebookNote]] = []
    private var subscriptions: Set<AnyCancellable> = []

    private var totalPages = 0
    private var currentPage = 0 {
        didSet {
            listState.isSeeMoreButtonVisible = (currentPage < totalPages - 1)
        }
    }

    // MARK: - Dependencies

    private let interactor: CourseNoteInteractor
    private let router: Router
    let courseID: String?
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        pageURL: String?,
        courseID: String?,
        interactor: CourseNoteInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        router: Router
    ) {
        self.interactor = interactor
        self.router = router
        self.courseID = courseID
        self.scheduler = scheduler
        fetchNotes(pageURL: pageURL, filter: .init(courseId: courseID))
    }

    // MARK: - Input Actions

    func goBack(_ viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    func seeMore() {
        guard currentPage + 1 < totalPages else {
            return
        }
        currentPage += 1
        filteredNotes.append(contentsOf: paginatedNotes[currentPage])
    }

    func refresh() async {
        listState.shouldReset = true
        await withCheckedContinuation { continuation in
            fetchNotes(ignoreCache: true, keepObserving: false, filter: getSelectedFilter()) {
                continuation.resume()
            }
        }
    }

    func deleteNote(_ note: CourseNotebookNote) {
        listState.shouldReset = false
        listState.isDeletedNoteLoaderVisible = true
        interactor.delete(id: note.id)
            .receive(on: scheduler)
            .sinkFailureOrValue(
                receiveFailure: { [weak self] error in
                    self?.listState.errorMessage = error.localizedDescription
                    self?.listState.isPresentedErrorToast = true
                    self?.listState.isDeletedNoteLoaderVisible = false
                }, receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.listState.isNoteDeleted.toggle()
                    self.allNotes.removeAll { $0.id == note.id }
                    self.filteredNotes.removeAll { $0.id == note.id }
                    self.listState.isDeletedNoteLoaderVisible = false
                    self.fetchTotalNotesCount()
                })
            .store(in: &subscriptions)
    }

    func filter() {
        listState.shouldReset = true
        fetchNotes(isCalledFromFilter: true, filter: getSelectedFilter())
    }

    func goToModuleItem(
        _ note: CourseNotebookNote,
        viewController: WeakViewController
    ) {
        let routePath = "/courses/\(note.courseId)/modules/items/\(note.objectId)?asset_type=Page&notebook_disabled=true"
        router.route(to: routePath, from: viewController)
    }

    func presentEditNote(note: CourseNotebookNote, viewController: WeakViewController) {
        let noteVC = EditNotebookAssembly.makeViewNoteViewController(courseNotebookNote: note) { [weak self] isNoteUpdated in
            if isNoteUpdated {
                self?.listState.successMessage = String(localized: "Note saved", bundle: .horizon)
                self?.listState.isPresentedSuccessToast = true
            }
            self?.listState.restoreAccessibility.send(())
        }
        router.show(noteVC, from: viewController)
    }

    func realod() {
        fetchNotes(ignoreCache: true, filter: .init(courseId: courseID))
    }

    // MARK: - Private Functions

    private func getSelectedFilter() -> NotebookQueryFilter {
        let course = listState.selectedCourse ?? courses.first
        let label = listState.selectedLable ?? courseLables.first
        let reactions = label?.id == "1" ? nil : [label?.key ?? ""]
        let courseID = course?.id == "-1" ? nil : course?.id
        return NotebookQueryFilter(reactions: reactions, courseId: courseID)
    }

    private func fetchNotes(
        pageURL: String? = nil,
        ignoreCache: Bool = false,
        keepObserving: Bool = true,
        isCalledFromFilter: Bool = false,
        filter: NotebookQueryFilter = .init(),
        completion: (() -> Void)? = nil
    ) {
        let isUnfiltered = filter.courseId == courseID && filter.reactions == nil && filter.pageId == nil

        interactor
            .getAllNotesWithCourses(
                pageURL: pageURL,
                ignoreCache: ignoreCache,
                keepObserving: keepObserving,
                filter: filter
            )
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] response in
                guard let self = self else { return }
                self.courses = response.courses

                if isUnfiltered {
                    self.totalNotesInDatabase = response.notes.count
                }

                self.setupPagination(with: response.notes, isCalledFromFilter: isCalledFromFilter)
                completion?()
            }
            .store(in: &subscriptions)
    }

    private func setupPagination(
        with notes: [CourseNotebookNote],
        isCalledFromFilter: Bool = false
    ) {
        allNotes = notes
        paginatedNotes = notes.chunked(into: 10)
        totalPages = paginatedNotes.count

        if listState.shouldReset {
            currentPage = 0
            filteredNotes = paginatedNotes.first ?? []
        }

        listState.isLoaderVisible = false
        listState.isSeeMoreButtonVisible = (currentPage < totalPages - 1)
        listState.isShowfilterView = totalNotesInDatabase > 0

        if filteredNotes.isEmpty {
            state = totalNotesInDatabase > 0 ? .filterEmpty : .empty
        } else {
            state = .data
        }
    }

    private func fetchTotalNotesCount() {
        interactor
            .getAllNotesWithCourses(
                pageURL: nil,
                ignoreCache: false,
                keepObserving: false,
                filter: .init(courseId: courseID)
            )
            .first()
            .receive(on: scheduler)
            .sink { [weak self] response in
                guard let self = self else { return }
                self.totalNotesInDatabase = response.notes.count
                self.setupPagination(with: self.allNotes, isCalledFromFilter: false)
            }
            .store(in: &subscriptions)
    }
}
