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
    init(courseID: String?, fileFolderInteractor: CourseSyncFileFolderInteractor, sessionDefaults: SessionDefaults)
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
    private let fileFolderInteractor: CourseSyncFileFolderInteractor
    private var sessionDefaults: SessionDefaults

    init(
        courseID: String? = nil,
        fileFolderInteractor: CourseSyncFileFolderInteractor = CourseSyncFileFolderInteractorLive(),
        sessionDefaults: SessionDefaults
    ) {
        self.courseID = courseID
        self.fileFolderInteractor = fileFolderInteractor
        self.sessionDefaults = sessionDefaults
    }

    // MARK: - Public Interface

    func getCourseSyncEntries() -> AnyPublisher<[CourseSyncEntry], Error> {
        courseListStore.getEntities()
            .filterToCourseID(courseID)
            .flatMap { Publishers.Sequence(sequence: $0).setFailureType(to: Error.self) }
            .flatMap { self.fileFolderInteractor.getAllFiles(course: $0) }
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
                syncEntries.first { $0.id == "courses/\(courseID)" }?.name
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
}

public enum CourseEntrySelection: Codable, Equatable, Comparable {
    public typealias CourseIndex = Int
    public typealias TabIndex = Int
    public typealias FileIndex = Int

    case course(CourseIndex)
    case tab(CourseIndex, TabIndex)
    case file(CourseIndex, FileIndex)

    private var sortPriority: Int {
        switch self {
        case .course: return 0
        case .tab: return 1
        case .file: return 2
        }
    }

    public static func < (lhs: CourseEntrySelection, rhs: CourseEntrySelection) -> Bool {
        switch (lhs, rhs) {
        case let (.course(lhsCourseIndex), .course(rhsCourseIndex)):
            return lhsCourseIndex <= rhsCourseIndex
        case (let .file(lhsCourseIndex, lhsFileIndex), let .file(rhsCourseIndex, rhsFileIndex)):
            return lhsCourseIndex <= rhsCourseIndex && lhsFileIndex <= rhsFileIndex
        case (let .tab(lhsCourseIndex, lhsTabIndex), let .tab(rhsCourseIndex, rhsTabIndex)):
            return lhsCourseIndex <= rhsCourseIndex && lhsTabIndex <= rhsTabIndex
        default:
            return lhs.sortPriority < rhs.sortPriority
        }
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
