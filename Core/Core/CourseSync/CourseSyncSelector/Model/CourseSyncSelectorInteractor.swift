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

protocol CourseSyncSelectorInteractor: AnyObject {
    /**
     - parameters:
        - sessionDefaults: The storage from where the selection states are read and written to.
     */
    init(courseID: String?, courseSyncListInteractor: CourseSyncListInteractor, sessionDefaults: SessionDefaults)
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
    private let courseSyncEntries = CurrentValueSubject<[CourseSyncEntry], Error>(.init())
    private var subscriptions = Set<AnyCancellable>()
    private let courseID: String?
    private let courseSyncListInteractor: CourseSyncListInteractor
    private var sessionDefaults: SessionDefaults

    init(
        courseID: String? = nil,
        courseSyncListInteractor: CourseSyncListInteractor = CourseSyncListInteractorLive(),
        sessionDefaults: SessionDefaults = AppEnvironment.shared.userDefaults ?? .fallback
    ) {
        self.courseID = courseID
        self.courseSyncListInteractor = courseSyncListInteractor
        self.sessionDefaults = sessionDefaults
    }

    // MARK: - Public Interface

    func getCourseSyncEntries() -> AnyPublisher<[CourseSyncEntry], Error> {
        let publisher: AnyPublisher<[CourseSyncEntry], Error>

        if let courseID {
            publisher = courseSyncListInteractor.getCourseSyncEntries(filter: .courseID(courseID))
        } else {
            publisher = courseSyncListInteractor.getCourseSyncEntries(filter: .all)
        }

        return publisher
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
        case let .course(entryID):
            entries[id: entryID]?.selectCourse(selectionState: selectionState)
        case let .tab(entryID, tabID):
            entries[id: entryID]?.selectTab(id: tabID, selectionState: selectionState)
        case let .file(entryID, fileID):
            entries[id: entryID]?.selectFile(id: fileID, selectionState: selectionState)
        }

        if let courseID {
            // If we only show one course then we should keep other course selections intact
            var oldSelections = sessionDefaults.offlineSyncSelections
            oldSelections.removeAll { $0.hasPrefix("courses/\(courseID)") }
            let newSelections = CourseSyncItemSelection.make(from: entries)
            sessionDefaults.offlineSyncSelections = oldSelections + newSelections
        } else {
            // If all courses are visible then it's safe to overwrite all course selections
            sessionDefaults.offlineSyncSelections = CourseSyncItemSelection.make(from: entries)
        }

        courseSyncEntries.send(entries)
    }

    func setCollapsed(selection: CourseEntrySelection, isCollapsed: Bool) {
        var entries = courseSyncEntries.value

        switch selection {
        case let .course(entryID):
            entries[id: entryID]?.isCollapsed = isCollapsed
        case let .tab(entryID, tabID):
            entries[id: entryID]?.tabs[id: tabID]?.isCollapsed = isCollapsed
        case .file:
            break
        }

        courseSyncEntries.send(entries)
    }

    func toggleAllCoursesSelection(isSelected: Bool) {
        unowned let unownedSelf = self

        courseSyncEntries.value
            .indices
            .map { unownedSelf.courseSyncEntries.value[$0].id }
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
                syncEntries.first { $0.id == "courses/\(courseID)" }?.name
            }
            .replaceNil(with: "")
            .replaceError(with: "")
            .eraseToAnyPublisher()
    }
}
