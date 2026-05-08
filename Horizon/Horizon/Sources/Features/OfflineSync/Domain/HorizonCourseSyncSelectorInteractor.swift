//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Core
import Foundation

public final class HorizonCourseSyncSelectorInteractor: CourseSyncSelectorInteractor {

    public init() {}

    required public init(
        courseID: String?,
        courseSyncListInteractor: CourseSyncListInteractor,
        sessionDefaults: SessionDefaults
    ) {}

    public func getCourseSyncEntries() -> AnyPublisher<[CourseSyncEntry], Error> {
        Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    public func getSelectedCourseEntries() -> AnyPublisher<[CourseSyncEntry], Never> {
        Just([]).eraseToAnyPublisher()
    }

    public func getDeselectedCourseIds() -> AnyPublisher<[CourseSyncID], Never> {
        Just([]).eraseToAnyPublisher()
    }

    public func observeSelectedSize() -> AnyPublisher<Int, Never> {
        Just(0).eraseToAnyPublisher()
    }

    public func observeIsEverythingSelected() -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }

    public func getCourseName() -> AnyPublisher<String, Never> {
        Just("").eraseToAnyPublisher()
    }

    public func setSelected(selection: CourseEntrySelection, selectionState: OfflineListCellView.SelectionState) {}
    public func saveSelection() {}
    public func setCollapsed(selection: CourseEntrySelection, isCollapsed: Bool) {}
    public func toggleAllCoursesSelection(isSelected: Bool) {}
}
