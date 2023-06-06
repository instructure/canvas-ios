//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Foundation

protocol CourseSyncSelectorInteractor {
    /**
     - parameters:
        - sessionDefaults: The storage from where the selection states are read and written to.
     */
    init(courseID: String?, sessionDefaults: SessionDefaults)
    func getCourseSyncEntries() -> AnyPublisher<[CourseSyncEntry], Error>
    func observeSelectedCount() -> AnyPublisher<Int, Never>
    func observeIsEverythingSelected() -> AnyPublisher<Bool, Never>
    func setSelected(selection: CourseEntrySelection, selectionState: ListCellView.SelectionState)
    func setCollapsed(selection: CourseEntrySelection, isCollapsed: Bool)
    func toggleAllCoursesSelection(isSelected: Bool)
    func getSelectedCourseEntries() -> AnyPublisher<[CourseSyncEntry], Never>
    func getCourseName() -> AnyPublisher<String, Never>
}

final class CourseSyncSelectorInteractorLive: CourseSyncSelectorInteractor {
    private let courseListStore = ReactiveStore(
        useCase: GetCourseSyncSelectorCourses()
    )
    private let courseSyncEntries = CurrentValueSubject<[CourseSyncEntry], Error>(.init())
    private var subscriptions = Set<AnyCancellable>()
    private let courseID: String?
    private let sessionDefaults: SessionDefaults

    init(courseID: String? = nil, sessionDefaults: SessionDefaults) {
        self.courseID = courseID
        self.sessionDefaults = sessionDefaults
    }

    // MARK: - Public Interface

    func getCourseSyncEntries() -> AnyPublisher<[CourseSyncEntry], Error> {
        courseListStore.getEntities()
            .filterToCourseID(courseID)
            .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
            .flatMap { self.getAllFilesIfFilesTabIsEnabled(course: $0) }
            .collect()
            .replaceEmpty(with: [])
            .handleEvents(
                receiveOutput: { self.courseSyncEntries.send($0) },
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        self.courseSyncEntries.send(completion: .failure(error))
                    default:
                        break
                    }
                }
            )
            .flatMap { self.applySelectionsFromPreviousSession($0) }
            .flatMap { _ in self.courseSyncEntries.eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }

    func observeSelectedCount() -> AnyPublisher<Int, Never> {
        courseSyncEntries
            .replaceError(with: [])
            .map {
                $0.reduce(0) { partialResult, entry in
                    partialResult + entry.selectionCount
                }
            }
            .replaceEmpty(with: 0)
            .eraseToAnyPublisher()
    }

    func observeIsEverythingSelected() -> AnyPublisher<Bool, Never> {
        courseSyncEntries
            .replaceError(with: [])
            .map { $0.allSatisfy { $0.isEverythingSelected } }
            .replaceEmpty(with: true)
            .eraseToAnyPublisher()
    }

    func setSelected(selection: CourseEntrySelection, selectionState: ListCellView.SelectionState) {
        var entries = courseSyncEntries.value

        switch selection {
        case let .course(courseIndex):
            entries[courseIndex].selectCourse(selectionState: selectionState)
        case let .tab(courseIndex, tabIndex):
            entries[courseIndex].selectTab(index: tabIndex, selectionState: selectionState)
        case let .file(courseIndex, fileIndex):
            entries[courseIndex].selectFile(index: fileIndex, selectionState: selectionState)
        }

        courseSyncEntries.send(entries)
    }

    func setCollapsed(selection: CourseEntrySelection, isCollapsed: Bool) {
        var entries = courseSyncEntries.value

        switch selection {
        case let .course(courseIndex):
            entries[courseIndex].isCollapsed = isCollapsed
        case let .tab(courseIndex, tabIndex):
            entries[courseIndex].tabs[tabIndex].isCollapsed = isCollapsed
        case .file:
            break
        }

        courseSyncEntries.send(entries)
    }

    func toggleAllCoursesSelection(isSelected: Bool) {
        courseSyncEntries.value
            .indices
            .map { CourseEntrySelection.course($0) }
            .forEach { setSelected(selection: $0, selectionState: isSelected ? .selected : .deselected) }
    }

    func getSelectedCourseEntries() -> AnyPublisher<[CourseSyncEntry], Never> {
        courseSyncEntries
            .map { $0.filter { $0.selectionState == .selected || $0.selectionState == .partiallySelected } }
            .replaceError(with: [])
            .first()
            .eraseToAnyPublisher()
    }

    func getCourseName() -> AnyPublisher<String, Never> {
        guard let courseID else {
            return Just(NSLocalizedString("All Courses", comment: "")).eraseToAnyPublisher()
        }

        return courseSyncEntries
            .first { !$0.isEmpty }
            .map { syncEntries in
                syncEntries.first { $0.id == courseID }?.name
            }
            .replaceNil(with: "")
            .replaceError(with: "")
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func applySelectionsFromPreviousSession(_ entries: [CourseSyncEntry])
    -> AnyPublisher<[CourseSyncEntry], Never> {
        Future<[CourseSyncEntry], Never> { [sessionDefaults, weak self] promise in
            sessionDefaults.offlineSyncSelections
                .compactMap { $0.toCourseEntrySelection(from: entries) }
                .forEach { self?.setSelected(selection: $0, selectionState: .selected) }
            promise(.success(entries))
        }.eraseToAnyPublisher()
    }

    private func getTabs(courseId: String) -> AnyPublisher<[CourseSyncEntry.Tab], Error> {
        ReactiveStore(
            useCase: GetContextTabs(
                context: Context.course(courseId)
            )
        )
        .getEntities()
        .map { $0.offlineSupportedTabs() }
        .map {
            $0.map {
                CourseSyncEntry.Tab(
                    id: "\(courseId)-\($0.id)",
                    name: $0.label,
                    type: $0.name
                )
            }
        }
        .eraseToAnyPublisher()
    }

    private func getAllFilesIfFilesTabIsEnabled(
        course: CourseSyncSelectorCourse
    ) -> AnyPublisher<CourseSyncEntry, Error> {
        let tabs = Array(course.tabs).offlineSupportedTabs()
        let mappedTabs = tabs.map {
            CourseSyncEntry.Tab(
                id: "\(course.courseId)-\($0.id)",
                name: $0.label,
                type: $0.name
            )
        }
        if tabs.isFilesTabEnabled() {
            return getAllFiles(courseId: course.courseId)
                .map { files in
                    CourseSyncEntry(
                        name: course.name,
                        id: course.courseId,
                        tabs: mappedTabs,
                        files: files
                    )
                }
                .eraseToAnyPublisher()
        } else {
            return Just(
                CourseSyncEntry(
                    name: course.name,
                    id: course.courseId,
                    tabs: mappedTabs,
                    files: []
                )
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
    }

    private func getAllFiles(courseId: String) -> AnyPublisher<[CourseSyncEntry.File], Error> {
        unowned let unownedSelf = self

        return ReactiveStore(
            useCase: GetFolderByPath(
                context: .course(courseId)
            )
        )
        .getEntities()
        .flatMap {
            Publishers.Sequence(sequence: $0)
                .filter { !$0.lockedForUser && !$0.hiddenForUser }
                .setFailureType(to: Error.self)
                .flatMap { unownedSelf.getFiles(folderID: $0.id, initialArray: []) }
        }
        .map {
            $0
                .compactMap { $0.file }
                .filter { $0.url != nil && $0.mimeClass != nil }
                .map {
                    CourseSyncEntry.File(
                        id: $0.id ?? Foundation.UUID().uuidString,
                        displayName: $0.displayName ?? NSLocalizedString("Unknown file", comment: ""),
                        fileName: $0.filename,
                        url: $0.url!,
                        mimeClass: $0.mimeClass!
                    )
                }
        }
        .replaceEmpty(with: [])
        .eraseToAnyPublisher()
    }

    private func getFiles(folderID: String, initialArray: [FolderItem]) -> AnyPublisher<[FolderItem], Error> {
        unowned let unownedSelf = self

        var result = initialArray

        return getFilesAndFolderIDs(folderID: folderID)
            .flatMap { files, folderIDs in
                result.append(contentsOf: files)

                guard folderIDs.count > 0 else {
                    return Just([result])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return Publishers.Sequence(sequence: folderIDs)
                    .setFailureType(to: Error.self)
                    .flatMap {
                        unownedSelf.getFiles(
                            folderID: $0,
                            initialArray: result
                        )
                        .handleEvents(receiveOutput: { result = $0 })
                    }
                    .collect()
                    .eraseToAnyPublisher()
            }
            .first()
            .map { _ in result }
            .eraseToAnyPublisher()
    }

    private func getFilesAndFolderIDs(folderID: String) -> AnyPublisher<([FolderItem], [String]), Error> {
        ReactiveStore(
            useCase: GetFolderItems(
                folderID: folderID
            )
        )
        .getEntities()
        .tryCatch { error -> AnyPublisher<[FolderItem], Error> in
            if case .unauthorized = error as? Core.APIError {
                return Just([])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                throw error
            }
        }
        .map {
            let files = $0
                .filter {
                    if let file = $0.file {
                        return !file.lockedForUser && !file.hiddenForUser
                    } else {
                        return false
                    }
                }
            let folderIDs = $0
                .filter { $0.folder != nil }
                .compactMap { $0.folder }
                .filter { !$0.lockedForUser && !$0.hiddenForUser }
                .map { $0.id }

            return (files, folderIDs)
        }
        .eraseToAnyPublisher()
    }
}

enum CourseEntrySelection: Equatable {
    typealias CourseIndex = Int
    typealias TabIndex = Int
    typealias FileIndex = Int

    case course(CourseIndex)
    case tab(CourseIndex, TabIndex)
    case file(CourseIndex, FileIndex)
}

private extension AnyPublisher<[CourseSyncSelectorCourse], Error> {

    func filterToCourseID(_ courseID: String?) -> AnyPublisher<[CourseSyncSelectorCourse], Error> {
        map { [courseID] courses in
            guard let courseID else {
                return courses
            }

            return courses.filter {
                $0.courseId == courseID
            }
        }
        .eraseToAnyPublisher()
    }
}
