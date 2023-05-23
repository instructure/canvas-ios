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

class CourseSyncProgressInteractorPreview: CourseSyncProgressInteractor {

    private let mockData: CurrentValueRelay<[CourseSyncProgressEntry]>

    init() {
        mockData = CurrentValueRelay<[CourseSyncProgressEntry]>([
            .init(name: "Black Hole",
                  id: "0",
                  tabs: [
                      .init(id: "0", name: "Assignments", type: .assignments, progress: 1),
                      .init(id: "1", name: "Discussion", type: .assignments, progress: 0),
                      .init(id: "2", name: "Grades", type: .assignments, progress: 0.5),
                      .init(id: "3", name: "People", type: .assignments, progress: 0.75),
                      .init(id: "4", name: "Files", type: .files, isCollapsed: false, progress: 1),
                      .init(id: "5", name: "Syllabus", type: .assignments, progress: 0.5),
                  ],
                  files: [
                      .init(id: "0", name: "Creative Machines and Innovative Instrumentation.mov", progress: 1),
                      .init(id: "1", name: "Intro Energy, Space and Time.mov", progress: nil, error: "Sync failed"),
                  ],
                  isCollapsed: false,
                  progress: 0.78),
        ])
    }

    func getCourseSyncProgressEntries() -> AnyPublisher<[CourseSyncProgressEntry], Error> {
        mockData
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func setProgress(selection: CourseEntrySelection, progress: Float?) {}

    func setCollapsed(selection _: CourseEntrySelection, isCollapsed _: Bool) {}

    func remove(selection: CourseEntrySelection) {}

    func getSyncProgress() -> SyncProgress {
        let total = Double(64_000_000_000)
        return SyncProgress(total: Int64(total),
                            progress: Int64(0.456 * total))
    }
}

#endif
