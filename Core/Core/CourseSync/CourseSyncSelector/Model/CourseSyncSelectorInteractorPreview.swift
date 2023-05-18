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

#if DEBUG

import Combine
import CombineExt

class CourseSyncSelectorInteractorPreview: CourseSyncSelectorInteractor {
    private let mockData: CurrentValueRelay<[CourseSyncSelectorEntry]>

    required init(courseID: String? = nil) {
        mockData = CurrentValueRelay<[CourseSyncSelectorEntry]>([
            .init(name: "Black Hole",
                  id: "0",
                  tabs: [
                      .init(id: "0", name: "Assignments", type: .assignments),
                      .init(id: "1", name: "Discussion", type: .assignments),
                      .init(id: "2", name: "Grades", type: .assignments),
                      .init(id: "3", name: "People", type: .assignments),
                      .init(id: "4", name: "Files", type: .files, isCollapsed: false),
                      .init(id: "5", name: "Syllabus", type: .assignments),
                  ],
                  files: [
                      .init(id: "0", name: "Creative Machines and Innovative Instrumentation.mov", url: nil),
                      .init(id: "0", name: "Intro Energy, Space and Time.mov", url: nil),
                  ],
                  isCollapsed: false),
        ])
    }

    func getCourseSyncEntries() -> AnyPublisher<[CourseSyncSelectorEntry], Error> {
        mockData
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func observeSelectedCount() -> AnyPublisher<Int, Never> {
        Future<Int, Never> { promise in
            promise(.success(3))
        }.eraseToAnyPublisher()
    }

    func observeIsEverythingSelected() -> AnyPublisher<Bool, Never> {
        mockData
            .replaceError(with: [])
            .map { $0.allSatisfy { $0.isEverythingSelected } }
            .replaceEmpty(with: true)
            .eraseToAnyPublisher()
    }

    func setSelected(selection: CourseEntrySelection, selectionState: ListCellView.SelectionState) {
        var entries = mockData.value

        switch selection {
        case let .course(courseIndex):
            entries[courseIndex].selectCourse(selectionState: selectionState)
        case let .tab(courseIndex, tabIndex):
            entries[courseIndex].selectTab(index: tabIndex, selectionState: selectionState)
        case let .file(courseIndex, fileIndex):
            entries[courseIndex].selectFile(index: fileIndex, selectionState: selectionState)
        }

        mockData.accept(entries)
    }

    func toggleAllCoursesSelection(isSelected _: Bool) {}
    func setCollapsed(selection _: CourseEntrySelection, isCollapsed _: Bool) {}

    func getSelectedCourseEntries() -> AnyPublisher<[CourseSyncSelectorEntry], Never> {
        mockData
            .replaceEmpty(with: [])
            .eraseToAnyPublisher()
    }
}

#endif
