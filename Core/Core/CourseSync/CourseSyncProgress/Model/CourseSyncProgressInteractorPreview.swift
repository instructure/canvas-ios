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

    private let mockData: CurrentValueRelay<[CourseSyncEntry]>

    init() {
        mockData = CurrentValueRelay<[CourseSyncEntry]>([
            .init(name: "Black Hole",
                  id: "0",
                  tabs: [
                    .init(id: "0", name: "Assignments", type: .assignments, state: .loading(1)),
                    .init(id: "1", name: "Discussion", type: .assignments, state: .loading(0)),
                    .init(id: "2", name: "Grades", type: .assignments, state: .loading(0.5)),
                    .init(id: "3", name: "People", type: .assignments, state: .loading(0.75)),
                    .init(id: "4", name: "Files", type: .files, isCollapsed: false, state: .loading(1)),
                    .init(id: "5", name: "Syllabus", type: .assignments, state: .loading(0.5)),
                  ],
                  files: [
                    .make(id: "0", displayName: "Creative Machines and Innovative Instrumentation.mov", state: .loading(1)),
                    .make(id: "1", displayName: "Intro Energy, Space and Time.mov", state: .error),
                  ],
                  isCollapsed: false,
                  state: .loading(0.78)),
        ])
    }

    func observeEntries() -> AnyPublisher<[CourseSyncEntry], Error> {
        mockData
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func setCollapsed(selection _: CourseEntrySelection, isCollapsed _: Bool) {}

    func cancelSync() {}

    func retrySync() {}

    func observeDownloadProgress() -> AnyPublisher<ReactiveStore<GetCourseSyncDownloadProgressUseCase>.State, Never> {
        Empty(completeImmediately: false).eraseToAnyPublisher()
    }
}

#endif
