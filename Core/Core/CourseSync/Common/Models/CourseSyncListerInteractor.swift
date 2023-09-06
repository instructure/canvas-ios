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
        let filteredToSynced = filter.isLimitedToSyncedOnly
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
            .flatMap { [entryComposerInteractor] in
                entryComposerInteractor.composeEntry(
                    from: $0,
                    useCache: filteredToSynced
                )
            }
            .collect()
            .replaceEmpty(with: [])
            .map { [sessionDefaults] in
                $0.applySelectionsFromPreviousSession(filter: filter,
                                                      sessionDefaults: sessionDefaults) }
            .map { filteredToSynced ? $0.selectedEntries() : $0 }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
}

// MARK: - Private Helpers

private extension Array where Element == CourseSyncEntry {

    /// Removes any tab and file that is not selected for syncing and returns the rest in a new array.
    func selectedEntries() -> [CourseSyncEntry] {
        filter { $0.selectionState == .selected || $0.selectionState == .partiallySelected }
        .map { filteredEntries in
            var entriesCpy = filteredEntries
            entriesCpy.tabs.removeAll { $0.selectionState == .deselected }
            entriesCpy.files.removeAll { $0.selectionState == .deselected }
            return entriesCpy
        }
    }

    func setSelected(
        selection: CourseEntrySelection,
        filter: CourseSyncListFilter,
        sessionDefaults: SessionDefaults
    ) -> [CourseSyncEntry] {
        var sessionDefaults = sessionDefaults
        var entriesCpy = self

        switch selection {
        case let .course(entryID):
            entriesCpy[id: entryID]?.selectCourse(selectionState: .selected)
        case let .tab(entryID, tabID):
            entriesCpy[id: entryID]?.selectTab(id: tabID, selectionState: .selected)
        case let .file(entryID, fileID):
            entriesCpy[id: entryID]?.selectFile(id: fileID, selectionState: .selected)
        }

        switch filter {
        case let .courseID(courseID):
            // If we only show one course then we should keep other course selections intact
            var oldSelections = sessionDefaults.offlineSyncSelections
            oldSelections.removeAll { $0.hasPrefix("courses/\(courseID)") }
            let newSelections = CourseSyncItemSelection.make(from: self)
            sessionDefaults.offlineSyncSelections = oldSelections + newSelections
        case .all:
            // If all courses are visible then it's safe to overwrite all course selections
            sessionDefaults.offlineSyncSelections = CourseSyncItemSelection.make(from: self)
        case .synced:
            break
        }

        return entriesCpy
    }

    func applySelectionsFromPreviousSession(
        filter: CourseSyncListFilter,
        sessionDefaults: SessionDefaults
    ) -> [CourseSyncEntry] {
        var entriesCpy = self
        let selections = sessionDefaults.offlineSyncSelections
            .compactMap { $0.toCourseEntrySelection(from: self) }

        for selection in selections {
            let entriesWithSelection = entriesCpy.setSelected(selection: selection,
                                                              filter: filter,
                                                              sessionDefaults: sessionDefaults)
            entriesCpy = entriesWithSelection
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
