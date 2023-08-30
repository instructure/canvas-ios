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
import CombineSchedulers
import Foundation

protocol CourseSyncListInteractor {
    func getCourseSyncEntries(filter: CourseSyncListFilter) -> AnyPublisher<[CourseSyncEntry], Error>
}

class CourseSyncListInteractorLive: CourseSyncListInteractor {
    private let courseListStore = ReactiveStore(
        useCase: GetCourseSyncSelectorCourses()
    )
    private let entryComposerInteractor: CourseSyncEntryComposerInteractor
    private var sessionDefaults: SessionDefaults
    private var filter: CourseSyncListFilter!
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        entryComposerInteractor: CourseSyncEntryComposerInteractor = CourseSyncEntryComposerInteractorLive(),
        sessionDefaults: SessionDefaults = AppEnvironment.shared.userDefaults ?? .fallback,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.entryComposerInteractor = entryComposerInteractor
        self.sessionDefaults = sessionDefaults
        self.scheduler = scheduler
    }

    func getCourseSyncEntries(filter: CourseSyncListFilter) -> AnyPublisher<[CourseSyncEntry], Error> {
        self.filter = filter

        unowned let unownedSelf = self

        let publisher: AnyPublisher<[CourseSyncSelectorCourse], Error>

        switch filter {
        case let .courseID(courseID):
            publisher = courseListStore.getEntities().filterToCourseID(courseID)
        case .all:
            publisher = courseListStore.getEntities()
        case .synced:
            publisher = courseListStore.getEntitiesFromDatabase()
        }

        return publisher
            .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
            .flatMap {
                unownedSelf.entryComposerInteractor.composeEntry(
                    from: $0,
                    useCache: unownedSelf.filter.isLimitedToSyncedOnly
                )
            }
            .collect()
            .replaceEmpty(with: [])
            .map { unownedSelf.applySelectionsFromPreviousSession($0) }
            .map {
                if unownedSelf.filter.isLimitedToSyncedOnly {
                    return unownedSelf.filterToSelectedCourses($0)
                } else {
                    return $0
                }
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func applySelectionsFromPreviousSession(
        _ entries: [CourseSyncEntry]
    ) -> [CourseSyncEntry] {
        var entriesCpy = entries
        let selections = sessionDefaults.offlineSyncSelections
            .compactMap { $0.toCourseEntrySelection(from: entries) }

        for selection in selections {
            let entriesWithSelection = setSelected(entries: entriesCpy, selection: selection, selectionState: .selected)
            entriesCpy = entriesWithSelection
        }

        return entriesCpy
    }

    /// Removes any tab and file that is not selected for syncing.
    private func filterToSelectedCourses(
        _ entries: [CourseSyncEntry]
    ) -> [CourseSyncEntry] {
        entries
            .filter { $0.selectionState == .selected || $0.selectionState == .partiallySelected }
            .map { filteredEntries in
                var entriesCpy = filteredEntries
                entriesCpy.tabs.removeAll { $0.selectionState == .deselected }
                entriesCpy.files.removeAll { $0.selectionState == .deselected }
                return entriesCpy
            }
    }

    private func setSelected(
        entries: [CourseSyncEntry],
        selection: CourseEntrySelection,
        selectionState: ListCellView.SelectionState
    ) -> [CourseSyncEntry] {
        var entriesCpy = entries

        switch selection {
        case let .course(entryID):
            entriesCpy[id: entryID]?.selectCourse(selectionState: selectionState)
        case let .tab(entryID, tabID):
            entriesCpy[id: entryID]?.selectTab(id: tabID, selectionState: selectionState)
        case let .file(entryID, fileID):
            entriesCpy[id: entryID]?.selectFile(id: fileID, selectionState: selectionState)
        }

        switch filter {
        case let .courseID(courseID):
            // If we only show one course then we should keep other course selections intact
            var oldSelections = sessionDefaults.offlineSyncSelections
            oldSelections.removeAll { $0.hasPrefix("courses/\(courseID)") }
            let newSelections = CourseSyncItemSelection.make(from: entries)
            sessionDefaults.offlineSyncSelections = oldSelections + newSelections
        case .all:
            // If all courses are visible then it's safe to overwrite all course selections
            sessionDefaults.offlineSyncSelections = CourseSyncItemSelection.make(from: entries)
        case .synced:
            break
        case .none:
            break
        }

        return entriesCpy
    }
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
